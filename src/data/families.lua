-- Suit -> monster family map and rank-value table (see MONSTERS.md).
-- Pure data: no love.* so it loads under plain lua for tests.
local M = {}

-- Suit decides the monster family / ability style (not its element).
M.families = {
	Clubs = "Goblins",
	Spades = "Brutes",
	Hearts = "Slimes",
	Diamonds = "Casters",
}

-- Rank label -> the value summed in a combo.
M.rankValues = {
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["8"] = 8,
	["9"] = 9,
	["10"] = 10,
	J = 11,
	Q = 12,
	K = 13,
	A = 14,
}

return M
