-- player.lua
--	babyjeans
--
-- the player's script, player controls here
---
local Player = Entity:extend("Player")
function Player:init(world)
    local groundY = GameSettings.Screen.Resolution.h - 8
    local brewWitch = Resources.brewWitch.idle
    
    self.states = {
        idle = { texture=brewWitch }
    }

    Player.super.init(self, 'player')
    self:setState(self.states.idle)

    self.world = world
	self.groundY = groundY
	self.playerSpeed = 30

    self.x = 10
    self.y = groundY - self.height
    self.sortingLayer = 100
    self.isPlayer = true

    world:registerEntity(self)

    self.inventorySlotCount = 6
    self.inventorySlots = { }
    self.money = 250

    self:setInventoryItem(1, 'berry', 4)
    self:setInventoryItem(2, 'bone', 2)
    self:setInventoryItem(3, 'eye', 1)
end

function Player:setInventoryItem(slot, itemName, count)
    self.inventorySlots[slot] = { itemName=itemName, count=count or 0 }
end

function Player:getItemSlot(slotIndex)
    if slotIndex > 0 and slotIndex <= self.inventorySlotCount then
        return self.inventorySlots[slotIndex] or { }
    end
end

function Player:update(dt)
    if not Game.UI:hasControls() then
    	local left = coreInput:isActionDown('left')
    	local right = coreInput:isActionDown('right')

        if self.moveUpdate == nil or self:moveUpdate(dt) == false then
            if left or right then
                if left then
                    dt = -dt
                end
                self:move(dt * self.playerSpeed, 0)
                return true
            end
        end
    end

    return false
end

function Player:handlePress(key, action)
    if action then 
        if action:is('secondary') and not Game.UI:hasControls() then
            Game.UI.showBrewUI = true
        end
    end
end

function Player:handleRelease(key)
end

function Player:tryTransition(direction)
    local sw = GameSettings.Screen.Resolution.w
    local sh = GameSettings.Screen.Resolution.h
    if self.constrained ~= nil then
        return false
    end

    if direction == 'left' then
        local currentChunk = self.world.currentChunk
        if currentChunk == 1 then
            return false
        else
            self.world:enterChunk(currentChunk - 1)
            self.x = sw - self.width
            return true
        end
    elseif direction == 'right' then
        local currentChunk = self.world.currentChunk
        if currentChunk == #self.world.world then
            return false
        else
            self.world:enterChunk(currentChunk + 1)
            self.x = 0
            return true
        end
    end

    return false
end

return Player