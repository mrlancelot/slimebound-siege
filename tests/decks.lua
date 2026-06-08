-- The full 52-card vocabulary generator + a tiny fixed deck, for tests and debug.
-- Pure data: no love.*, safe to require from plain lua.
local Cards = require("src.data.cards")

local M = {}

local SUITS = { "Clubs", "Spades", "Hearts", "Diamonds" }
local RANKS = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" }

-- Every suit x rank combination (52 cards), each Physical by default.
function M.vocabulary()
	local cards = {}
	for _, suit in ipairs(SUITS) do
		for _, rank in ipairs(RANKS) do
			cards[#cards + 1] = Cards.new(suit, rank, "Physical")
		end
	end
	return cards
end

-- A small deterministic deck for resolver/deck tests.
M.testDeck = {
	Cards.new("Clubs", "5", "Fire"),
	Cards.new("Clubs", "5", "Acid"),
	Cards.new("Spades", "K", "Physical"),
	Cards.new("Hearts", "9", "Frost"),
	Cards.new("Diamonds", "2", "Poison"),
}

return M
