local Gamestate = require("lib.hump.gamestate")

local M = {}

function M:enter(previous) end
function M:update(dt) end

function M:draw()
	love.graphics.clear(0.07, 0.08, 0.08)
	love.graphics.print("Slimebound Siege", 24, 24)
	love.graphics.print("Press Enter to lay siege.   Esc to quit.", 24, 56)
end

function M:keypressed(key)
	if key == "return" then
		Gamestate.switch(require("src.states.combat"))
	elseif key == "escape" then
		love.event.quit()
	end
end

return M
