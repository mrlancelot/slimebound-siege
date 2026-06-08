-- Monster types: suit + rank-value band -> { name, ability = { kind, params } }.
-- Abilities are commit-time lane modifiers; the resolver/siege dispatch them via
-- src/combat/effects.lua (see MONSTERS.md). Band overlaps in the doc are resolved
-- here into clean non-overlapping ranges. PURE data.
local M = {}

-- bands[suit] = ordered { minValue, maxValue, name, ability }
M.bands = {
	Clubs = {
		{ 2, 3, "Goblin Runt", { kind = "flatPerOtherSuit", params = { per = 1, suit = "Clubs" } } },
		{ 4, 5, "Goblin Sneak", { kind = "flatIfAlone", params = { amount = 5 } } },
		{ 6, 7, "Goblin Raider", { kind = "flatIfSuitCount", params = { amount = 3, suit = "Clubs", count = 2 } } },
		{ 8, 10, "Pack-leader", { kind = "pairsPlusMultCommit" } },
		{ 11, 12, "Goblin Boss", { kind = "multPerClubCommit" } },
		{ 13, 14, "Goblin Khan", { kind = "flushDoubleCommit" } },
	},
	Spades = {
		{ 2, 3, "Orcling", { kind = "flatVsMaterial", params = { amount = 2, material = "Wood" } } },
		{ 4, 6, "Orc Grunt", { kind = "armorReduce", params = { amount = 2 } } },
		{ 7, 8, "Ogre", { kind = "scaleVsMaterials", params = { scale = 1.5, materials = { Wood = true, Iron = true } } } },
		{ 9, 10, "Troll", { kind = "healSlime", params = { amount = 2 } } },
		{ 11, 12, "Berserker", { kind = "multPerRank6" } },
		{ 13, 14, "War Brute", { kind = "scaleVsCore", params = { scale = 2 } } },
	},
	Hearts = {
		{ 2, 4, "Slime", { kind = "sticky" } },
		{ 5, 6, "Slime Spitter", { kind = "hpReduce", params = { amount = 2 } } },
		{ 7, 8, "Hex Slime", { kind = "ignoreArmor" } },
		{ 9, 10, "Greater Slime", { kind = "forcePair" } },
		{ 11, 13, "Slime Familiar", { kind = "copyHighestRank" } },
		{ 14, 14, "Slime Core", { kind = "wild" } },
	},
	Diamonds = {
		{ 2, 4, "Imp", { kind = "multiLane", params = { lanes = 2 } } },
		{ 5, 6, "Acolyte", { kind = "multPerCasterCommit" } },
		{ 7, 8, "Shaman", { kind = "multBonus", params = { amount = 2 } } },
		{ 9, 10, "Dragonkin", { kind = "overkillCarry" } },
		{ 11, 12, "Frost Mage", { kind = "hpReduce", params = { amount = 5 } } },
		{ 13, 14, "Wyvern", { kind = "scaleVsCore", params = { scale = 2 } } },
	},
}

-- Merged monsters (M3.2.25 / M4.3 merge results). name -> { ability(ies) }.
-- `ability` may be a single { kind, params } or a list of them.
M.merged = {
	Hobgoblin = { ability = { kind = "countsDouble" } },
	["Stone Ogre"] = { ability = { kind = "scaleAll", params = { scale = 1.5 } } },
	["Greater Slime"] = { ability = { kind = "forcePair" } },
	Hexling = { ability = { { kind = "multiLane", params = { lanes = 2 } }, { kind = "multBonus", params = { amount = 1 } } } },
	["Ember Brute"] = {
		ability = {
			{ kind = "scaleVsMaterials", params = { scale = 1.5, materials = { Wood = true, Iron = true } } },
			{ kind = "overkillCarry" },
		},
	},
	["Hex Slime"] = { ability = { { kind = "hpReduce", params = { amount = 3 } }, { kind = "ignoreArmor" } } },
}

-- The monster type for a suit + rank value (nil if none matches).
function M.forValue(suit, value)
	local bands = M.bands[suit]
	if not bands then
		return nil
	end
	for _, b in ipairs(bands) do
		if value >= b[1] and value <= b[2] then
			return { name = b[3], ability = b[4] }
		end
	end
	return nil
end

return M
