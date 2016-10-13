-- circle.lua
--	babyjeans
--
-- simple class for circle collisions
---
local Circle = class('coreCircle')

function Circle:init(x, y, radius)
	self.x = x
	self.y = y
	self.radius = radius
end

---
-- implementation
--
function Circle:contains(x, y)
	local xy = Vector2(x, y)
	local me = Vector2(self.x, self.y)
	return (xy - me):magnitude() <= self.radius
end

function Circle:intersects(otherCircle)
	local xy = Vector2(otherCircle.x, otherCircle.y)
	local me = Vector2(self.x, self.y)
	return (xy - me):magnitude() <= self.radius + otherCircle.radius	
end

---

return Circle