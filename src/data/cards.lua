-- Card factory. A card is one monster described by three independent things:
-- suit (family), rank (power), and element (matchup tag). monsterType is filled in
-- later (M3). `value` is the numeric rank the resolver sums.
local Families = require("src.data.families")
local Monsters = require("src.data.monsters")

local M = {}

function M.new(suit, rank, element, monsterType)
	local value = Families.rankValues[rank]
	local mt = Monsters.forValue(suit, value)
	return {
		suit = suit,
		rank = rank,
		value = value,
		element = element,
		monsterType = monsterType or (mt and mt.name),
		ability = mt and mt.ability,
	}
end

return M
