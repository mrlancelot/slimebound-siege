-- Structure templates `{name, hp, armor, material, element, keywords}`. Towns clone
-- these into fresh mutable instances (hp/destroyed change during a siege). The Core
-- is the back-most, highest-HP target; destroying it conquers the town.
--   hp     = damage pool to deplete
--   armor  = flat reduction: damage = max(0, attack - armor)
local M = {}

-- Flat armor by material (tuning). Used when a template omits an explicit armor.
M.materialArmor = {
	Wood = 1,
	Iron = 2,
	Stone = 3,
	Ice = 1,
	Holy = 2,
}

M.templates = {
	woodWall = { name = "Wood Wall", hp = 3, material = "Wood" },
	ironGate = { name = "Iron Gate", hp = 6, material = "Iron" },
	stoneTower = { name = "Stone Tower", hp = 9, material = "Stone" },
	townCore = { name = "Town Core", hp = 14, material = "Holy", core = true },
}

-- Shallow copy of a template, filling in material armor if none was set.
function M.clone(t)
	local c = {}
	for k, v in pairs(t) do
		c[k] = v
	end
	c.armor = c.armor or M.materialArmor[c.material] or 0
	return c
end

return M
