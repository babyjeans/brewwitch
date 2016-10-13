-- app.lua
--	babyjeans
--
-- convenience class for handling app stuff, keeping it out of love namespace
---
local App = class('coreApp')

-- types
GameState       = require('script/core/gamestate')
Rectangle       = require('script/core/rectangle')
Circle 		    = require('script/core/circle')

-- global systems
Timers          = { }
Resources       = { } 
Audio			= { }

function App:init(appFunctions)
	App.appInstance = self
	if love then
		love.load = App.load
		love.update = App.update
		love.draw = App.draw
	end

	self.states = { }

	AppUtil.addHook(self, 'update')
	self.currentState = GameState()

	love.graphics.setDefaultFilter('nearest', 'nearest')
	--love.mouse.setGrabbed(true)

	self.appFunctions = {
		load = appFunctions.load or function() end,
		update = appFunctions.update or function(dt) end,
		draw = appFunctions.draw or function() end
	}

	-- setup input
	coreInput:hookPressed(function(key, scancode, isrepeat)
		App.appInstance:keyPressed(key, scancode, isrepeat)
	end)

	coreInput:hookReleased(function(key, scancode)
		App.appInstance:keyReleased(key)
	end)
end

---
-- state management
--

function App:addState(name, state)
	self.states[name] = state
end


function App:setState(state)
	state = self.states[state]
	if state == self.currentState then
		return 
	end 
	
	if self.currentState then
		self.currentState:exit()
	end

	self.currentState = state

	if self.currentState then
		self.currentState:enter()
	end
end


function App:setScreen(screen)
	self.screen = screen

	-- create the render target for the target resolution
	self.renderCanvas = love.graphics.newCanvas(self.screen.Resolution.w, self.screen.Resolution.h)
end


---
--
--
function App.load()
	self = App.appInstance

	Timers 	 = require('script/core/timers')
	Tweens   = require('script/core/tweens')
	Audio	 = require('script/core/audio')

	self.appFunctions.load(self)
end

function App.draw()
	self = App.appInstance

	self.renderCanvas:renderTo(function()
		self.appFunctions.draw(self, dt)
		self.currentState:draw()

	end)

	-- draw the canvas now
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.renderCanvas, 0, 0, 0, self.screen.Scale, self.screen.Scale)

	-- draw debug data
    coreDebug:draw()
end

function App.update(dt)
	self = App.appInstance

	self.appFunctions.update(self, dt)
	self.currentState:update(dt)
	for i, updateHook in ipairs(self.updateHooks.contents) do
		updateHook[2](updateHook[1], dt)
	end

	coreDebug:update()
end

function App:keyReleased(key)
	self.currentState:onKeyReleased(key)

	if key == '\\' then
    	coreDebug.showWatches = not coreDebug.showWatches
	end
end

function App:keyPressed(key)
	self.currentState:onKeyPressed(key)
end

return App