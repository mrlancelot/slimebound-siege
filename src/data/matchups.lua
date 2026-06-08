-- Element x material type multiplier (strong 2.0 / neutral 1.0 / resist 0.5).
-- The 5x5 table from GAME_DESIGN. Frost/Poison are utility: mostly neutral, with
-- their real effects (DEF reduction / ignore-resist) handled in the resolver.
-- Any element/material not listed defaults to 1.0 (see resolver.typeMultiplier).
local M = {
	Fire = { Wood = 2, Iron = 1, Stone = 1, Ice = 2, Holy = 1 },
	Acid = { Wood = 1, Iron = 2, Stone = 2, Ice = 1, Holy = 0.5 },
	Physical = { Wood = 1, Iron = 0.5, Stone = 0.5, Ice = 1, Holy = 2 },
	Frost = { Wood = 1, Iron = 1, Stone = 1, Ice = 0.5, Holy = 1 },
	Poison = { Wood = 1, Iron = 1, Stone = 1, Ice = 1, Holy = 0.5 },
}

return M
