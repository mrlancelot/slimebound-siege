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

return M
