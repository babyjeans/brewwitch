-- tweens.lua
--	babyjeans
--
-- a simple manager for tween.lua tweens
---
local Tweens = class('coreTweens')

----
--- Tween class
--
-- adapter class to wrap tween.lua and add a few more features
--

local Tween = class('coreTween')
function Tween:init(tweens, duration, subject, target, callback, easing)
	if type(callback) == 'string' and not easing then easing = callback
	elseif type(callback) == 'function' then self.callback = callback end
	
	self._tween = Tween.new(duration, subject, target, easing)
	self.complete = false
	self.Tweens = tweens
end

	
function Tween:restart() 
	local found = false
	local playingTweens = self.Tweens.tweens
	for i, t in ipairs(playingTweens) do
		if self == t then found = true end
	end

	if not found then 
		playingTweens[#playingTweens + 1] = self 
	end
	
	self.complete  = false
	self._tween.set(0)
end

function Tween:play()
	self:restart()
end

function Tween:kill()
	local playingTweens = self.Tweens.tweens
	for i, t in ipairs(playingTweens) do
		if tween == self then
			table.remove(tweens.tweens, i) 
			break
		end
	end
end


----
--- Tweens
--
--

function Tweens:init()
	self.tweens = { }
	coreApp:hookupdate( {self, self.update} )
end

-- same params as tween.lua
function Tweens:newTween(duration, subject, target, callback, easing)
	local me = self
	local tween = Tween(self, duration, subject, target, callback, easing)
	self.tweens[#self.tweens + 1] = tween
	return tween
end

function Tweens:update()
	local dt = love.timer.getDelta()
	
	table.removeIndexedMatching(self.tweens, function(tween)
		tween.complete = tween._tween:update(dt)
		if tween.complete then
			if tween.callback then tween.callback(self) end
			return true
		end
	end)
end

return Tweens