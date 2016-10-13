-- mainmenu.lua
--	babyjeans
--
-- mainmanu for the game.
--   contains the options and credits screens
---
local MainMenu = GameState:extend("MainMenu")

local menuOptions = { }

local function addOption(optionName, callback)
	local num = #menuOptions + 1
	local y = 85
	y = y + (10 * num - 1)

	menuOptions[num] = { optionName, y, callback }
end

function MainMenu:init()
	Resources.loadStage('fonts')
	Resources.loadStage('menu')

	self.font = Resources.fonts.font
	self.hugeFont = Resources.fonts.hugeFont

	self.selectedOption = 1

	addOption("NEW GAME", function(mainMenu) mainMenu:onNewGame() end)
	addOption("OPTIONS", function(mainMenu) mainMenu:onOptions() end)
	addOption("QUIT", function(mainMenu) mainMenu:onQuit() end)
end

function MainMenu:onNewGame() 
	coreApp:setState('game')
end

function MainMenu:onOptions()
end

function MainMenu:onQuit()
	love.event.quit()
end

function MainMenu:onKeyPressed(key)
	if key == 'down' then
		self.selectedOption = self.selectedOption + 1
		if self.selectedOption > #menuOptions then
			self.selectedOption = 1
		end
	elseif key == 'up' then
		self.selectedOption = self.selectedOption - 1
		if self.selectedOption < 1 then
			self.selectedOption = #menuOptions
		end
	elseif key == 'return' then
		menuOptions[self.selectedOption][3](self)
	end
end

function MainMenu:draw()
	love.graphics.setFont(self.font)
	love.graphics.clear(GameSettings.Colors.Darkest)
	
	love.graphics.setColor(GameSettings.Colors.Lightest)
	love.graphics.print("BREW WITCH", 55, 20)
	love.graphics.print("2016 :: babyjeans :: rou.sr", 30, 134)
	love.graphics.draw(Resources.fonts.copyright, 22, 134)

	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(Resources.menu.logo, 64, 32)

	for i, menuOption in ipairs(menuOptions) do
		love.graphics.setColor(GameSettings.Colors.Light)
		if i == self.selectedOption then
			love.graphics.setColor(GameSettings.Colors.Lightest)
		end

		love.graphics.print(menuOption[1], 10, menuOption[2])
	end
end

return MainMenu()