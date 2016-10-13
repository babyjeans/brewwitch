-- boxedtext.lua
--  babyjeans
--
---
local BoxedText = class('BoxedText')
function BoxedText:init(label)
	self.font = Resources.fonts.font

    self.colors = {
    	shadow = GameSettings.Colors.Dark,
    	border = GameSettings.Colors.Darkest,
    	fill = GameSettings.Colors.Light,
    	label = GameSettings.Colors.Darkest
	}

	self.shadow = true
	self.alignment = 'center'
	self:setText(label)
end

function BoxedText:setShadow(shadow)
	self.shadow = shadow
	return self
end

function BoxedText:setText(text)
	local textWidth = self.font:getWidth(text)
	self.w = textWidth + 4
	self.h = self.font:getHeight(text) + 4
	self.label = text
	return self
end

function BoxedText:draw(x, y)
	if self.alignment == 'center' then
		x = (x - self.w / 2) + 2
	end

	local w = self.w
	local h = self.h

	if self.shadow then
    	love.graphics.setColor(self.colors.shadow)
    	love.graphics.rectangle('line', x - 1, y + 1, w, h)
    end
    
    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle('line', x, y, w, h)
    
    love.graphics.setColor(self.colors.fill)
    love.graphics.rectangle('fill', x, y, w-1, h-1)            

    love.graphics.setColor(self.colors.label)
    love.graphics.print(self.label, x + 2, y + 2)
end

return BoxedText