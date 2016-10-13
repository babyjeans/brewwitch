-- vector2.lua
-- 	babyjeans
--
-- simple 2d vector class. everything's just so SIMPLE!
---
local Vector2 = class('coreVector2')
function Vector2:init(x, y)
	self.x = x
	self.y = y
end

function Vector2.__add(l, r)
	return Vector2(
		l.x + r.x, 
		l.y + r.y
	)
end

function Vector2.__sub(v1, v2)
	return Vector2(
		v2.x - v1.x, 
		v2.y - v1.y
	)
end

-- scalar multiply or
-- dot product
function Vector2.__mul(l, r)
	if type(r) == 'number' then
		return Vector2(l.x * r, l.y * r)
	elseif type(l) == 'number' then
		return Vector2(l * r.x, l* r.y)
	else
		return l.x * r.x + l.y * r.y
	end
end

function Vector2:magnitude()
	return math.sqrt(self:magsq())
end

function Vector2:magsq()
	return self.x * self.x + self.y * self.y
end

function Vector2:norm()
	local mag = self:magnitude()
	if mag ~= 0 then
		return Vector2(self.x / mag, self.y / mag)
	end

	return Vector2(0, 0)
end

return Vector2