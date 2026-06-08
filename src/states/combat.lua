local Gamestate = require("lib.hump.gamestate")

local M = {}

function M:enter(previous) end
function M:update(dt) end

function M:draw()
	love.graphics.clear(0.08, 0.07, 0.1)
	love.graphics.print("Siege in progress (skeleton)", 24, 24)
	love.graphics.print("Press Enter to resolve.   Esc to retreat.", 24, 56)
end

function M:keypressed(key)
	if key == "return" then
		Gamestate.switch(require("src.states.result"))
	elseif key == "escape" then
		Gamestate.switch(require("src.states.menu"))
	end
end

return M
