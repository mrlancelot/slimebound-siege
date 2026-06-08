-- Town definitions. Each builder returns a FRESH, mutable town instance so a
-- siege (and restart) can flip per-structure `destroyed` flags without leaking
-- state across runs. Structures are an ordered array; their array index is the
-- lane/structure id the resolver keys on, and `core = true` marks the Town Core.
local M = {}

function M.frontier()
	return {
		name = "Brackenford Outpost",
		structures = {
			{ name = "Outer Wall", def = 3, material = "Wood" },
			{ name = "Town Core", def = 14, material = "Holy", core = true },
		},
	}
end

return M
