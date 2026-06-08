-- Town definitions. Each builder returns a FRESH, mutable town instance (cloned
-- from structures.lua templates) so a siege (and restart) can flip per-structure
-- `destroyed`/`def` without leaking state. Structures are an ordered array; their
-- array index is the lane/structure id the resolver keys on; `core = true` marks
-- the Town Core. `fightBack` is the town's predetermined sculpt-phase rule.
local Structures = require("src.data.structures")

local M = {}

function M.frontier()
	local t = Structures.templates
	return {
		name = "Brackenford Outpost",
		structures = {
			Structures.clone(t.woodWall),
			Structures.clone(t.ironGate),
			Structures.clone(t.stoneTower),
			Structures.clone(t.townCore),
		},
		fightBack = { kind = "chipHP", amount = 2 },
	}
end

return M
