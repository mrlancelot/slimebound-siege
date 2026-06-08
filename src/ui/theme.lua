-- The one palette table + helpers. UI reads all colors from here (presentation
-- over logic). Colors are hex strings; theme.hex(name) -> {r,g,b} in 0-1 for
-- love.graphics.setColor. Exact values per the M2.6 tickets.
local M = {}

M.palette = {
	-- UI chrome
	bg = "#15151e",
	panel = "#2a2a3a",
	text = "#e8e8ec",
	muted = "#9a9aa8",
	accent = "#f0c040",
	success = "#6aa84f",
	danger = "#e2554a",
	-- Suits
	Clubs = "#6aa84f",
	Spades = "#7f8a9b",
	Hearts = "#d6608f",
	Diamonds = "#b06fd6",
	-- Elements
	Fire = "#e2554a",
	Acid = "#b6d94c",
	Physical = "#d8d2c2",
	Frost = "#5fc7e8",
	Poison = "#7d4b9c",
	-- Materials
	Wood = "#8a5a2b",
	Iron = "#6d7079",
	Stone = "#9a9488",
	Ice = "#b8e0ef",
	Holy = "#f2e6b3",
}

-- "#rrggbb" -> {r, g, b} in 0-1.
local function parse(hex)
	local r = tonumber(hex:sub(2, 3), 16) / 255
	local g = tonumber(hex:sub(4, 5), 16) / 255
	local b = tonumber(hex:sub(6, 7), 16) / 255
	return { r, g, b }
end

-- theme.hex(name) -> {r,g,b}; accepts a palette name or a raw "#rrggbb" string.
function M.hex(name)
	local value = M.palette[name] or name
	return parse(value)
end

-- Convenience: set the current draw color from a palette name (with optional alpha).
function M.set(name, a)
	local c = M.hex(name)
	love.graphics.setColor(c[1], c[2], c[3], a or 1)
end

-- Load a pixel/monospace .ttf from assets/ if one is present; otherwise keep the
-- LOVE default font. Dropping a .ttf into assets/ activates it (M2.6.7).
function M.applyFont(size)
	size = size or 16
	for _, name in ipairs({ "assets/font.ttf", "assets/PixelMono.ttf", "assets/mono.ttf" }) do
		if love.filesystem.getInfo(name) then
			M.font = love.graphics.newFont(name, size)
			love.graphics.setFont(M.font)
			return M.font
		end
	end
	M.font = love.graphics.newFont(size)
	love.graphics.setFont(M.font)
	return M.font
end

return M
