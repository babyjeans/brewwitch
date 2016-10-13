-- game.lua
--	babyjeans
--
-- the "game" gamestate... manages the world and gameUI, basically
-- the container for stuff not in the main menu.
--
-- TODO: need a pause state?
---
Game = { }
GameClass = GameState:extend("GameClass")

Entity = require('script/game/entity')
Anim = require('script/game/anim')

local World = require('script/game/world')
local UI = require('script/ui/ui')
local Player = require('script/game/player')

---
-- init / appstate
function GameClass:init()
	-- load resources
	Resources.loadStage('fonts')
	Resources.loadStage('game')
	Resources.loadStage('forest')
	Resources.loadStage('cave')
	Resources.loadStage('brewWitch')
	Resources.loadStage('witchHouse')
	Resources.loadStage('ui')
	
	local screenW = GameSettings.Screen.Resolution.w
	local screenH = GameSettings.Screen.Resolution.h

	self.gameFont = Resources.fonts.font
	self.gameFontHuge = Resources.fonts.fontHuge

	self.world = World()
	self.player = Player(self.world)
	self.UI = UI()
end

function GameClass:enter()
	--disable for now 
	--Audio:playTrack(Resources.game.brewWitchOST)
end

---
-- mutation

--- 
-- round / scene management

---
-- input handling
function GameClass:onKeyPressed(key) 
	----
	-- DEBUG / CHEAT KEYS
	--[[

	--]]
	---
	local action = coreInput:convertKey(key)

	if self.UI:handlePress(key, action) then
		return
	end

	if self.player:handlePress(key, action) then
		return
	end

	if action then
		if action:is('escape') then
			love.event.quit()
		end
	end
end

function GameClass:onKeyReleased(key)
	local action = coreInput:convertKey(key)

	if self.UI:handleRelease(key, action) then
		return
	end

	if self.player:handleRelease(key, action) then
		return
	end

end	

---
-- frame functions
function GameClass:update(dt)
	self.world:update(dt);
	self.UI:update(dt)
end

function GameClass:draw()	
	love.graphics.clear(GameSettings.Colors.Light)
	love.graphics.setColor(255,255,255,255)

	self.world:draw()
	self.UI:draw()
	--self.world:postDraw()
end

Game = GameClass()
return Game