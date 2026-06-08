local Gamestate = require("lib.hump.gamestate")

local M = {}

function M:enter(previous) end
function M:update(dt) end

function M:draw()
	love.graphics.clear(0.07, 0.09, 0.08)
	love.graphics.print("Siege resolved (skeleton)", 24, 24)
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
