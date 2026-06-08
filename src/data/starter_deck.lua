-- The explicit 16-card starting deck (M2.5 tuning starting point): 4 Goblins,
-- 4 Brutes, 4 Slimes, 3 Casters, 1 Slime Core; elements spread across all five.
-- `build()` returns FRESH card instances each call (a siege may mutate cards,
-- e.g. the `wound` fight-back rule), so never share the result between sieges.
local Cards = require("src.data.cards")

-- { suit, rank, element } per card.
local LIST = {
	-- Goblins (Clubs)
	{ "Clubs", "3", "Fire" },
	{ "Clubs", "5", "Physical" },
	{ "Clubs", "6", "Acid" },
	{ "Clubs", "8", "Poison" },
	-- Brutes (Spades)
	{ "Spades", "4", "Physical" },
	{ "Spades", "6", "Fire" },
	{ "Spades", "7", "Acid" },
	{ "Spades", "9", "Frost" },
	-- Slimes (Hearts)
	{ "Hearts", "2", "Frost" },
	{ "Hearts", "4", "Poison" },
	{ "Hearts", "6", "Physical" },
	{ "Hearts", "8", "Acid" },
	-- Casters (Diamonds)
	{ "Diamonds", "3", "Frost" },
	{ "Diamonds", "5", "Fire" },
	{ "Diamonds", "7", "Poison" },
	-- Slime Core (wild Ace)
	{ "Hearts", "A", "Physical" },
}

local M = {}

function M.build()
	local cards = {}
	for i, c in ipairs(LIST) do
		cards[i] = Cards.new(c[1], c[2], c[3])
	end
	return cards
end

return M
