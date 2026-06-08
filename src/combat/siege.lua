-- The siege: the mutable one-commit combat instance the UI drives and tests
-- exercise. PURE (no love.*) so it stays unit-testable. Wraps a deck + a town,
-- tracks the sculpt budget, lane assignment, locked suit, and expedition HP, and
-- resolves the commit through the pure resolver.
local Deck = require("src.core.deck")
local Rng = require("src.core.rng")
local Resolver = require("src.combat.resolver")
local FightBack = require("src.combat.fightback")

local M = {}

local function removeFromHand(siege, card)
	for i, c in ipairs(siege.hand) do
		if c == card then
			table.remove(siege.hand, i)
			return true
		end
	end
	return false
end

-- Start a siege over a freshly built+shuffled deck and a fresh town instance.
function M.new(deck, town, opts)
	opts = opts or {}
	Deck.draw(deck) -- fill the hand to the hand size
	local hp = opts.hp or 30 -- expedition HP (tuning); moves to expedition.lua in M4
	return {
		deck = deck,
		hand = deck.hand,
		town = town,
		sculptTurnsLeft = 2,
		exchangesLeft = 3,
		lanes = {}, -- [structureId] = { cards }
		assigned = {}, -- [card] = structureId
		lockedSuit = nil,
		expeditionHP = hp,
		maxHP = hp,
		gold = 0,
		essence = 0,
		seed = opts.seed or 1,
		tokens = opts.tokens or { coin = 1, die = 2 }, -- gamble consumables (tuning)
		bonuses = {}, -- [structureId] = { add, mult } from spent tokens
	}
end

-- Find an ability's params on a card (card.ability may be one entry or a list).
local function abilityParams(card, kind)
	local a = card.ability
	if not a then
		return nil
	end
	local list = a.kind and { a } or a
	for _, ab in ipairs(list) do
		if ab.kind == kind then
			return ab.params or {}
		end
	end
	return nil
end

-- How many lanes a card may occupy at once (Imp / Hexling = 2 via multiLane).
local function maxLanes(card)
	local p = abilityParams(card, "multiLane")
	return (p and (p.lanes or 2)) or 1
end

-- Remove a card from every lane it occupies (a card may be in >1 lane via multiLane).
function M.unassign(siege, card)
	local ids = siege.assigned[card]
	if not ids then
		return
	end
	for _, id in ipairs(ids) do
		local lane = siege.lanes[id]
		if lane then
			for i = #lane, 1, -1 do
				if lane[i] == card then
					table.remove(lane, i)
				end
			end
			if #lane == 0 then
				siege.lanes[id] = nil
			end
		end
	end
	siege.assigned[card] = nil
end

-- Reach: a back structure is reachable only if every structure in front is
-- destroyed, or a Caster (Diamonds) is in the lane (the card being assigned counts).
function M.reachable(siege, structureId, card)
	if Resolver.frontCleared(siege.town, structureId) then
		return true
	end
	if card and card.suit == "Diamonds" then
		return true
	end
	local lane = siege.lanes[structureId]
	if lane then
		for _, c in ipairs(lane) do
			if c.suit == "Diamonds" then
				return true
			end
		end
	end
	return false
end

-- Assign a hand card to a structure lane (any card -> any open, reachable structure).
-- A card occupies one lane; locked-suit / destroyed / unreachable targets are rejected.
function M.assign(siege, card, structureId)
	local structure = siege.town.structures[structureId]
	if not structure or structure.destroyed then
		return false
	end
	if siege.lockedSuit and card.suit == siege.lockedSuit then
		return false
	end
	if not M.reachable(siege, structureId, card) then
		return false
	end
	local ids = siege.assigned[card] or {}
	for _, id in ipairs(ids) do
		if id == structureId then
			return true -- already assigned here
		end
	end
	if #ids >= maxLanes(card) then
		if maxLanes(card) == 1 then
			M.unassign(siege, card) -- single-lane card: move it
			ids = {}
		else
			return false -- multi-lane card already at its limit
		end
	end
	siege.lanes[structureId] = siege.lanes[structureId] or {}
	table.insert(siege.lanes[structureId], card)
	ids[#ids + 1] = structureId
	siege.assigned[card] = ids
	return true
end

-- Exchange (toss + redraw) the given cards; costs from the 3-card sculpt budget.
-- Sticky cards (Slime 2-4) refuse to leave: they are skipped, not tossed.
function M.exchange(siege, cards)
	local toToss = {}
	for _, card in ipairs(cards) do
		if not abilityParams(card, "sticky") then
			toToss[#toToss + 1] = card
		end
	end
	local n = #toToss
	if n == 0 or n > siege.exchangesLeft then
		return false
	end
	for _, card in ipairs(toToss) do
		M.unassign(siege, card)
		removeFromHand(siege, card)
		Deck.discard(siege.deck, card)
	end
	for _ = 1, n do
		siege.seed = siege.seed + 1
		local drawn = Deck.drawOne(siege.deck, siege.seed)
		if drawn then
			siege.hand[#siege.hand + 1] = drawn
		end
	end
	siege.exchangesLeft = siege.exchangesLeft - n
	return true
end

-- End a sculpt turn: the town fights back, structures with Regen heal, then the
-- turn counter drops (stalling to sculpt lets Regen structures recover).
function M.endSculpt(siege)
	if siege.sculptTurnsLeft <= 0 then
		return false
	end
	siege.sculptTurnsLeft = siege.sculptTurnsLeft - 1
	FightBack.apply(siege)
	for _, s in ipairs(siege.town.structures) do
		if not s.destroyed and s.keywords and s.keywords.regen then
			s.hp = s.hp + s.keywords.regen
		end
	end
	return true
end

-- The pending lane breakdown for a structure (for the live UI readout).
function M.preview(siege, structureId)
	local lane = siege.lanes[structureId]
	if not lane or #lane == 0 then
		return nil
	end
	local bonus = siege.bonuses[structureId] or {}
	return Resolver.resolveLane(lane, siege.town.structures[structureId], {
		bonusAdd = bonus.add,
		bonusMult = bonus.mult,
		shieldActive = not Resolver.frontCleared(siege.town, structureId),
	})
end

local function laneBonus(siege, laneId)
	siege.bonuses[laneId] = siege.bonuses[laneId] or { add = 0, mult = 1 }
	return siege.bonuses[laneId]
end

-- Spend a die on a lane: +1..6 to its attack (seeded). Returns the roll or nil.
function M.applyDie(siege, laneId)
	if (siege.tokens.die or 0) <= 0 or not siege.lanes[laneId] then
		return nil
	end
	siege.seed = siege.seed + 1
	local roll = Rng.new(siege.seed):random(6)
	laneBonus(siege, laneId).add = laneBonus(siege, laneId).add + roll
	siege.tokens.die = siege.tokens.die - 1
	return roll
end

-- Spend a coin on a lane: flip heads x1.5 / tails x0.5. Returns true on heads.
function M.applyCoin(siege, laneId)
	if (siege.tokens.coin or 0) <= 0 or not siege.lanes[laneId] then
		return nil
	end
	siege.seed = siege.seed + 1
	local heads = Rng.new(siege.seed):random(2) == 1
	local bonus = laneBonus(siege, laneId)
	bonus.mult = bonus.mult * (heads and 1.5 or 0.5)
	siege.tokens.coin = siege.tokens.coin - 1
	return heads
end

-- Commit every lane at once: the resolver marks destroyed structures, bonus loot,
-- and per-ability/keyword side effects (heal, thorns); we apply them and the outcome.
function M.commit(siege)
	local resolved = Resolver.resolveCommit(siege.lanes, siege.town, { bonuses = siege.bonuses })
	siege.gold = siege.gold + (resolved.loot.gold or 0)
	siege.essence = siege.essence + (resolved.loot.essence or 0)
	siege.expeditionHP = math.min(siege.maxHP, siege.expeditionHP + (resolved.heal or 0))
	siege.expeditionHP = siege.expeditionHP - (resolved.thorns or 0)

	local outcome
	if resolved.conquered then
		outcome = "victory"
	else
		siege.expeditionHP = siege.expeditionHP - 10 -- shortfall damage (tuning)
		outcome = siege.expeditionHP <= 0 and "retreat" or "shortfall"
	end
	return { outcome = outcome, conquered = resolved.conquered, loot = resolved.loot, results = resolved.results }
end

return M
