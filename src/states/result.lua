local Gamestate = require("lib.hump.gamestate")
local Theme = require("src.ui.theme")

local M = {}

-- `info` is the siege outcome table from CombatState (conquered/outcome/loot/hp).
function M:enter(previous, info)
	self.info = info or {}
end
function M:update(dt) end

function M:draw()
	local info = self.info
	Theme.set("bg")
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	if info.conquered then
		Theme.set("success")
		love.graphics.print("VICTORY - the Town Core falls. The town is conquered!", 24, 24)
	elseif info.outcome == "retreat" then
		Theme.set("danger")
		love.graphics.print("RETREAT - the slime is spent; the siege is broken.", 24, 24)
	else
		Theme.set("danger")
		love.graphics.print("SHORTFALL - the Core holds; the slime takes the hit.", 24, 24)
	end

	Theme.set("text")
	if info.loot then
		love.graphics.print("Bonus loot:  +" .. (info.loot.gold or 0) .. " gold", 24, 56)
	end
	if info.hp then
		love.graphics.print(string.format("Expedition HP: %d/%d", info.hp, info.maxHP or info.hp), 24, 78)
	end

	Theme.set("muted")
	love.graphics.print("Press R to besiege again.   Esc for menu.", 24, 116)
end

function M:keypressed(key)
	if key == "r" then
		Gamestate.switch(require("src.states.combat"))
	elseif key == "escape" then
		Gamestate.switch(require("src.states.menu"))
	end
end

return M
