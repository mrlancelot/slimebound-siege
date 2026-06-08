-- The pure siege resolver: scores poker-combo lanes against structures.
-- PURE by contract: no love.* and no globals (no RNG either - gamble rolls are
-- made by siege.lua and passed in as modifiers), so it unit-tests under plain lua.
--
-- Pipeline (resolveLane): pre-lane ability hooks -> combo -> mult hooks ->
-- flat/scale hooks -> element/type (ward, poison) -> base attack -> gamble
-- modifiers -> armor -> hp/shield -> destroyed + post-destroy hooks. Side effects
-- (heal, thorns, overkill carry, loot) are returned as data for siege.commit.
local Elements = require("src.data.elements")
local Matchups = require("src.data.matchups")
local Effects = require("src.combat.effects")

local M = {}

-- Combo kind -> attack multiplier (see ARCHITECTURE combo tiers).
local MULTS = {
	high = 1,
	pair = 2,
	three = 3,
	straight = 4,
	flush = 5,
	fullhouse = 6,
	four = 7,
	straightflush = 8,
}
M.MULTS = MULTS

-- Sum of the lane's rank values.
function M.rankSum(cards)
	local sum = 0
	for _, card in ipairs(cards) do
		sum = sum + card.value
	end
	return sum
end

-- Longest run of consecutive distinct values; if `suit` is given, only count
-- values present in that suit. Returns the run length (Ace is high only for M1).
local function longestRun(cards, suit)
	local present = {}
	for _, card in ipairs(cards) do
		if not suit or card.suit == suit then
			present[card.value] = true
		end
	end
	local best, run = 0, 0
	for v = 2, 14 do
		run = present[v] and (run + 1) or 0
		best = math.max(best, run)
	end
	return best
end

-- Best poker pattern over the lane's cards -> { kind, mult, rankSum }.
function M.evaluateCombo(cards)
	local rankCounts, suitCounts = {}, {}
	for _, card in ipairs(cards) do
		rankCounts[card.value] = (rankCounts[card.value] or 0) + 1
		suitCounts[card.suit] = (suitCounts[card.suit] or 0) + 1
	end

	local maxKind, hasTriple, pairCount, flushSuit = 0, false, 0, nil
	for _, n in pairs(rankCounts) do
		maxKind = math.max(maxKind, n)
		if n >= 3 then
			hasTriple = true
		end
		if n >= 2 then
			pairCount = pairCount + 1
		end
	end
	for suit, n in pairs(suitCounts) do
		if n >= 5 then
			flushSuit = suit
		end
	end

	local kind = "high"
	if flushSuit and longestRun(cards, flushSuit) >= 5 then
		kind = "straightflush"
	elseif maxKind >= 4 then
		kind = "four"
	elseif hasTriple and pairCount >= 2 then
		kind = "fullhouse"
	elseif flushSuit then
		kind = "flush"
	elseif longestRun(cards) >= 5 then
		kind = "straight"
	elseif maxKind == 3 then
		kind = "three"
	elseif maxKind == 2 then
		kind = "pair"
	end

	return { kind = kind, mult = MULTS[kind], rankSum = M.rankSum(cards) }
end

-- The lane's matchup element: the most common element, ties broken by priority.
function M.dominantElement(cards)
	local counts = {}
	for _, card in ipairs(cards) do
		counts[card.element] = (counts[card.element] or 0) + 1
	end
	local best
	for _, element in ipairs(Elements.priority) do
		if counts[element] and (not best or counts[element] > counts[best]) then
			best = element
		end
	end
	return best
end

-- Element x material multiplier; 1.0 (neutral) when either side is unlisted.
function M.typeMultiplier(element, material)
	local row = Matchups[element]
	local mult = row and row[material]
	return mult or 1
end

-- DEF removed by Frost cards in the lane (lowers the target before the compare).
function M.frostReduction(cards)
	local frost = 0
	for _, card in ipairs(cards) do
		if card.element == "Frost" then
			frost = frost + 1
		end
	end
	return frost * Elements.frostDefPerCard
end

local function hasPoison(cards)
	for _, card in ipairs(cards) do
		if card.element == "Poison" then
			return true
		end
	end
	return false
end

-- A card's ability list (single {kind,params} or a list of them).
local function abilitiesOf(card)
	local a = card.ability
	if not a then
		return nil
	end
	return a.kind and { a } or a
end

-- Run a named ability hook over the lane's (working) cards.
local function runHook(ctx, hook)
	for _, card in ipairs(ctx.cards) do
		local list = abilitiesOf(card)
		if list then
			for _, ab in ipairs(list) do
				local handler = Effects[ab.kind] and Effects[ab.kind][hook]
				if handler then
					handler(ctx, card, ab.params or {})
				end
			end
		end
	end
end

-- Shallow-copy each card so pre-lane tweaks (wild, rank-copy, double) don't leak
-- back to the caller's hand.
local function workingCopy(cards)
	local copy = {}
	for i, card in ipairs(cards) do
		local c = {}
		for k, v in pairs(card) do
			c[k] = v
		end
		copy[i] = c
	end
	return copy
end

-- Score one lane vs one structure. `opts` (all optional):
--   commit       commit-wide context (clubs/casters counts, packleader/khan flags)
--   bonusAdd     gamble: flat add to attack (die)         -- (base + add) * mult
--   bonusMult    gamble: attack multiplier (coin)
--   shieldActive a front structure still stands (Shield keyword blocks damage)
function M.resolveLane(cards, structure, opts)
	opts = opts or {}
	local ctx = {
		cards = workingCopy(cards),
		structure = structure,
		commit = opts.commit,
		flatAdd = 0,
		multAdd = 0,
		attackScale = 1,
		hpReduce = M.frostReduction(cards),
		armorReduce = 0,
		ignoreArmor = false,
		heal = 0,
		carry = 0,
	}

	runHook(ctx, "preLane")
	local combo = M.evaluateCombo(ctx.cards)
	if ctx.forcePair and combo.mult < MULTS.pair then
		combo = { kind = "pair", mult = MULTS.pair, rankSum = combo.rankSum }
	end
	ctx.combo = combo

	runHook(ctx, "mult")
	-- commit-wide mult/scale flags
	if ctx.commit then
		if ctx.commit.packleader and combo.kind == "pair" then
			ctx.multAdd = ctx.multAdd + 1
		end
		if ctx.commit.khan and (combo.kind == "flush" or combo.kind == "straightflush") then
			ctx.attackScale = ctx.attackScale * 2
		end
	end
	runHook(ctx, "flat")

	local element = M.dominantElement(ctx.cards)
	local typeMult = M.typeMultiplier(element, structure.material)
	local kw = structure.keywords
	if kw and kw.ward == element then
		typeMult = typeMult * 0.5
	end
	if typeMult < 1 and hasPoison(ctx.cards) then
		typeMult = 1 -- Poison ignores the resist case.
	end

	local base = combo.rankSum * (combo.mult + ctx.multAdd) * typeMult * ctx.attackScale + ctx.flatAdd
	local attack = (base + (opts.bonusAdd or 0)) * (opts.bonusMult or 1)

	local armor = ctx.ignoreArmor and 0 or math.max(0, (structure.armor or 0) - ctx.armorReduce)
	local damage = math.max(0, attack - armor)
	local hp = structure.hp - ctx.hpReduce
	local shielded = kw and kw.shield and opts.shieldActive or false
	local destroyed = (not shielded) and damage >= hp
	local overkill = destroyed and math.max(0, damage - hp) or 0

	local result = {
		attack = attack,
		damage = damage,
		destroyed = destroyed,
		overkill = overkill,
		hp = hp,
		armor = armor,
		combo = combo,
		type = typeMult,
		element = element,
		shielded = shielded,
		heal = 0,
		thorns = (kw and kw.thorns) or 0,
		carry = 0,
	}
	if destroyed then
		ctx.result = result
		runHook(ctx, "postDestroy")
		result.heal = ctx.heal
		result.carry = ctx.carry
	end
	return result
end

-- True if every structure in front of `id` (lower index) is destroyed.
local function frontCleared(town, id)
	for i = 1, id - 1 do
		if not town.structures[i].destroyed then
			return false
		end
	end
	return true
end
M.frontCleared = frontCleared

-- Commit-wide context for abilities that count across all lanes.
local function buildCommitCtx(lanes)
	local ctx = { clubs = 0, casters = 0, packleader = false, khan = false }
	for _, cards in pairs(lanes) do
		for _, card in ipairs(cards) do
			if card.suit == "Clubs" then
				ctx.clubs = ctx.clubs + 1
			elseif card.suit == "Diamonds" then
				ctx.casters = ctx.casters + 1
			end
			for _, ab in ipairs(abilitiesOf(card) or {}) do
				if ab.kind == "pairsPlusMultCommit" then
					ctx.packleader = true
				elseif ab.kind == "flushDoubleCommit" then
					ctx.khan = true
				end
			end
		end
	end
	return ctx
end

-- Resolve every lane at once (front -> back so Shield/destruction chains within
-- the commit). `lanes` is { [structureId] = cards }; `opts.bonuses[id]` carries
-- gamble modifiers. Returns per-lane results + aggregated side effects.
function M.resolveCommit(lanes, town, opts)
	opts = opts or {}
	local bonuses = opts.bonuses or {}
	local commit = buildCommitCtx(lanes)
	local results, conquered = {}, false
	local heal, thorns = 0, 0
	local loot = { gold = 0, essence = 0 }

	-- front -> back ordering by structure index
	local ids = {}
	for id in pairs(lanes) do
		ids[#ids + 1] = id
	end
	table.sort(ids)

	for _, id in ipairs(ids) do
		local structure = town.structures[id]
		local bonus = bonuses[id] or {}
		local result = M.resolveLane(lanes[id], structure, {
			commit = commit,
			bonusAdd = bonus.add,
			bonusMult = bonus.mult,
			shieldActive = not frontCleared(town, id),
		})
		results[id] = result
		heal = heal + (result.heal or 0)
		thorns = thorns + (result.thorns or 0)
		if result.destroyed then
			structure.destroyed = true
			if structure.core then
				conquered = true
			elseif not structure.looted then
				loot.gold = loot.gold + 10 -- bonus loot for non-core (tuning)
			end
			-- Dragonkin/Ember Brute overkill carry -> next surviving non-core target.
			if result.carry and result.carry > 0 then
				for i = 1, #town.structures do
					local s = town.structures[i]
					if not s.destroyed and not s.core and i ~= id then
						if result.carry - (s.armor or 0) >= s.hp then
							s.destroyed = true
							loot.gold = loot.gold + 10
						end
						break
					end
				end
			end
		end
	end

	return { results = results, conquered = conquered, heal = heal, thorns = thorns, loot = loot, commit = commit }
end

return M
