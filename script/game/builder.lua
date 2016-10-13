-- builder.lua
--	babyjeans
--
-- worldbuilders build segments of the world that 
-- are essentially stitched together in the gamedata.lua file
---
local Builder = class("Builder")
local WorldChunk = require('script/game/worldchunk')

function Builder:init(description)
	self.description = description
	self.groundTable = { }
    self.bgFills = { }
end

function Builder:setGroundTable(groundTable)
	self.groundTable = groundTable
	return self
end

function Builder:setDither(dither, y)
	self.dither = { 
        dither = dither,
        y =  y
    }
	return self
end

function Builder:addBgFill(bgFills) 
    for i=1, #bgFills do
        self.bgFills[#self.bgFills+1]=bgFills[i]
    end

    return self
end

function Builder:addParallax(parallaxImage, params)
	if not parallaxImage then return end

	local position = params.position or {  0, 'ground' }
	local scrollSpeed = params.speed or { -1, 0 }

	self.parallax = self.parallax or { }
	self.parallax[#self.parallax+1] = { 
        image=parallaxImage, 
        position=position, 
        speed=scrollSpeed 
    }

	return self
end

function Builder:setStartZone(x, y)
    self.startZone = { x, y }
	return self
end

function Builder:addEnv(x, y, sprite)
    self.env = self.env or { }
    self.env[#self.env + 1] = { x, y, sprite }
	return self
end

function Builder:addEntity(entity, x, y)
    self.entities = self.entities or { }
    self.entities[#self.entities + 1] = { x, y, entity }
    return self
end

function Builder:build(world)
    local newChunk = WorldChunk(self, world)
	world.world[#world.world + 1] = newChunk

	if self.startZone then 
        world.currentChunk = #world.world
        local x, y = newChunk:parsePosition(self.startZone)
        world.start = { x, y }
    end
end

return Builder