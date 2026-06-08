local Gamestate = require("lib.hump.gamestate")
local Menu = require("src.states.menu")

local Game = {}

function Game.load(args)
	love.graphics.setDefaultFilter("nearest", "nearest")
	Gamestate.registerEvents()
	Gamestate.switch(Menu, args)
end

return Game
