-- anim.lua
--  babyjeans
--
-- simple animation class
---
local Anim = class('Anim')
function Anim:init(animData)
	self.animData = animData
    self.fps = self.animData.fps
    self.looping = self.animData.looping

    self.isPlaying = false
    self.frame = 1
end

function Anim:setLooping(looping)
	self.looping = looping
	return self
end

function Anim:setFPS(fps)
	self.fps = fps
	return self
end

function Anim:play(reset)
    
    self.animTime = 0
	self.isPlaying = true    
	self.fps = self.fps or 30
	self.frameTime = 1.0 / self.fps

	if reset == nll then reset = true end
	if reset then self.frame = 1 end

	return self
end

function Anim:update(dt)
	if not self.isPlaying then
		return
	end

	local animTime = self.animTime + dt
    local frameCount = self.animData.frameCount

	if animTime >= self.frameTime then
		self.frame = self.frame + 1
		if self.frame > frameCount then
			if self.looping then
				self.frame = 1
			else
				self.frame = frameCount
				self.isPlaying = false
			end
		end

		self.animTime = 0
	else
		self.animTime = animTime
	end
end

function Anim:draw(x, y)
	local frame = self.frame
	local frames = self.animData.frames
	local texture = self.animData.texture

	if frames and frames[frame] then
		love.graphics.draw(self.animData.texture, frames[frame], x, y)
	end
end

return Anim
