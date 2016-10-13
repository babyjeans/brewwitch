-- Rectangle.lua
--	babyjeans
--
-- A rectangle class to use for intersection tests
---
Rectangle = class('coreRectangle')

function Rectangle:init(x, y, w, h)
	self.x = x or 0
	self.y = y or 0
	self.w = w or 0 
	self.h = h or 0

    self:update()
end

function Rectangle:set(x, y, w, h)
	self.x = x or 0
	self.y = y or 0
	self.w = w or 0
	self.h = h or 0

    self:update()
end

function Rectangle:min() 
	return { x=self.x, y=self.y }
end

function Rectangle:max()
	return { x=self.x+self.w, y=self.y+self.h }
end

function Rectangle:contains(x, y)
	return x >= self.x and x <= self.x + self.w and
	       y >= self.y and y <= self.y + self.h 
end

-- update the max/min functions, only necessry if those are used
function Rectangle:update()
    local min = self:min()
    local max = self:max()

    self.xMin = min.x
    self.xMax = max.x

    self.yMin = min.y
    self.yMax = max.y
end

function Rectangle:intersects(otherRect)
	local min = self:min()
	local max = self:max()

	local otherMin = otherRect:min()
	local otherMax = otherRect:max()

	if min.x > otherMax.x or max.x < otherMin.x or min.y > otherMax.y or max.y < otherMin.y then
		return false
	end
	return true
end

return Rectangle