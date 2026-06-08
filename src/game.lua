local Gamestate = require("lib.hump.gamestate")
local Menu = require("src.states.menu")
local Theme = require("src.ui.theme")

local Game = {}

function Game.load(args)
	love.graphics.setDefaultFilter("nearest", "nearest")
	Theme.applyFont(16)
	Gamestate.registerEvents()
	Gamestate.switch(Menu, args)
end

return Game
