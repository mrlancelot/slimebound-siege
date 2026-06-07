local Game = require("src.game")

local game

function love.load(args)
	love.graphics.setDefaultFilter("nearest", "nearest")
	game = Game.new(args)
end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	game:draw()
end

function love.keypressed(key, scancode, isrepeat)
	game:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
	game:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
	game:mousepressed(x, y, button, istouch, presses)
end

function love.resize(width, height)
	game:resize(width, height)
end
