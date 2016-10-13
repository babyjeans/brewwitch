-- ui.lua
--	babyjeans
--
-- until it gets mkore complicated - the game UI
---
local UI = class("UI")
local Prompt = require('script/ui/prompt')

function UI:init()
	self.endCap = Resources.ui.endCap
	self.bar = Resources.ui.bar
	self.divider = Resources.ui.divider
	self.magicBar = Resources.ui.magicBarBack
	self.magicBarFill = Resources.ui.magicBarFill
	self.magicIcon = Resources.ui.magicIcon
	self.coin = Resources.ui.coin
	self.countX = Resources.ui.countX
	self.key = Resources.ui.key
    self.brewUI = require('script/ui/brewui')
    self.catalogUI = require('script/ui/catalog')

    self.promptLeft  = Prompt(79, 3, 'z', 'Brew', 'right')
	self.promptRight = Prompt(81, 3, 'x', 'Brew', 'left')
end

function UI:draw()
	local screenW = GameSettings.Screen.Resolution.w
	local endCapW = self.endCap:getWidth()
	local barW = self.bar:getWidth()

	-- draw background
	love.graphics.setColor(GameSettings.Colors.Light)
	love.graphics.rectangle('fill', 0, 0, 160, 21)

	-- draw bar
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.endCap, 0, 21)
	love.graphics.draw(self.endCap, screenW, 21, 0, -1, 1)

	local barPieces = math.ceil((screenW - (endCapW * 2)) / barW)
	local drawX = endCapW
	for i=1,barPieces do
		love.graphics.draw(self.bar, drawX, 21)
		drawX = drawX + barW
	end

	-- draw dividers
	love.graphics.draw(self.divider, 34, 0)
	love.graphics.draw(self.divider, 126, 0)

	-- draw the prompts
	if self.showBrewUI then 
		if self.brewUI.brewState == 'mixing' or (self.brewUI.cauldron.state == 'choose') or self.brewUI.brewState == 'dismiss' then
			self.promptLeft:draw()
			self.promptRight:draw()
		end
	else
		local slotTexture = self.brewUI.inventorySlot.up
	        
		local x = 37
		local y = 0
		local w = slotTexture:getWidth()
		local h = slotTexture:getHeight()
	    
	    -- draw inventory
		for i=1,self.brewUI.inventorySlotCount do
	        local drawDown = false

	        love.graphics.setColor(255,255,255,255)
	        love.graphics.draw(slotTexture, x, y)

	        local inventoryItem = Game.player:getItemSlot(i)
	        if inventoryItem and inventoryItem.itemName ~= nil and inventoryItem.count ~= nil then
	            local itemName = inventoryItem.itemName
	            local count = inventoryItem.count
	            
	            local invX = x
	            local invY = y
	            if drawDown then 
	                invX = invX + 1
	                invY = invY + 1
	            end

	            love.graphics.draw(self.brewUI.inventorySlot[itemName], invX, invY)

	            local countX = x + 5
	            local countY = y + h - 2
	            count = math.floor(count)

	            if count > 9 then
	                countX = countX - 1
	            end

	            love.graphics.setColor(GameSettings.Colors.Dark)
	            love.graphics.print(count, countX + 1, countY + 1)

	            love.graphics.setColor(GameSettings.Colors.Lightest)
	            love.graphics.print(count, countX, countY)
	        end
	        x = x + w + 2
	    end
	end

	-- draw the magic meter
	love.graphics.setColor(255,255,255,255)
	drawX = 129
	drawY = 12
	love.graphics.draw(self.magicBar,         drawX,      drawY)
	love.graphics.draw(self.magicBarFill,     drawX,      drawY)
	love.graphics.draw(self.magicIcon,    drawX + 9, drawY - 11)
	
	-- draw money
	local money = Game.player.money
	money=2500
	drawX = 2
	drawY = 7
	local countX = drawX + 8
	local countY = drawY + 3
	if money >= 1000 then
		drawX = drawX - 2
		countX = countX - 2
	end
	--love.graphics.draw(self.coin, 8, 2)
	--love.graphics.draw(self.countX, 16, 5)
	love.graphics.draw(self.coin,    drawX,  drawY)
	love.graphics.draw(self.countX, countX, countY)

	local w = Resources.fonts.font:getWidth(money)
	local h = Resources.fonts.font:getHeight(money)
	
	-- drawX = (31 - w) / 2
	drawX = 15

	if money >= 1000 then
		drawX = drawX - 2
	end

	--drawY = 12
	drawY = 8

	love.graphics.setColor(GameSettings.Colors.Lightest)
	love.graphics.rectangle('fill', drawX+1, drawY, w-3, h - 1)
	love.graphics.setColor(GameSettings.Colors.Dark)
	love.graphics.print(money, drawX, drawY)
	self:drawOutlineText(money, drawX, drawY, GameSettings.Colors.Dark, GameSettings.Colors.Lightest)

    if self.showBrewUI then
        self.brewUI:draw()
    elseif self.showCatalogUI then
        self.catalogUI.draw()
    end
end

function UI:update(dt)
	if self.showBrewUI then
		self.brewUI:update(dt)

		-- update prompts
		if self.brewUI.brewState == 'mixing' then
			local selected = self.brewUI.selected
			if type(selected) == 'number' then
				
				if self.brewUI:availableRecipeSlot() ~= nil then
					self.promptLeft.label  = 'Add'
				else
					self.promptLeft.label  = ''
				end

				if self.brewUI:canBrew() then
					self.promptRight.label = 'Take'
				else
					self.promptRight.label = 'Exit'
				end
			elseif selected == 'brew' then
				self.promptLeft.label  = 'Brew'
				self.promptRight.label = 'Back'
			elseif selected == 'exit' then
				self.promptLeft.label  = 'Exit'
				self.promptRight.label = 'Back'
			end
		elseif self.brewUI.cauldron.state == 'choose' then
			self.promptLeft.label = 'Yay'
			self.promptRight.label = 'Yippie'
		elseif self.brewUI.brewState == 'dismiss' then
			self.promptLeft.label = 'Fine'
			self.promptRight.label = 'Okay'
		end
	elseif self.showCatalogUI then
        self.showCatalogUI(dt)

        -- update prompts
    end
end

function UI:hasControls()
	return self.showBrewUI or self.showCatalogUI
end

function UI:handlePress(key, action)
    if self.showBrewUI then
    	return self.brewUI:handlePress(key, action)
    elseif self.showCatalogUI then
        return self.catalogUI:handlePress(key, action)
    end

    return false
end

function UI:handleRelease(key, action)
	if self.showBrewUI then
    	return self.brewUI:handleRelease(key, action)
    elseif self.showCatalogUI then
        return self.catalogUI:handleRelease(key, action)
    end

    return false
end

function UI:drawOutlineText(text, x, y, textColor, bgColor, border)
    love.graphics.setColor(bgColor)

    local i=1
	love.graphics.print(text, x - i, y)
	love.graphics.print(text, x - i, y - i)
	love.graphics.print(text, x,     y - i)
	love.graphics.print(text, x + i, y - i)
	love.graphics.print(text, x + i, y)
	love.graphics.print(text, x + i, y + i)
	love.graphics.print(text, x,     y + i)
	love.graphics.print(text, x - i, y + i)

    love.graphics.setColor(textColor)
    love.graphics.print(text, x, y)
end

return UI