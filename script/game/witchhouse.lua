-- witchhouse.lua
--  babyjeans
--
-- the script for the house
---
local WitchHouse = Entity:extend('WitchHouse')

local tween = require('ext/tween')
local Trigger = require('script/game/trigger')

local function closeInOnHelper(player, xPos, dt)
    if player == xPos then
        return 0
    end

    if player.x > xPos then
        if player.x - (dt * player.playerSpeed) <= xPos then
            player = xPos
            return 0
        end
         dt = -dt
    elseif player.x < xPos then
        if player.x + (dt * player.playerSpeed) >= xPos then
            player.x = xPos
            return 0
        end
       
    end

    return dt
end

local function climbLadderMoveUpdate(player, me, dt)
    local ladderHotSpot = 29
    local ladderTopY = 104 - player.height
    local ladderBottomY = 126
    local climbSpeed = 0.7

    local leftPressed  = coreInput:isActionDown('left')
    local rightPressed = coreInput:isActionDown('right')
    local upPressed    = coreInput:isActionDown('up')
    local downPressed  = coreInput:isActionDown('down')

    if not leftPressed and not rightPressed and not upPressed and not downPressed then
        return false
    end

    -- don't left/right while climbing
    if me.ladderState == 'climb' and 
       ((leftPressed or rightPressed) and not (upPressed or downPressed)) then
        return true
    end

    if (upPressed and me.ladderState == 'bottom') or (downPressed and me.ladderState == 'top') then
        dt = closeInOnHelper(player, ladderHotSpot, dt)
        if dt == 0 then
            local clockSet = climbSpeed

            if upPressed then 
                local spot = { x=ladderHotSpot, y=ladderTopY }
                me.ladderTween = tween.new(climbSpeed, player, spot)
                clockSet = 0
            end

            me.ladderState = 'climb'
            me.ladderTween:set(clockSet) 
        else
            player:move(dt * player.playerSpeed, 0)
        end
        return true
    elseif me.ladderState == 'climb' and (upPressed or downPressed) then
        local finishState = 'top'
        if downPressed then
            dt = -dt 
            finishState = 'bottom'
        end

        if me.ladderTween:update(dt) or me.ladderTween.clock <= 0 then
            me.ladderState = finishState
        end

        return true
    end
    return false
end

local function climbStairMoveUpdate(player, me, dt)
    local playerStairHotSpot = 60
    local doorSpot = { x=53, y=126 }
    local topSpot = { x=doorSpot.x, y=doorSpot.y - player.height }
    local climbSpeed = 0.8
    
    local leftPressed  = coreInput:isActionDown('left')
    local rightPressed = coreInput:isActionDown('right')
    local upPressed    = coreInput:isActionDown('up')
    local downPressed  = coreInput:isActionDown('down')

    local doUp = upPressed or leftPressed
    local doDown = downPressed or rightPressed

    if me.stairState ~= 'climb' then
        if (me.stairState == 'top' and doDown) or
           (me.stairState == 'bottom' and upPressed) then
            
            local hotSpot = playerStairHotSpot
            if me.stairState == 'top' then
                if doUp then return upPressed end
                hotSpot = doorSpot.x
            end
            
            dt = closeInOnHelper(player, hotSpot, dt)
            if dt == 0 then
                if me.stairState == 'bottom' then
                    me.stairTween = tween.new(climbSpeed, player, topSpot)
                else
                    me.stairTween:set(climbSpeed)
                    me:showInside(false, player)
                end
                me.stairState = 'climb'
            else    
                player:move(dt * player.playerSpeed, 0)
            end

            return true
        end
    elseif doUp or doDown then
        player.flipped = doUp
        local finalState = 'top'
        local playerY = player.y
        if doDown then
            dt = -dt
            finalState = 'bottom'
        end

        if me.stairTween:update(dt) or me.stairTween.clock <= 0 then
            me.stairState = finalState
            
            if doDown then
                player.x = playerStairHotSpot
                player.y = GameSettings.Screen.Resolution.h - (8 + player.height)
            else
                me:showInside(true, player)
                player.x = doorSpot.x
            end
        end

        return true
    end

    return false
end

function WitchHouse:init(x, y)
    self.states = {
        outside = { texture=Resources.witchHouse.outside },
        inside = { textures={ Resources.witchHouse.outside, Resources.witchHouse.interiorLvl1 } }
    }

    WitchHouse.super.init(self, 'WitchHouse', x, y)
    self.stairState = 'bottom'
    self.ladderState = 'bottom'
    self:setState(self.states.outside)

    local me = self
    
    coreDebug:addWatch('witchHouse.stairState', function() return self.stairState end)
    
    self.triggers = {
    	Trigger('enterWitchHouse', { 
    		x = 47, y =126, 
    		w = 29, h = 11,

            onTrigger = function(self, entity)
                if entity.isPlayer then
                    entity.moveUpdate = function(self, dt)
                        return climbStairMoveUpdate(self, me, dt)
                    end
                end
            end,

    		onTriggerExit = function(self, entity)
    			if entity.isPlayer then
    				entity.moveUpdate = nil
                    self.stairTween = nil
    			end
    		end,
    	}),

        Trigger('climbWitchLadder', {
            x = 28, y = 86,
            w = 12, h = 42,

            onTrigger = function(self, entity) 
                if not me.inside then
                    return
                end

                if entity.isPlayer then
                    entity.moveUpdate = function(self, dt)
                        return climbLadderMoveUpdate(self, me, dt)
                    end
                end
            end,

            onTriggerExit = function(self, entity)
                if entity.isPlayer then
                    entity.moveUpdate = nil
                    self.ladderTween = nil
                end
            end,
        })
	}

    self.entities = { 
        Entity('bed', 5, 31, Resources.witchHouse.bed)
            :offsetBy(self)
            :setSortingLayer(101)
            :addTrigger('sleep',
                { }),

        Entity('cauldron', 47, 29, Resources.witchHouse.cauldron)
            :offsetBy(self)
            :setSortingLayer(101)
            :addTrigger('brew', { }),

        Entity('counter', 15, 52, Resources.witchHouse.counter)
            :offsetBy(self)
            :setSortingLayer(101)
            :addTrigger('sell', { })
    }
end

function WitchHouse:showInside(show, player)
    self.inside = show
    local registerFunc = self.chunk.world.registerEntity

    if show then
        self:setState(self.states.inside)
        player.constrained = Rectangle(6, 80, 68, 51)
    else
        self:setState(self.states.outside)
        player.constrained = nil
        registerFunc = self.chunk.world.unregisterEntity
    end

    for i, entity in ipairs(self.entities) do
        registerFunc(self.chunk.world, entity)
    end
end

function WitchHouse:onPlayerOver(player)
    payer.moveUpdate = playerClimbStairs
end


return WitchHouse