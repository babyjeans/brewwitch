-- entity.lua
--  babyjeans
--
---
local Entity = class('Entity')
function Entity:init(name, x, y, texture)
    self.x = x or 0
    self.y = y or 0
    self.sortingLayer = 0
    self.visible = true
    self.name = name
    self.triggers = { } -- triggers are loosely associated with entities. this is probably a bad coupling
    self.textures = { }
    self:setTexture(texture)
end

---
-- Override < operator for table.sort
function Entity.__lt(lhs, rhs)
    return lhs.sortingLayer < rhs.sortingLayer
end

---
-- Game Functionality
--
function Entity:setTexture(texture, textureIndex)
    self.width = 0
    self.height = 0
    
    textureIndex = textureIndex or 1
    self.textures[textureIndex] = texture
 
    if self.textures[1] and textureIndex == 1 then
        self.width = self.textures[1]:getWidth()
        self.height = self.textures[1]:getHeight()
    end

    return self
end

function Entity:offsetBy(parent)
    self.parent = parent
    return self
end

function Entity:setSortingLayer(index)
    self.sortingLayer = index
    return self
end

function Entity:addTrigger(triggerName, params)
    --self.triggers[#self.triggers+1] = Trigger(triggerName, params)
    return self
end

function Entity:setState(newState)
    self.state = newState

    self.textures = { }
    local stateTextures = self.state.textures
    if stateTextures ~= nil then
        for i, texture in ipairs(stateTextures) do
            self:setTexture(texture, i)
        end
    else
        self:setTexture(self.state.texture)
    end

    return self
end

-- called when worldChunk is entered on all entities that exist in it.
-- like a show. this is not for when THIS entity enters the chunk
function Entity:onChunkEnter(worldChunk)
    for i, trigger in ipairs(self.triggers) do 
        worldChunk.world:registerTrigger(trigger)
        trigger:onChunkEnter(worldChunk)
    end 
end

function Entity:onChunkExit(worldChunk)
    for i, trigger in ipairs(self.triggers) do
        worldChunk.world:unregisterTrigger(trigger)
        trigger:onChunkExit(worldChunk)
    end
end

function Entity:move(directionX, directionY)
    local sw = GameSettings.Screen.Resolution.w
    local sh = GameSettings.Screen.Resolution.h

    self.x = self.x + directionX
    self.flipped = directionX < 0
    
    self.y = self.y + directionY

    local leftConstraint = 0
    local rightConstraint = sw

    if self.constrained ~= nil then
        self.constrained:update()
        leftConstraint = self.constrained.xMin
        rightConstraint = self.constrained.xMax
    end

    local entityLeft = self.x
    local entityRight = self.x + self.width

    if entityLeft < leftConstraint then
        if not self:tryTransition('left') then
            self.x = leftConstraint
        end
    elseif entityRight > rightConstraint then
        if not self:tryTransition('right') then
            self.x = rightConstraint - self.width
        end
    end

    self.chunk:checkTriggers(self)
    return self
end

function Entity:draw(offsetX, offsetY)
    local sx = 1
    local sy = 1

    offsetX = offsetX or 0
    offsetY = offsetY or 0

    if self.parent then
        offsetX = offsetX + (self.parent.x or 0)
        offsetY = offsetY + (self.parent.y or 0)
    end

    local x = self.x + offsetX
    local y = self.y + offsetY

    if self.flipped then
        sx = -1
        x = x + self.width 
    end

    for i, texture in ipairs(self.textures) do
        local drawX = x
        local drawY = y 
        love.graphics.draw(texture, drawX, drawY, 0, sx, sy)
    end
end

-- 'Prorotypes' for child classes... virtual functions basically.
function Entity:update(dt) end
function Entity:tryTransition(side) end

return Entity