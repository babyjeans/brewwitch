-- brew witch
-- 	a game wonderfully created by babyjeans for #GBJAM-5
--	http://babyjeans.rou.sr
--  http://www.twitter.com/babyj3ans
---

-- external types / core
class           = require('ext/30log-clean')
Tween           = require('ext/tween')

-- types
vector          = require('script/core/vector')
Vector2         = require('script/core/vector2')
AppUtil			= require('script/core/apputil')
 
coreApp			= { }
coreInput 		= require('script/core/input')
coreDebug		= require('script/core/debug')


-- game specific
require('gamedata')

-- app definition
local App             = require('script/core/app')

AppUtil.addTableHelpers()

coreApp = App({
	load = function(self)
		Resources = require('script/core/resources')
		initGameData()

		coreInput:updateControlMap(GameSettings.Controls)
	
		self:setScreen(GameSettings.Screen)

		self:addState('mainMenu', require('script/mainmenu'))
		self:addState('game', 	 require('script/game'))
		self:setState('mainMenu')
	end,

	update = function(self, dt)
		
	end,

	draw = function(self)

	end,
})