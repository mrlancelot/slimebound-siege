-- The deck: build a draw pile from a card list, seeded shuffle, draw to hand size.
-- Pure: no love.* so it loads under plain lua for tests.
local Rng = require("src.core.rng")

local M = {}
M.HAND_SIZE = 7

-- Build a fresh deck (shallow-copy the card list so the source is untouched).
function M.build(cards)
	local pile = {}
	for i, card in ipairs(cards) do
		pile[i] = card
	end
	return { draw = pile, hand = {}, discard = {} }
end

-- Fisher-Yates shuffle of the draw pile using a seeded RNG.
function M.shuffle(deck, seed)
	local rng = Rng.new(seed)
	local pile = deck.draw
	for i = #pile, 2, -1 do
		local j = rng:random(i)
		pile[i], pile[j] = pile[j], pile[i]
	end
	return deck
end

-- Draw up to n cards (default the hand size) off the top of the draw pile.
function M.draw(deck, n)
	n = n or M.HAND_SIZE
	for _ = 1, n do
		local card = table.remove(deck.draw)
		if not card then
			break
		end
		deck.hand[#deck.hand + 1] = card
	end
	return deck.hand
end

-- Put a card onto the discard pile (used when exchanging/tossing during sculpt).
function M.discard(deck, card)
	deck.discard[#deck.discard + 1] = card
end

-- Move the discard pile back into the draw pile and shuffle it (seeded).
function M.reshuffle(deck, seed)
	for i = #deck.discard, 1, -1 do
		deck.draw[#deck.draw + 1] = deck.discard[i]
		deck.discard[i] = nil
	end
	return M.shuffle(deck, seed)
end

-- Draw a single card, reshuffling the discard back in if the draw pile is empty.
-- Returns the card (or nil if both piles are exhausted).
function M.drawOne(deck, seed)
	if #deck.draw == 0 then
		M.reshuffle(deck, seed)
	end
	return table.remove(deck.draw)
end

return M
