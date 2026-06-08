-- Structure card widget: an independent lane target showing name, HP, armor,
-- material, keyword badges, and core/locked/destroyed/targeted state. Colors from theme.
local Theme = require("src.ui.theme")

local M = {}

-- Short keyword tags for the badge line.
local function keywordTags(kw)
	if not kw then
		return ""
	end
	local tags = {}
	if kw.shield then
		tags[#tags + 1] = "Shield"
	end
	if kw.regen then
		tags[#tags + 1] = "Regen " .. kw.regen
	end
	if kw.thorns then
		tags[#tags + 1] = "Thorns " .. kw.thorns
	end
	if kw.ward then
		tags[#tags + 1] = "Ward:" .. kw.ward
	end
	return table.concat(tags, "  ")
end

function M.draw(s, x, y, w, h, opts)
	opts = opts or {}
	if s.destroyed then
		Theme.set("bg")
	elseif opts.locked then
		Theme.set("danger", 0.25)
	elseif opts.targeted then
		Theme.set("accent", 0.35)
	else
		Theme.set("panel")
	end
	love.graphics.rectangle("fill", x, y, w, h, 6, 6)

	Theme.set(s.material or "muted")
	love.graphics.rectangle("line", x, y, w, h, 6, 6)

	Theme.set(s.destroyed and "muted" or "text")
	love.graphics.print(s.name .. (s.core and "  [CORE]" or ""), x + 10, y + 6)
	love.graphics.print(
		string.format("HP %d   Armor %d   %s", s.hp, s.armor or 0, s.material or ""),
		x + 10,
		y + 28
	)
	if s.destroyed then
		Theme.set("muted")
		love.graphics.print("(destroyed)", x + 10, y + 50)
	elseif opts.locked then
		Theme.set("danger")
		love.graphics.print("locked (need Caster)", x + 10, y + 50)
	else
		Theme.set("muted")
		love.graphics.print(keywordTags(s.keywords), x + 10, y + 50)
	end
end

return M
