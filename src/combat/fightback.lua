-- Town fights back: one predetermined rule fired each sculpt turn. Data-driven -
-- `kind -> handler(siege, rule)`; new rules are a new row + a handler. PURE (no
-- love.*). The town carries `fightBack = { kind = ..., amount/suit = ... }`.
local M = {}

local function firstOpen(siege)
	for id, s in ipairs(siege.town.structures) do
		if not s.destroyed and not s.core then
			return id, s
		end
	end
	return nil
end

M.handlers = {
	-- Reinforce a structure's DEF before the commit.
	reinforce = function(siege, rule)
		local _, s = firstOpen(siege)
		s = s or siege.town.structures[#siege.town.structures]
		s.def = s.def + (rule.amount or 2)
	end,

	-- Lock a suit: cards of that suit can't be committed; drop any already assigned.
	lockSuit = function(siege, rule)
		siege.lockedSuit = rule.suit
		for _, card in ipairs(siege.hand) do
			if card.suit == rule.suit then
				require("src.combat.siege").unassign(siege, card)
			end
		end
	end,

	-- Wound the strongest card in hand (reduce its rank value, floor 2).
	wound = function(siege, rule)
		local target
		for _, card in ipairs(siege.hand) do
			if not target or card.value > target.value then
				target = card
			end
		end
		if target then
			target.value = math.max(2, target.value - (rule.amount or 2))
			if target.value <= 10 then
				target.rank = tostring(target.value)
			end
		end
	end,

	-- Chip the slime's expedition HP.
	chipHP = function(siege, rule)
		siege.expeditionHP = siege.expeditionHP - (rule.amount or 2)
	end,
}

function M.apply(siege)
	local rule = siege.town.fightBack
	local handler = rule and M.handlers[rule.kind]
	if handler then
		handler(siege, rule)
	end
end

return M
