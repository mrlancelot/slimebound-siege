-- Card face widget: rank, suit glyph (themed by suit), element pip, and selection
-- / lane-assignment state. All colors come from theme.lua (presentation only).
local Theme = require("src.ui.theme")

local M = {}

local SUIT_GLYPH = { Clubs = "C", Spades = "S", Hearts = "H", Diamonds = "D" }

function M.draw(card, x, y, w, h, opts)
	opts = opts or {}
	Theme.set(opts.selected and "accent" or "panel")
	love.graphics.rectangle("fill", x, y, w, h, 6, 6)
	Theme.set(opts.selected and "accent" or "muted")
	love.graphics.rectangle("line", x, y, w, h, 6, 6)

	Theme.set("text")
	love.graphics.print(card.rank, x + 8, y + 6)

	Theme.set(card.suit)
	love.graphics.print(SUIT_GLYPH[card.suit] or "?", x + 8, y + h - 24)

	-- element pip (top-right)
	Theme.set(card.element)
	love.graphics.rectangle("fill", x + w - 20, y + 8, 12, 12, 2, 2)

	if opts.assignedTo then
		Theme.set("accent")
		love.graphics.print("->" .. tostring(opts.assignedTo), x + w - 40, y + h - 24)
	end
	Theme.set("text")
end

return M
