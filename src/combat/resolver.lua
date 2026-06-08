-- The pure siege resolver: scores poker-combo lanes against structures.
-- PURE by contract: no love.* and no globals, so it unit-tests under plain lua.
-- attack = rankSum x combo-mult x type-mult; a structure falls when attack >= def.
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

-- Score one lane vs one structure. type-mult is stubbed to 1 here; the real
-- element/material multiplier (and Frost/Poison) arrive in M2.1.
function M.resolveLane(cards, structure)
	local combo = M.evaluateCombo(cards)
	local typeMult = 1
	local attack = combo.rankSum * combo.mult * typeMult
	return {
		attack = attack,
		destroyed = attack >= structure.def,
		combo = combo,
		type = typeMult,
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
