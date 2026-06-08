local Gamestate = require("lib.hump.gamestate")
local Deck = require("src.core.deck")
local Towns = require("src.data.towns")
local Resolver = require("src.combat.resolver")
-- Placeholder M1 deck source: the 52-card vocabulary generator. Replaced by the
-- starter deck (M2.5) and the expedition deck (M4).
local Vocab = require("tests.decks")

local M = {}

local function cardRect(i)
	local w, h, gap = 120, 160, 12
	return 24 + (i - 1) * (w + gap), 360, w, h
end

local function structRect(i)
	local w, h, gap = 360, 56, 12
	return 24, 70 + (i - 1) * (h + gap), w, h
end

local function hit(mx, my, x, y, w, h)
	return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function selectedCards(self)
	local cards = {}
	for i, card in ipairs(self.hand) do
		if self.selected[i] then
			cards[#cards + 1] = card
		end
	end
	return cards
end

local function commit(self)
	local target = self.target
	local cards = selectedCards(self)
	if not target or #cards == 0 then
		self.message = "Pick at least one card AND a structure, then press Enter."
		return
	end

	local outcome = Resolver.resolveCommit({ [target] = cards }, self.town)
	for id, result in pairs(outcome.results) do
		if result.destroyed then
			self.town.structures[id].destroyed = true
		end
	end

	local kept = {}
	for i, card in ipairs(self.hand) do
		if not self.selected[i] then
			kept[#kept + 1] = card
		end
	end
	self.hand = kept
	self.selected = {}
	self.target = nil

	if outcome.conquered then
		Gamestate.switch(require("src.states.result"), true)
	elseif #self.hand == 0 then
		Gamestate.switch(require("src.states.result"), false)
	else
		self.message = "Lane committed. Keep sieging the Core."
	end
end

function M:enter()
	local deck = Deck.build(Vocab.vocabulary())
	Deck.shuffle(deck, 1337)
	Deck.draw(deck)
	self.deck = deck
	self.hand = deck.hand
	self.town = Towns.frontier()
	self.selected = {}
	self.target = nil
	self.message = "Click cards to select, click a structure to target, Enter to commit."
end

function M:update(dt) end

function M:draw()
	love.graphics.clear(0.08, 0.07, 0.1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Siege: " .. self.town.name, 24, 24)

	for i, s in ipairs(self.town.structures) do
		local x, y, w, h = structRect(i)
		if s.destroyed then
			love.graphics.setColor(0.18, 0.18, 0.22)
		elseif self.target == i then
			love.graphics.setColor(0.5, 0.42, 0.16)
		else
			love.graphics.setColor(0.16, 0.16, 0.24)
		end
		love.graphics.rectangle("fill", x, y, w, h)
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("line", x, y, w, h)
		local label = string.format(
			"%s   DEF %d%s%s",
			s.name,
			s.def,
			s.core and "   [CORE]" or "",
			s.destroyed and "   (destroyed)" or ""
		)
		love.graphics.print(label, x + 10, y + 18)
	end

	for i, card in ipairs(self.hand) do
		local x, y, w, h = cardRect(i)
		if self.selected[i] then
			love.graphics.setColor(0.2, 0.4, 0.5)
		else
			love.graphics.setColor(0.15, 0.15, 0.2)
		end
		love.graphics.rectangle("fill", x, y, w, h)
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("line", x, y, w, h)
		love.graphics.print(card.rank, x + 10, y + 10)
		love.graphics.print(card.suit, x + 10, y + h - 28)
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(self.message, 24, 330)
	love.graphics.print("Enter: commit    R: restart    Esc: menu", 24, 520)
end

function M:mousepressed(mx, my, button)
	if button ~= 1 then
		return
	end
	for i = 1, #self.hand do
		local x, y, w, h = cardRect(i)
		if hit(mx, my, x, y, w, h) then
			self.selected[i] = not self.selected[i] or nil
			return
		end
	end
	for i, s in ipairs(self.town.structures) do
		local x, y, w, h = structRect(i)
		if not s.destroyed and hit(mx, my, x, y, w, h) then
			self.target = i
			return
		end
	end
end

function M:keypressed(key)
	if key == "return" then
		commit(self)
	elseif key == "r" then
		Gamestate.switch(require("src.states.combat"))
	elseif key == "escape" then
		Gamestate.switch(require("src.states.menu"))
	end
end

return M
