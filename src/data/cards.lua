-- Card factory. A card is one monster described by three independent things:
-- suit (family), rank (power), and element (matchup tag). monsterType is filled in
-- later (M3). `value` is the numeric rank the resolver sums.
local Families = require("src.data.families")

local M = {}

function M.new(suit, rank, element, monsterType)
	return {
		suit = suit,
		rank = rank,
		value = Families.rankValues[rank],
		element = element,
		monsterType = monsterType,
	}
end

return M
