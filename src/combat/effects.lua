-- Monster-ability effect handlers (M3). `effects[kind]` is a table of optional
-- hook functions the resolver calls during a lane:
--   preLane(ctx, card, p)     -- tweak cards / DEF / armor before the combo
--   mult(ctx, card, p)        -- add to combo mult (ctx.multAdd)
--   flat(ctx, card, p)        -- flat attack (ctx.flatAdd) / scale (ctx.attackScale)
--   postDestroy(ctx, card, p) -- on a kill: heal / overkill carry
-- ctx fields handlers read/write: cards, structure, combo, commit, flatAdd, multAdd,
-- attackScale, hpReduce, armorReduce, ignoreArmor, forcePair, heal, carry, result.
-- `sticky` (Slime) and `multiLane` (Imp/Hexling) are handled in siege.lua, not here.
-- PURE: no love.*.
local M = {}

local function countSuit(cards, suit, exclude)
	local n = 0
	for _, c in ipairs(cards) do
		if c ~= exclude and c.suit == suit then
			n = n + 1
		end
	end
	return n
end

M.armorReduce = {
	preLane = function(ctx, _, p)
		ctx.armorReduce = ctx.armorReduce + (p.amount or 0)
	end,
}
M.ignoreArmor = {
	preLane = function(ctx)
		ctx.ignoreArmor = true
	end,
}
M.hpReduce = {
	preLane = function(ctx, _, p)
		ctx.hpReduce = ctx.hpReduce + (p.amount or 0)
	end,
}
M.forcePair = {
	preLane = function(ctx)
		ctx.forcePair = true
	end,
}
-- Slime Familiar: copies the rank of the highest other card in its lane.
M.copyHighestRank = {
	preLane = function(ctx, card)
		local best = 0
		for _, c in ipairs(ctx.cards) do
			if c ~= card and c.value > best then
				best = c.value
			end
		end
		if best > 0 then
			card.value = best -- become the highest other card's rank
		end
	end,
}
-- Slime Core (wild): counts as the lane's most-common rank + suit (best-effort).
M.wild = {
	preLane = function(ctx, card)
		local rc, sc = {}, {}
		for _, c in ipairs(ctx.cards) do
			if c ~= card then
				rc[c.value] = (rc[c.value] or 0) + 1
				sc[c.suit] = (sc[c.suit] or 0) + 1
			end
		end
		local bestV, bv = card.value, 0
		for v, n in pairs(rc) do
			if n > bv then
				bv, bestV = n, v
			end
		end
		local bestS, bs = card.suit, 0
		for s, n in pairs(sc) do
			if n > bs then
				bs, bestS = n, s
			end
		end
		card.value, card.suit = bestV, bestS
	end,
}
-- Hobgoblin: counts as two cards for flush/straight (append an ability-less copy).
M.countsDouble = {
	preLane = function(ctx, card)
		local clone = {}
		for k, v in pairs(card) do
			clone[k] = v
		end
		clone.ability = nil
		ctx.cards[#ctx.cards + 1] = clone
	end,
}

M.multBonus = {
	mult = function(ctx, _, p)
		ctx.multAdd = ctx.multAdd + (p.amount or 0)
	end,
}
M.multPerRank6 = {
	mult = function(ctx)
		ctx.multAdd = ctx.multAdd + math.floor(ctx.combo.rankSum / 6)
	end,
}
M.multPerClubCommit = {
	mult = function(ctx)
		if ctx.commit then
			ctx.multAdd = ctx.multAdd + math.max(0, ctx.commit.clubs - 1)
		end
	end,
}
M.multPerCasterCommit = {
	mult = function(ctx)
		if ctx.commit then
			ctx.multAdd = ctx.multAdd + ctx.commit.casters
		end
	end,
}

M.flatPerOtherSuit = {
	flat = function(ctx, card, p)
		ctx.flatAdd = ctx.flatAdd + countSuit(ctx.cards, p.suit, card) * (p.per or 1)
	end,
}
M.flatIfAlone = {
	flat = function(ctx, _, p)
		if #ctx.cards == 1 then
			ctx.flatAdd = ctx.flatAdd + (p.amount or 0)
		end
	end,
}
M.flatIfSuitCount = {
	flat = function(ctx, _, p)
		if countSuit(ctx.cards, p.suit) >= (p.count or 2) then
			ctx.flatAdd = ctx.flatAdd + (p.amount or 0)
		end
	end,
}
M.flatVsMaterial = {
	flat = function(ctx, _, p)
		if ctx.structure.material == p.material then
			ctx.flatAdd = ctx.flatAdd + (p.amount or 0)
		end
	end,
}
M.scaleVsMaterials = {
	flat = function(ctx, _, p)
		if p.materials[ctx.structure.material] then
			ctx.attackScale = ctx.attackScale * (p.scale or 1)
		end
	end,
}
M.scaleVsCore = {
	flat = function(ctx, _, p)
		if ctx.structure.core then
			ctx.attackScale = ctx.attackScale * (p.scale or 1)
		end
	end,
}
M.scaleAll = {
	flat = function(ctx, _, p)
		ctx.attackScale = ctx.attackScale * (p.scale or 1)
	end,
}

M.healSlime = {
	postDestroy = function(ctx, _, p)
		ctx.heal = ctx.heal + (p.amount or 0)
	end,
}
M.overkillCarry = {
	postDestroy = function(ctx)
		ctx.carry = ctx.result.overkill
	end,
}

return M
