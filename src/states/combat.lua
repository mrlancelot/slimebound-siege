local Gamestate = require("lib.hump.gamestate")
local Deck = require("src.core.deck")
local Siege = require("src.combat.siege")
local Towns = require("src.data.towns")
local StarterDeck = require("src.data.starter_deck")
local Theme = require("src.ui.theme")
local CardUI = require("src.ui.card")
local TownView = require("src.ui.town_view")

local M = {}

local function structRect(i)
	local w, h, gap = 210, 90, 12
	return 24 + (i - 1) * (w + gap), 70, w, h
end

local function cardRect(i)
	local w, h, gap = 120, 150, 12
	return 24 + (i - 1) * (w + gap), 370, w, h
end

local function hit(mx, my, x, y, w, h)
	return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function selectedList(self)
	local cards = {}
	for _, card in ipairs(self.siege.hand) do
		if self.selected[card] then
			cards[#cards + 1] = card
		end
	end
	return cards
end

function M:enter()
	local deck = Deck.shuffle(Deck.build(StarterDeck.build()), 1337)
	self.siege = Siege.new(deck, Towns.frontier(), { hp = 30, seed = 7 })
	self.selected = {}
	self.target = nil
	self.debug = false
	self.message = "Sculpt: exchange (E) cards, Enter ends a turn. Town fights back each turn."
end

function M:update(dt) end

local function drawHud(self)
	local s = self.siege
	Theme.set("text")
	love.graphics.print("Siege: " .. s.town.name, 24, 16)
	love.graphics.print(
		string.format("Sculpt turns: %d    Exchanges left: %d    Gold: %d", s.sculptTurnsLeft, s.exchangesLeft, s.gold),
		24,
		38
	)
	if s.lockedSuit then
		Theme.set("danger")
		love.graphics.print("Locked suit: " .. s.lockedSuit, 480, 38)
	end

	-- expedition HP bar (top-right)
	local x, y, w, h = 600, 14, 320, 18
	local frac = math.max(0, s.expeditionHP) / s.maxHP
	Theme.set("panel")
	love.graphics.rectangle("fill", x, y, w, h, 4, 4)
	Theme.set(frac > 0.5 and "success" or (frac > 0.25 and "accent" or "danger"))
	love.graphics.rectangle("fill", x, y, w * frac, h, 4, 4)
	Theme.set("muted")
	love.graphics.rectangle("line", x, y, w, h, 4, 4)
	Theme.set("text")
	love.graphics.print(string.format("HP %d/%d", s.expeditionHP, s.maxHP), x + 8, y + 1)
end

local function drawBreakdown(self)
	local s = self.siege
	if not self.target then
		return
	end
	local structure = s.town.structures[self.target]
	local p = Siege.preview(s, self.target)
	Theme.set("muted")
	love.graphics.print("Targeting: " .. structure.name, 24, 180)
	Theme.set("text")
	if p then
		love.graphics.print(
			string.format(
				"%s  %d x%d x%.1f = %d   vs DEF %d   -> %s",
				p.combo.kind,
				p.combo.rankSum,
				p.combo.mult,
				p.type,
				p.attack,
				p.def,
				p.destroyed and "DESTROYED" or "holds"
			),
			24,
			202
		)
	else
		love.graphics.print("No cards in this lane yet (select cards, then click this structure).", 24, 202)
	end
end

function M:draw()
	Theme.set("bg")
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	drawHud(self)
	for i, s in ipairs(self.siege.town.structures) do
		local x, y, w, h = structRect(i)
		TownView.draw(s, x, y, w, h, { targeted = self.target == i })
	end
	drawBreakdown(self)

	for i, card in ipairs(self.siege.hand) do
		local x, y, w, h = cardRect(i)
		CardUI.draw(card, x, y, w, h, {
			selected = self.selected[card],
			assignedTo = self.siege.assigned[card],
		})
	end

	Theme.set("text")
	love.graphics.print(self.message, 24, 336)
	Theme.set("muted")
	love.graphics.print(
		"Click: select card / click structure to assign    E: exchange    Enter: end turn / COMMIT    R: restart    Esc: menu",
		24,
		524
	)

	if self.debug then
		Theme.set("accent")
		love.graphics.print(
			string.format("[debug] seed=%d lanes=%d hand=%d", self.siege.seed, (function()
				local n = 0
				for _ in pairs(self.siege.lanes) do
					n = n + 1
				end
				return n
			end)(), #self.siege.hand),
			24,
			500
		)
	end
end

local function endTurnOrCommit(self)
	local s = self.siege
	if s.sculptTurnsLeft > 0 then
		Siege.endSculpt(s)
		self.message = s.sculptTurnsLeft > 0 and "Town fought back. One sculpt turn left."
			or "Sculpt done. Assign lanes (click cards, then a structure), Enter to COMMIT."
		return
	end
	local result = Siege.commit(s)
	Gamestate.switch(require("src.states.result"), {
		conquered = result.conquered,
		outcome = result.outcome,
		loot = result.loot,
		hp = s.expeditionHP,
		maxHP = s.maxHP,
	})
end

function M:mousepressed(mx, my, button)
	if button ~= 1 then
		return
	end
	for i, card in ipairs(self.siege.hand) do
		local x, y, w, h = cardRect(i)
		if hit(mx, my, x, y, w, h) then
			self.selected[card] = not self.selected[card] or nil
			return
		end
	end
	for i, s in ipairs(self.siege.town.structures) do
		local x, y, w, h = structRect(i)
		if hit(mx, my, x, y, w, h) then
			self.target = i
			local picks = selectedList(self)
			local assigned = 0
			for _, card in ipairs(picks) do
				if Siege.assign(self.siege, card, i) then
					assigned = assigned + 1
				end
				self.selected[card] = nil
			end
			if assigned > 0 then
				self.message = string.format("Assigned %d card(s) to %s.", assigned, s.name)
			end
			return
		end
	end
end

function M:keypressed(key)
	if key == "return" then
		endTurnOrCommit(self)
	elseif key == "e" then
		local picks = selectedList(self)
		if Siege.exchange(self.siege, picks) then
			for _, card in ipairs(picks) do
				self.selected[card] = nil
			end
			self.message = "Exchanged. Exchanges left: " .. self.siege.exchangesLeft
		else
			self.message = "Can't exchange that many (budget: " .. self.siege.exchangesLeft .. ")."
		end
	elseif key == "tab" then
		self.debug = not self.debug
	elseif key == "r" then
		Gamestate.switch(require("src.states.combat"))
	elseif key == "escape" then
		Gamestate.switch(require("src.states.menu"))
	end
end

return M
