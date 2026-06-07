local Playground = require("src.scenes.playground")

local Game = {}
Game.__index = Game

function Game.new(args)
	local self = setmetatable({}, Game)
	self.args = args or {}
	self.scene = Playground.new()
	self.scene:enter()
	return self
end

function Game:update(dt)
	if self.scene.update then
		self.scene:update(dt)
	end
end

function Game:draw()
	self.scene:draw()
end

function Game:keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
		return
	end

	if self.scene.keypressed then
		self.scene:keypressed(key, scancode, isrepeat)
	end
end

function Game:keyreleased(key, scancode)
	if self.scene.keyreleased then
		self.scene:keyreleased(key, scancode)
	end
end

function Game:mousepressed(x, y, button, istouch, presses)
	if self.scene.mousepressed then
		self.scene:mousepressed(x, y, button, istouch, presses)
	end
end

function Game:resize(width, height)
	if self.scene.resize then
		self.scene:resize(width, height)
	end
end

return Game
