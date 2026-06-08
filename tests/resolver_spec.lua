-- Plain-Lua asserts for the pure siege resolver. No love.*.
-- Run from the repo root with `lua tests/resolver_spec.lua` (or via the
-- headless-LOVE harness build.ps1/Makefile set up). Exits non-zero on failure.

package.path = package.path .. ";./?.lua;./?/init.lua"

local R = require("src.combat.resolver")
local Cards = require("src.data.cards")

-- Cards with abilities stripped, so these test the pure scoring math in isolation
-- (monster abilities have their own asserts in abilities_spec.lua).
local function card(suit, rank)
	local c = Cards.new(suit, rank, "Physical")
	c.ability = nil
	return c
end

local failures = 0
local function check(ok, msg)
	if ok then
		print("ok: " .. msg)
	else
		failures = failures + 1
		print("FAIL: " .. msg)
	end
end

-- 1.3.2 - each combo tier's kind + mult.
local tiers = {
	{ "high", 1, { card("Clubs", "5") } },
	{ "pair", 2, { card("Clubs", "5"), card("Hearts", "5") } },
	{ "three", 3, { card("Clubs", "5"), card("Hearts", "5"), card("Spades", "5") } },
	{
		"straight",
		4,
		{ card("Clubs", "5"), card("Hearts", "6"), card("Spades", "7"), card("Diamonds", "8"), card("Clubs", "9") },
	},
	{
		"flush",
		5,
		{ card("Clubs", "2"), card("Clubs", "5"), card("Clubs", "7"), card("Clubs", "9"), card("Clubs", "J") },
	},
	{
		"fullhouse",
		6,
		{ card("Clubs", "5"), card("Hearts", "5"), card("Spades", "5"), card("Diamonds", "8"), card("Clubs", "8") },
	},
	{ "four", 7, { card("Clubs", "5"), card("Hearts", "5"), card("Spades", "5"), card("Diamonds", "5") } },
	{
		"straightflush",
		8,
		{ card("Clubs", "5"), card("Clubs", "6"), card("Clubs", "7"), card("Clubs", "8"), card("Clubs", "9") },
	},
}
for _, t in ipairs(tiers) do
	local combo = R.evaluateCombo(t[3])
	check(combo.kind == t[1] and combo.mult == t[2], t[1] .. " -> mult " .. t[2])
end

-- rankSum.
check(R.rankSum({ card("Clubs", "10"), card("Hearts", "K") }) == 23, "rankSum 10+K = 23")

-- 1.3.3 - lane outcomes.
local wall = { hp = 3 }
check(R.resolveLane({ card("Clubs", "5") }, wall).destroyed == true, "1 low card clears HP-3 wall")
local overkill = R.resolveLane({ card("Spades", "K"), card("Hearts", "K") }, { hp = 14 })
check(overkill.attack == 52 and overkill.destroyed == true, "overkill: pair of K = 52 vs HP 14")
check(R.resolveLane({ card("Clubs", "2") }, { hp = 10 }).destroyed == false, "shortfall: 2 vs HP 10")

-- resolveCommit conquer / no-conquer.
local town = { structures = { { hp = 3 }, { hp = 14, core = true } } }
local win = R.resolveCommit({ [2] = { card("Spades", "K"), card("Hearts", "K") }, [1] = { card("Clubs", "5") } }, town)
check(win.conquered == true and win.results[1].destroyed == true, "commit: core falls -> conquered")
check(R.resolveCommit({ [2] = { card("Clubs", "2") } }, town).conquered == false, "commit: core stands -> not conquered")

-- 2.1.5-2.1.7 - element matchups, Frost DEF reduction, Poison ignore-resist.
local function el(suit, rank, element)
	local c = Cards.new(suit, rank, element)
	c.ability = nil
	return c
end
check(R.typeMultiplier("Fire", "Wood") == 2, "Fire vs Wood = x2")
check(R.typeMultiplier("Acid", "Iron") == 2, "Acid vs Iron = x2")
check(R.typeMultiplier("Physical", "Holy") == 2, "Physical vs Holy = x2")
check(R.typeMultiplier("Physical", "Iron") == 0.5, "Physical vs Iron = x0.5")
check(R.typeMultiplier("Fire", "Granite") == 1, "unknown material -> neutral")
-- Fire 5 vs Wood hp 8: 5 * 1 * 2 = 10 >= 8.
check(R.resolveLane({ el("Clubs", "5", "Fire") }, { hp = 8, material = "Wood" }).attack == 10, "Fire x2 attack")
-- Frost lowers effective hp: two Frost cards remove 4 hp (frostDefPerCard 2).
local frosted = R.resolveLane({ el("Hearts", "6", "Frost"), el("Spades", "6", "Frost") }, { hp = 14, material = "Iron" })
check(frosted.hp == 10, "Frost reduces effective HP 14 -> 10")
-- Poison ignores the x0.5 resist (Physical vs Iron) -> treated as x1.
local poisoned = R.resolveLane({ el("Spades", "8", "Physical"), el("Clubs", "4", "Poison") }, { hp = 5, material = "Iron" })
check(poisoned.type == 1, "Poison ignores the x0.5 resist case")
-- dominantElement: majority wins, ties resolve by priority (Fire before Frost).
check(R.dominantElement({ el("Clubs", "2", "Fire"), el("Clubs", "3", "Frost") }) == "Fire", "dominant tie -> priority")

-- 2.7.x - combat depth.
-- Armor: attack 10 - armor 3 = damage 7 vs hp 6 -> destroyed; damage field exact.
local armored = R.resolveLane({ el("Clubs", "5", "Fire") }, { hp = 6, material = "Wood", armor = 3 })
check(armored.damage == 7 and armored.destroyed == true, "armor reduces damage 10 -> 7")
-- High armor blocks a small lane.
check(R.resolveLane({ card("Clubs", "5") }, { hp = 3, armor = 9 }).destroyed == false, "armor 9 blocks attack 5")
-- Ward halves the warded element (Fire 10 -> type x1 -> 5).
local warded = R.resolveLane({ el("Clubs", "5", "Fire") }, { hp = 6, material = "Wood", keywords = { ward = "Fire" } })
check(warded.attack == 5, "Ward Fire halves Fire x2 -> x1")
-- Shield blocks while a front structure stands (opts.shieldActive).
local shielded = R.resolveLane({ card("Spades", "K"), card("Hearts", "K") }, { hp = 5, keywords = { shield = true } }, { shieldActive = true })
check(shielded.destroyed == false and shielded.shielded == true, "Shield blocks while front stands")
-- Gamble order: (attack + die) * coin. base 5, +3 die, x1.5 coin = 12.
local gambled = R.resolveLane({ card("Clubs", "5") }, { hp = 1 }, { bonusAdd = 3, bonusMult = 1.5 })
check(gambled.attack == 12, "gamble (5+3)*1.5 = 12")
-- Thorns reported for siege to apply.
check(R.resolveLane({ card("Clubs", "5") }, { hp = 3, keywords = { thorns = 2 } }).thorns == 2, "Thorns reported")

print(failures == 0 and "PASS: all resolver specs" or ("FAILED: " .. failures .. " spec(s)"))
os.exit(failures > 0 and 1 or 0)
