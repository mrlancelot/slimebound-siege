-- The pure siege resolver: scores poker-combo lanes against structures.
-- PURE by contract: no love.* and no globals, so it unit-tests under plain lua.
-- attack = rankSum x combo-mult x type-mult; a structure falls when attack >= def.
local Elements = require("src.data.elements")
local Matchups = require("src.data.matchups")

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

-- Score one lane vs one structure, applying the element matchup, Frost DEF
-- reduction, and Poison's ignore-resist rule.
function M.resolveLane(cards, structure)
	local combo = M.evaluateCombo(cards)
	local element = M.dominantElement(cards)
	local typeMult = M.typeMultiplier(element, structure.material)
	if typeMult == 0.5 and hasPoison(cards) then
		typeMult = 1 -- Poison ignores the resist case.
	end
	local def = structure.def - M.frostReduction(cards)
	local attack = combo.rankSum * combo.mult * typeMult
	return {
		attack = attack,
		destroyed = attack >= def,
		combo = combo,
		type = typeMult,
		element = element,
		def = def,
	}
end

-- Resolve every lane at once. `lanes` is { [structureId] = cards }; the town's
-- structures share those ids. The town is conquered if a core structure falls.
function M.resolveCommit(lanes, town)
	local results, conquered = {}, false
	for id, cards in pairs(lanes) do
		local structure = town.structures[id]
		local result = M.resolveLane(cards, structure)
		results[id] = result
		if structure.core and result.destroyed then
			conquered = true
		end
	end
	return { results = results, conquered = conquered }
end

return M
