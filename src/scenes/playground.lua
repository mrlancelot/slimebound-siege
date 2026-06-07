local Playground = {}
Playground.__index = Playground

local COLORS = {
	background = { 0.07, 0.08, 0.08 },
	text = { 0.96, 0.95, 0.9 },
	muted = { 0.66, 0.72, 0.7 },
	accent = { 0.45, 0.78, 0.52 },
	dim = { 0.16, 0.2, 0.19 },
}

local function setColor(color)
	love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
end

function Playground.new()
	return setmetatable({}, Playground)
end

function Playground:enter()
	self.font = love.graphics.newFont(14)
	self.titleFont = love.graphics.newFont(24)
	self.headingFont = love.graphics.newFont(18)
end

function Playground:draw()
	love.graphics.clear(COLORS.background[1], COLORS.background[2], COLORS.background[3], COLORS.background[4] or 1)

	setColor(COLORS.text)
	love.graphics.setFont(self.titleFont)
	love.graphics.print("Slimebound Siege", 24, 24)

	love.graphics.setFont(self.headingFont)
	love.graphics.print("Design documentation phase", 24, 64)

	setColor(COLORS.muted)
	love.graphics.setFont(self.font)
	love.graphics.print("The old prototype has been removed.", 24, 98)
	love.graphics.print("Current source of truth: docs/GAME_DESIGN.md", 24, 122)
	love.graphics.print("Press Esc to quit.", 24, 146)

	setColor(COLORS.dim)
	love.graphics.rectangle("fill", 24, 190, 360, 2)

	setColor(COLORS.accent)
	love.graphics.print("Next step: plan the first vertical slice from the design bible.", 24, 214)
end

return Playground
