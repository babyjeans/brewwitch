-- timers.lua
--	babyjeans 
--
-- a simple timer class
--
--	use: 
--		Timers:newTimer(seconds, callback, repeats)
--			create a new timer that will call the callback after seconds. if repeats is true it will repeat indefinitely
--			if repeats is a number it will repeat that many times.
--
--		Timers:update()
--			must call this every update to update the timers values
--
--		Timer:start()
--			restart a timer
--
--		Timer:stop()
--			stop the timer
---
local Timers = class('coreTimers')
local Timer = class('coreTimer')

local timerList = { }

---
--
function Timer:init(seconds, callback, repeats)
	self.timeElapsed = 0
	self.seconds = seconds
	self.startTime = love.timer.getTime()
	self.lastTime = self.startTime
	self.callback = callback  
	self.repeats = repeats 
	if self.repeats == nil then self.repeats = true end
	self.og_repeats = self.repeats
end

function Timer:start()
	if not self.isGoing then
		self.isGoing = true
		timerList[#timerList + 1] = self
	end
end

function Timer:reset()
	self.lastTime = love.timer.getTime()
	self.isGoing = true
	self.repeats = self.og_repeats
end

function Timer:stop(callCallback)
	self.isGoing = false
	if callCallback and self.callback then self.callback() end
end

---
--
function Timers:init()
	coreApp:hookupdate( { self, self.update } )
end

function Timers:newTimer(seconds, callback, repeats)
	local timer = Timer(seconds, callback, repeats)
	timer:start()
	return timer
end

function Timers:update()
	local currentTime = love.timer.getTime()
	
	table.removeIndexedMatching(timerList, function(timer)
		if timer.isGoing then 
			timer.timeElapsed = currentTime - timer.lastTime
			if timer.timeElapsed >= timer.seconds then
				timer.callback()

				if type(timer.repeats) == "number" then
					timer.repeats = timer.repeats - 1
					if timer.repeats < 0 then
						timer.isGoing = false
						return true
					end
				elseif not timer.repeats then
					timer.isGoing = false
					return true
				end

				timer.lastTime = currentTime
			end
		else
			return true
		end
	end)
end

return Timers()