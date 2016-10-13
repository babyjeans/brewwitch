-- world.lua
--	babyjeans
-- 
-- i put the whole world in here
---
local World = class("World")
local WorldBuilder = require('script/game/builder')

function World:init()
	initWorldData(Resources)

	self.envObjs = { }
	self.world = { }
	self.entities = vector()
    self.triggers = vector()
    self.triggered = vector()

    for i, mapData in ipairs(WorldMapData) do 
		mapData:build(self)
	end

    if not self.currentChunk then
        self.currentChunk = 1
    end

    self:enterChunk(self.currentChunk, true)
end

function World:registerEntity(entity)
    self.entities:add(entity)
    entity.chunk = self.world[self.currentChunk]
    self.entitiesDirty = true
end

function World:unregisterEntity(entity)
    self.entities:remove(entity)
    self.entitiesDirty = true
end

function World:registerTrigger(trigger)
	self.triggers:add(trigger)
end

function World:unregisterTrigger(trigger)
	self.triggers:remove(trigger)
end

function World:enterChunk(chunkIndex)
    local worldChunk = self.world[self.currentChunk]
    if worldChunk ~= nil then 
        worldChunk:onExit()
    end

    self.currentChunk = chunkIndex
    worldChunk = self.world[self.currentChunk]
    if worldChunk ~= nil then
        worldChunk:onEnter()
    end
end

function World:sortEntities()
    table.sort(self.entities.contents)
    self.entitiesDirty = nil
end

function World:checkTriggers(entity)
    local entityRect = Rectangle(entity.x, entity.y, entity.width, entity.height)
    local overlappingTrigger = { }
    local removeTriggers = { }
    entity.triggered = entity.triggered or vector()
    
    -- find what we overlap
    for i, trigger in ipairs(self.triggers.contents) do
        local triggerRect = Rectangle(trigger.x, trigger.y, trigger.w, trigger.h)
    
        if entityRect:intersects(triggerRect) then
            overlappingTrigger[#overlappingTrigger+1] = trigger
        end
    end

    -- remove any triggers we no longer overlap
    entity.triggered:forEach(function(trigger)
        local found = false
        for i, overlapped in ipairs(overlappingTrigger) do
            if overlapped == trigger then
                found = true
                break
            end
        end
        if not found then
            removeTriggers[#removeTriggers + 1] = trigger
        end
    end)

    -- do the remove
    for i, trigger in ipairs(removeTriggers) do
        entity.triggered:remove(trigger)
        trigger:onTriggerExit(entity)
    end

    -- trigger any existing triggers / new triggers
    for i, overlapped in ipairs(overlappingTrigger) do
        local found = false
        for i, prev in ipairs(entity.triggered.contents) do
            if prev == overlapped then
                prev:onTrigger(entity)
                found = true
                break
            end
        end
        
        if not found then
            entity.triggered:add(overlapped)
            overlapped:onTriggerEnter(entity)
        end
    end
end

---
-- drawing functions
--
--	drawbehind - called first, draws background pieces and most of the environment
--	drawEntities - draw all entities at this point
--  drawInfront - draw environment pieces that appear 'in front' of entities, such as counters / walls
-- 	
---
function World:draw()
    local worldChunk = self.world[self.currentChunk]
    
    worldChunk:draw()
    self:drawEntities()
end

function World:drawEntities()
	for i, entity in ipairs(self.entities.contents) do
		entity:draw()
	end
end

---
-- externally called functions
function World:update(dt)
    if self.entitiesDirty then
        self:sortEntities()
    end

	for i, entity in ipairs(self.entities.contents) do
		entity.chunk = self.world[self.currentChunk]
		entity:update(dt)
	end
end

return World