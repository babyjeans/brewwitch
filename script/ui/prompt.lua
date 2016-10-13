-- prompt.lua
--  babyjeans
--
---
local Prompt = class('Prompt')
function Prompt:init(x, y, key, label, justification)
	self.x = x
	self.y = y
	self.key = key or ' '
	self.label = label
	self.justification = justification

	self.keyTexture = Resources.ui.keyUp
	self.keyWidth = self.keyTexture:getWidth() - 1
	self.hpadding = 2
	self.vpadding = 1
	self.gameFont = Resources.fonts.font

	self.updateHook = coreApp:hookupdate({self, self.update})
end

function Prompt:update(dt)
	if coreInput:isKeyDown(self.key) then
		self.keyTexture =  Resources.ui.keyDown
		self.down = true
	else
		self.keyTexture =  Resources.ui.keyUp
		self.down = false
	end
end

function Prompt:draw()
	if (self.key == nil or self.key == ' ') and (self.label == nil or self.label=="") then
		return
	end

	love.graphics.setFont(self.gameFont)
	local drawX = self.x
	local drawY = self.y

	local keyX = drawX
	local keyY = drawY

	if self.label and self.label ~= '' then
		local textWidth = self.gameFont:getWidth(self.label)
		local textHeight =  self.gameFont:getHeight(self.label)
		local textRectWidth = textWidth + self.hpadding + 2
		local textRectHeight = textHeight + self.vpadding + 2
		
		drawY = drawY + 3
		if self.justification == 'right' then
			drawX = drawX - (self.keyWidth + self.hpadding + textRectWidth)
			keyX = drawX + textRectWidth + self.hpadding
		else
			drawX = drawX + self.keyWidth + self.hpadding + 1
		end

		love.graphics.setColor(GameSettings.Colors.Darkest)
		love.graphics.rectangle('line', drawX, drawY, textRectWidth, textRectHeight)
	
		love.graphics.setColor(GameSettings.Colors.lightest)
		love.graphics.rectangle('fill', drawX, drawY, textRectWidth-1, textRectHeight-1)

		love.graphics.setColor(GameSettings.Colors.Darkest)
		love.graphics.print(self.label, drawX + self.hpadding, drawY + self.vpadding)
	elseif self.justification == 'right' then
		keyX = keyX - self.keyWidth
	end

	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.keyTexture, keyX, keyY)
	
	if self.key and self.key ~= ' ' then
		love.graphics.setColor(GameSettings.Colors.Darkest)
		
		keyX = keyX + 6
		keyY = keyY + 3

		if self.down then
			keyX = keyX - 2
			keyY = keyY + 1
		end

		love.graphics.print(self.key, keyX, keyY)
	end
end

return Prompt