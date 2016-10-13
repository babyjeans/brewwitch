-- worldchunk.lua
--  babyjeans
--
-- worldchunks are the meat of the world, just a way to partition it
-- there might be a benefit to this programmatically, but definitely for 
-- my thinkins'
---

local WorldChunk = class('WorldChunk')
function WorldChunk:init(worldBuilder, world)
	local sw = GameSettings.Screen.Resolution.w
    local sh = GameSettings.Screen.Resolution.h

    self.world = world
    self.description = worldBuilder.description
	
    -- setup the ground
    local groundTable = worldBuilder.groundTable
	if #groundTable == 0 then
		coreDebug.err("WorldChunk:init", "can't build worldChunk without valid ground")
		return
	end

    local numTemplates = #groundTable
    local groundTemplate = groundTable[1]

    self.groundW = groundTemplate:getWidth()
    self.groundY = sh - groundTemplate:getHeight()
    self.groundTiles = { }
    
    local numTiles = math.ceil(sw / self.groundW)
    for i=1, numTiles do 
        self.groundTiles[i] = groundTable[math.floor(love.math.random(1, numTemplates))]
    end

	if worldBuilder.dither then
		self.dither = worldBuilder.dither.dither 
        self.ditherY = worldBuilder.dither.y or 41
		self.ditherW = self.dither:getWidth()
        self.ditherRepeat = math.ceil(sw / self.ditherW)
	end

    self.parallax = { }
	if worldBuilder.parallax then
		for i, parallax in ipairs(worldBuilder.parallax) do
		end
	end

    self.env = { }
	if worldBuilder.env then
        self.env = worldBuilder.env
	end

    self.bgFills = { }
    if #worldBuilder.bgFills > 0 then
        self.bgFills = worldBuilder.bgFills
    end

    self.entities = { }
    if worldBuilder.entities then
        for i, entityEntry in ipairs(worldBuilder.entities) do
            local x, y, entityScript = unpack(entityEntry)
          
            entityScript = require(EntityPath .. entityScript)
            local entity = entityScript()
            entity.x = x
            entity.y = y
            entity.chunk = self
            self.entities[#self.entities + 1] = entity
        end
    end
end

function WorldChunk:onEnter()
    for i, entity in ipairs(self.entities) do
        self.world:registerEntity(entity)
        entity:onChunkEnter(self)
    end
end

function WorldChunk:onExit()
    for i, entity in ipairs(self.entities) do
        self.world:unregisterEntity(entity)
        entity:onChunkExit(self)
    end    
end

function WorldChunk:parsePosition(position, obj)
	local pos = { 0, 0 }

	for i=1,2 do
		if type(position[i]) == 'number' then
			pos[i] = position[i]
		elseif type(position[i]) == 'boolean' then
			if position[i] then
				pos[i] = 1
			else
				pos[i] = 0
			end
		else
			if position[i] == 'ground' then
				position[i] = self.groundY
				if obj then
					local h = obj.h or obj.height or obj:getHeight()
					if h then
						position[i] = position[i] - h
					end
				end 
			end
		end
	end

	return unpack(pos)
end

function WorldChunk:checkTriggers(entity)
    self.world:checkTriggers(entity)
end

function WorldChunk:draw()
    local colors = GameSettings.Colors
    local sw = GameSettings.Screen.Resolution.w
    local sh = GameSettings.Screen.Resolution.h 
    local drawX = 0
    
	-- draw background
   	for i=1,#self.bgFills do
        local fill = self.bgFills[i]
        love.graphics.setColor(colors[fill[3]])
        love.graphics.rectangle('fill', 0, fill[1], sw, fill[2])
	end

    -- reset
    love.graphics.setColor(255, 255, 255, 255)

    -- draw the dither
	if self.dither then
		for i=1,self.ditherRepeat do
			love.graphics.draw(self.dither, drawX, self.ditherY)
			drawX = drawX + self.ditherW
		end
	end

	-- draw ground
	drawX = 0
	for i=1,#self.groundTiles do
		love.graphics.draw(self.groundTiles[i], drawX, self.groundY)
		drawX = drawX + self.groundW
	end

	-- draw props
    for i=1, #self.env do 
        local obj = self.env[i]
        love.graphics.draw(unpack(obj))
    end
end

return WorldChunk