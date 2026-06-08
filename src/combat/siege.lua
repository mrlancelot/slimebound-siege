-- The siege: the mutable one-commit combat instance the UI drives and tests
-- exercise. PURE (no love.*) so it stays unit-testable. Wraps a deck + a town,
-- tracks the sculpt budget, lane assignment, locked suit, and expedition HP, and
-- resolves the commit through the pure resolver.
local Deck = require("src.core.deck")
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
	}
end

-- Remove a card from whatever lane it currently occupies.
function M.unassign(siege, card)
	local id = siege.assigned[card]
	if not id then
		return
	end
	local lane = siege.lanes[id]
	for i, c in ipairs(lane) do
		if c == card then
			table.remove(lane, i)
			break
		end
	end
	if #lane == 0 then
		siege.lanes[id] = nil
	end
	siege.assigned[card] = nil
end

-- Assign a hand card to a structure lane (any card -> any open structure). A card
-- occupies one lane; locked-suit or destroyed targets are rejected.
function M.assign(siege, card, structureId)
	local structure = siege.town.structures[structureId]
	if not structure or structure.destroyed then
		return false
	end
	if siege.lockedSuit and card.suit == siege.lockedSuit then
		return false
	end
	M.unassign(siege, card)
	siege.lanes[structureId] = siege.lanes[structureId] or {}
	local lane = siege.lanes[structureId]
	lane[#lane + 1] = card
	siege.assigned[card] = structureId
	return true
end

-- Exchange (toss + redraw) the given cards; costs from the 3-card sculpt budget.
function M.exchange(siege, cards)
	local n = #cards
	if n == 0 or n > siege.exchangesLeft then
		return false
	end
	for _, card in ipairs(cards) do
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

-- End a sculpt turn: the town fights back, then the turn counter drops.
function M.endSculpt(siege)
	if siege.sculptTurnsLeft <= 0 then
		return false
	end
	siege.sculptTurnsLeft = siege.sculptTurnsLeft - 1
	FightBack.apply(siege)
	return true
end

-- The pending lane breakdown for a structure (for the live UI readout).
function M.preview(siege, structureId)
	local lane = siege.lanes[structureId]
	if not lane or #lane == 0 then
		return nil
	end
	return Resolver.resolveLane(lane, siege.town.structures[structureId])
end

-- Commit every lane at once: apply destroyed flags, bonus loot, and the outcome.
function M.commit(siege)
	local resolved = Resolver.resolveCommit(siege.lanes, siege.town)
	local loot = { gold = 0, essence = 0 }
	for id, result in pairs(resolved.results) do
		if result.destroyed then
			local s = siege.town.structures[id]
			s.destroyed = true
			if not s.core then
				loot.gold = loot.gold + 10 -- bonus loot for non-core (tuning)
			end
		end
	end
	siege.gold = siege.gold + loot.gold
	siege.essence = siege.essence + loot.essence

	local outcome
	if resolved.conquered then
		outcome = "victory"
	else
		siege.expeditionHP = siege.expeditionHP - 10 -- shortfall damage (tuning)
		outcome = siege.expeditionHP <= 0 and "retreat" or "shortfall"
	end
	return { outcome = outcome, conquered = resolved.conquered, loot = loot, results = resolved.results }
end

return M
