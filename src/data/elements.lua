-- The 5 elements: 3 damage (Fire/Acid/Physical) + 2 utility (Frost/Poison).
-- Pure data; the matchup numbers live in matchups.lua. (see GAME_DESIGN.)
local M = {}

M.damage = { "Fire", "Acid", "Physical" }
M.utility = { "Frost", "Poison" }

-- Tie-break order for dominantElement when counts are equal (damage first).
M.priority = { "Fire", "Acid", "Physical", "Frost", "Poison" }

-- Frost (utility) lowers a target's DEF before the compare; per Frost card. (tuning)
M.frostDefPerCard = 2

return M
