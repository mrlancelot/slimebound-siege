-- Plain-Lua asserts for M3 monster abilities (one per ability kind) + Imp split.
-- Run from the repo root with `lua tests/abilities_spec.lua` (or the LOVE harness).
package.path = package.path .. ";./?.lua;./?/init.lua"

local R = require("src.combat.resolver")
local Cards = require("src.data.cards")
local Monsters = require("src.data.monsters")
local Siege = require("src.combat.siege")
local Deck = require("src.core.deck")
local Towns = require("src.data.towns")
local Starter = require("src.data.starter_deck")

local failures = 0
local function check(ok, msg)
	print((ok and "ok: " or "FAIL: ") .. msg)
	if not ok then
		failures = failures + 1
	end
end

local function mk(suit, rank, el) -- card WITH its band ability
	return Cards.new(suit, rank, el or "Physical")
end
local function plain(suit, rank, el) -- card with its ability stripped
	local c = mk(suit, rank, el)
	c.ability = nil
	return c
end
local function lane(cards, structure, opts) -- resolveLane helper
	return R.resolveLane(cards, structure, opts)
end
local function bigTown(n)
	local s = {}
	for i = 1, n do
		s[i] = { hp = 100 }
	end
	return { structures = s }
end

-- Clubs
check(lane({ mk("Clubs", "2"), plain("Clubs", "3") }, { hp = 1 }).attack == 6, "Runt: +1 per other Goblin")
check(lane({ mk("Clubs", "4") }, { hp = 1 }).attack == 9, "Sneak: +5 if alone")
check(lane({ mk("Clubs", "6"), plain("Clubs", "2") }, { hp = 1 }).attack == 11, "Raider: +3 with 2+ Clubs")
do
	local town = bigTown(2)
	local res = R.resolveCommit({ [1] = { plain("Hearts", "5"), plain("Hearts", "5") }, [2] = { mk("Clubs", "8") } }, town)
	check(res.results[1].attack == 30, "Pack-leader: pairs in commit +1 mult")
end
do
	local res = R.resolveCommit({ [1] = { mk("Clubs", "J") }, [2] = { plain("Clubs", "2"), plain("Clubs", "3") } }, bigTown(2))
	check(res.results[1].attack == 33, "Boss: +1 mult per other Club in commit")
end
do
	local flush = { plain("Clubs", "2"), plain("Clubs", "5"), plain("Clubs", "7"), plain("Clubs", "9"), plain("Clubs", "10") }
	local res = R.resolveCommit({ [1] = flush, [2] = { mk("Clubs", "K") } }, bigTown(2))
	check(res.results[1].attack == 330, "Khan: flush lanes deal double")
end

-- Spades
check(lane({ mk("Spades", "2") }, { hp = 1, material = "Wood" }).attack == 4, "Orcling: +2 vs Wood")
check(lane({ mk("Spades", "4") }, { hp = 1, armor = 3 }).damage == 3, "Orc Grunt: ignores 2 armor")
check(lane({ mk("Spades", "8") }, { hp = 1, material = "Wood" }).attack == 12, "Ogre: +50% vs Wall/Gate")
check(lane({ mk("Spades", "9") }, { hp = 1 }).heal == 2, "Troll: heal 2 on destroy")
check(lane({ mk("Spades", "J") }, { hp = 1 }).attack == 22, "Berserker: +1 mult per 6 rank")
check(lane({ mk("Spades", "K") }, { hp = 1, core = true }).attack == 26, "War Brute: x2 vs Core")

-- Hearts
check(lane({ mk("Hearts", "5") }, { hp = 10 }).hp == 8, "Slime Spitter: -2 target HP")
check(lane({ mk("Hearts", "7") }, { hp = 1, armor = 5 }).damage == 7, "Hex Slime: ignore armor")
check(lane({ mk("Hearts", "9") }, { hp = 1 }).attack == 18, "Greater Slime: counts as a pair")
check(lane({ mk("Hearts", "J"), plain("Spades", "10") }, { hp = 1 }).attack == 40, "Slime Familiar: copies highest rank -> pair")
do
	-- wild Slime Core pairs with a 7: two 7s -> pair, rankSum 14, mult 2 = 28
	local res = lane({ mk("Hearts", "A"), plain("Spades", "7") }, { hp = 1 })
	check(res.attack == 28, "Slime Core: wild forms a pair")
end

-- Diamonds
do
	local res = R.resolveCommit({ [1] = { mk("Diamonds", "5") }, [2] = { plain("Diamonds", "2"), plain("Diamonds", "3") } }, bigTown(2))
	check(res.results[1].attack == 20, "Acolyte: +1 mult per Caster in commit")
end
check(lane({ mk("Diamonds", "7") }, { hp = 1 }).attack == 21, "Shaman: +2 mult to its lane")
check(lane({ mk("Diamonds", "J") }, { hp = 20 }).hp == 15, "Frost Mage: -5 target HP")
check(lane({ mk("Diamonds", "K") }, { hp = 1, core = true }).attack == 26, "Wyvern: x2 vs Core")
do
	-- Dragonkin overkill carries to the next surviving non-core structure.
	local town = { structures = { { hp = 2 }, { hp = 2 }, { hp = 100, core = true } } }
	R.resolveCommit({ [1] = { mk("Diamonds", "9") } }, town)
	check(town.structures[2].destroyed == true, "Dragonkin: overkill carries to next structure")
end

-- Merged (data rows reuse the kinds)
do
	local hob = plain("Clubs", "5")
	hob.ability = Monsters.merged.Hobgoblin.ability
	check(lane({ hob }, { hp = 1 }).attack == 20, "Hobgoblin: counts as two cards (pair)")
end
do
	local so = plain("Spades", "8")
	so.ability = Monsters.merged["Stone Ogre"].ability
	check(lane({ so }, { hp = 1 }).attack == 12, "Stone Ogre: +50% vs all")
end
do
	local hx = plain("Hearts", "6")
	hx.ability = Monsters.merged["Hex Slime"].ability
	local res = lane({ hx }, { hp = 10, armor = 5 })
	check(res.hp == 7 and res.armor == 0, "Hex Slime merge: -3 HP + ignore armor")
end

-- Imp multi-lane (the headline done-when)
do
	local s = Siege.new(Deck.shuffle(Deck.build(Starter.build()), 1337), Towns.frontier(), { seed = 3 })
	local imp = mk("Diamonds", "2")
	s.hand[#s.hand + 1] = imp
	local a = Siege.assign(s, imp, 1)
	local b = Siege.assign(s, imp, 2)
	local c = Siege.assign(s, imp, 3)
	check(a and b and #s.assigned[imp] == 2 and not c, "Imp: splits into two lanes (not three)")
	check(s.lanes[1][#s.lanes[1]] == imp and s.lanes[2][#s.lanes[2]] == imp, "Imp: present in both lanes")
end

print(failures == 0 and "PASS: all ability specs" or ("FAILED: " .. failures .. " spec(s)"))
os.exit(failures > 0 and 1 or 0)
