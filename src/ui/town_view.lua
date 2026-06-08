-- Structure card widget: an independent lane target showing name, DEF, material,
-- and core/locked/destroyed/targeted state. Colors from theme.lua.
local Theme = require("src.ui.theme")

local M = {}

function M.draw(s, x, y, w, h, opts)
	opts = opts or {}
	if s.destroyed then
		Theme.set("bg")
	elseif opts.targeted then
		Theme.set("accent", 0.35)
	else
		Theme.set("panel")
	end
	love.graphics.rectangle("fill", x, y, w, h, 6, 6)

	Theme.set(s.material or "muted")
	love.graphics.rectangle("line", x, y, w, h, 6, 6)

	Theme.set(s.destroyed and "muted" or "text")
	love.graphics.print(s.name .. (s.core and "  [CORE]" or ""), x + 10, y + 8)
	love.graphics.print(
		string.format("DEF %d   %s%s", s.def, s.material or "", s.destroyed and "   (destroyed)" or ""),
		x + 10,
		y + 32
	)
end

return M
