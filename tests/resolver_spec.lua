-- Plain-Lua asserts for the pure siege resolver. No love.*.
-- Run from the repo root with `lua tests/resolver_spec.lua` (or via the
-- headless-LOVE harness build.ps1/Makefile set up). Exits non-zero on failure.

package.path = package.path .. ";./?.lua;./?/init.lua"

local R = require("src.combat.resolver")
local Cards = require("src.data.cards")

local function card(suit, rank)
	return Cards.new(suit, rank, "Physical")
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
local wall = { def = 3 }
check(R.resolveLane({ card("Clubs", "5") }, wall).destroyed == true, "1 low card clears DEF-3 wall")
local overkill = R.resolveLane({ card("Spades", "K"), card("Hearts", "K") }, { def = 14 })
check(overkill.attack == 52 and overkill.destroyed == true, "overkill: pair of K = 52 vs DEF 14")
check(R.resolveLane({ card("Clubs", "2") }, { def = 10 }).destroyed == false, "shortfall: 2 vs DEF 10")

-- resolveCommit conquer / no-conquer.
local town = { structures = { { def = 3 }, { def = 14, core = true } } }
local win = R.resolveCommit({ [2] = { card("Spades", "K"), card("Hearts", "K") }, [1] = { card("Clubs", "5") } }, town)
check(win.conquered == true and win.results[1].destroyed == true, "commit: core falls -> conquered")
check(R.resolveCommit({ [2] = { card("Clubs", "2") } }, town).conquered == false, "commit: core stands -> not conquered")

-- 2.1.5-2.1.7 - element matchups, Frost DEF reduction, Poison ignore-resist.
local function el(suit, rank, element)
	return Cards.new(suit, rank, element)
end
check(R.typeMultiplier("Fire", "Wood") == 2, "Fire vs Wood = x2")
check(R.typeMultiplier("Acid", "Iron") == 2, "Acid vs Iron = x2")
check(R.typeMultiplier("Physical", "Holy") == 2, "Physical vs Holy = x2")
check(R.typeMultiplier("Physical", "Iron") == 0.5, "Physical vs Iron = x0.5")
check(R.typeMultiplier("Fire", "Granite") == 1, "unknown material -> neutral")
-- Fire 5 vs Wood DEF 8: 5 * 1 * 2 = 10 >= 8.
check(R.resolveLane({ el("Clubs", "5", "Fire") }, { def = 8, material = "Wood" }).attack == 10, "Fire x2 attack")
-- Frost lowers effective DEF: two Frost cards remove 4 DEF (frostDefPerCard 2).
local frosted = R.resolveLane({ el("Hearts", "6", "Frost"), el("Spades", "6", "Frost") }, { def = 14, material = "Iron" })
check(frosted.def == 10, "Frost reduces effective DEF 14 -> 10")
-- Poison ignores the x0.5 resist (Physical vs Iron) -> treated as x1.
local poisoned = R.resolveLane({ el("Spades", "8", "Physical"), el("Clubs", "4", "Poison") }, { def = 5, material = "Iron" })
check(poisoned.type == 1, "Poison ignores the x0.5 resist case")
-- dominantElement: majority wins, ties resolve by priority (Fire before Frost).
check(R.dominantElement({ el("Clubs", "2", "Fire"), el("Clubs", "3", "Frost") }) == "Fire", "dominant tie -> priority")

print(failures == 0 and "PASS: all resolver specs" or ("FAILED: " .. failures .. " spec(s)"))
os.exit(failures > 0 and 1 or 0)
