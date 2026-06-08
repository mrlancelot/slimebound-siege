local Gamestate = require("lib.hump.gamestate")

local M = {}

function M:enter(previous, won)
	self.won = won
end
function M:update(dt) end

function M:draw()
	love.graphics.clear(0.07, 0.09, 0.08)
	love.graphics.print(
		self.won and "VICTORY - the Town Core falls. The town is conquered!"
			or "DEFEAT - out of options; the siege is broken.",
		24,
		24
	)
	love.graphics.print("Press R to besiege again.   Esc for menu.", 24, 56)
end

function M:keypressed(key)
	if key == "r" then
		Gamestate.switch(require("src.states.combat"))
	elseif key == "escape" then
		Gamestate.switch(require("src.states.menu"))
	end
end

return M
