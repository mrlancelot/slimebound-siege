-- Structure templates `{name, def, material, element, rule}`. Towns clone these
-- into fresh mutable instances (def/destroyed change during a siege). The Core is
-- just the highest-DEF target; destroying it conquers the town.
local M = {}

M.templates = {
	woodWall = { name = "Wood Wall", def = 3, material = "Wood" },
	ironGate = { name = "Iron Gate", def = 6, material = "Iron" },
	stoneTower = { name = "Stone Tower", def = 9, material = "Stone" },
	townCore = { name = "Town Core", def = 14, material = "Holy", core = true },
}

-- Shallow copy of a template so a siege can mutate it without touching the table.
function M.clone(t)
	local c = {}
	for k, v in pairs(t) do
		c[k] = v
	end
	return c
end

return M
