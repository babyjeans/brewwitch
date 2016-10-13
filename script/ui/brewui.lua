-- brewui.lua
--  babyjeans
--
---
local BrewUI = class('BrewUI')
local tween = require('ext/tween')
local Cauldron = require('script/ui/cauldron')
local BoxedText = require('script/ui/boxedtext')

function BrewUI:init()
    local me = self

    self.window = Rectangle(27, 35, 100, 93)
    self.original = Rectangle(27, 35, 100, 93)

    Resources.loadStage('brewUI')
    self.cauldron = Cauldron()

    self.menuTop    = Resources.brewUI.menuTop
    self.menuMiddle = {
        topBorder = Resources.brewUI.menuMiddleTop,
        fill = Resources.brewUI.menuMiddleMid,
        bottomBorder  = Resources.brewUI.menuMiddleBot,

        height = 36,
    }
    self.menuBottom = Resources.brewUI.menuBottom

    self.menuTopH    = self.menuTop:getHeight()
    self.menuBottomH = self.menuBottom:getHeight()

    self.title = BoxedText('BREW')
    self.tweens = { }
    
    self.inventorySlotCount = 5
    self.recipeSlotCount = 4
    self.selected = 1
    self.lastSelected = 1

    self.recipeSlot = { w=21, h=20, up=Resources.brewUI.recipeSlotUp, down=Resources.brewUI.recipeSlotDown, 
        berry = Resources.brewUI.recipeBerry, 
        stick = Resources.brewUI.recipeStick,
        bone  = Resources.brewUI.recipeBone,
        eye   = Resources.brewUI.recipeEye,
    }
    self.recipe = { } -- 'berry', 'stick', 'bone', 'eye' }

    self.inventorySlot = { w=14, h=15, up=Resources.brewUI.inventorySlotUp, down=Resources.brewUI.inventorySlotDown,
        berry = Resources.brewUI.inventoryBerry, 
        stick = Resources.brewUI.inventoryStick,
        bone  = Resources.brewUI.inventoryBone,
        eye   = Resources.brewUI.inventoryEye,
     }

    self.tweenTopY = 0
    self.tweenBottomY = 0
    self.tweenCauldronY = 0

    self.lastTime = 'failedBrew'

    self.brewStates = {
        ['mixing'] = { 
            enterState = function(self, oldState)
                if oldState ~= nil and oldState ~= 'mixing' then
                    self.tweens = {
                        tween.new(0.6, self, { tweenTopY = 0, tweenBottomY = 0, tweenCauldronY = 0 }, 'outQuad'),
                        tween.new(0.6, self.window, { y = self.original.y }, 'outQuad'),
                        tween.new(0.6, self.menuMiddle, { height = 36 }, 'outQuad')
                    }
                end

                self.cauldron:setState('idle')
                self.brewTween = nil
            end,
        },

        ['brewing'] = {
            enterState = function(self, oldState) 
                self.cauldron:setState('brew')
                self.tweens = {
                    tween.new(1.2, self, { tweenTopY = self.menuTopH - 5, tweenBottomY  = -1*(self.menuBottomH - 5) }, 'outQuad'),
                    tween.new(1.7, self.window, { y = 16 }, 'outQuad')
                }

                self.brewTween = self.tweens[1] -- for fading text, hack
            end,

            update = function(self, dt) 
                if #self.tweens > 0 then
                    return
                end

                if not self.timer then
                    self.timer = Timers:newTimer(0.5, function()
                        local thisTime = 'failedBrew'
                        if self.lastTime == 'failedBrew' then thisTime = 'successfulBrew' end
                        me:setBrewState(thisTime)
                        self.lastTime = thisTime
                    end, false)
                end
            end,
        },

        ['failedBrew'] = {
            enterState = function(self, oldState) 
                self.cauldron:setState('failed')
                self.timer = nil
            end,

            update = function(self, dt)
                if not self.cauldron:isAnimPlaying() then
                    self.recipe = { }
                    self.selected = 'exit'
                    me:setBrewState('dismiss')
                end
            end,
        },

        ['dismiss'] = {
            enterState = function(self, oldState) 
            --    self.cauldron:setState('failed')
                self.timer = nil
            end,

            update = function(self, dt)
            end,

            draw = function(self)
                local textWidth = Resources.fonts.hugeFont:getWidth('FAILED')
                local textHeight = Resources.fonts.hugeFont:getHeight('FAILED')

                love.graphics.setFont(Resources.fonts.hugeFont)
                local x = self.window.x + ((self.window.w - textWidth) / 2) + 3
                local y = self.window.y + self.menuMiddle.height + textHeight + 12
                Game.UI:drawOutlineText("FAILED", x, y, GameSettings.Colors.Dark, GameSettings.Colors.Darkest)
                love.graphics.setFont(Resources.fonts.font)
            end,

        },

        ['successfulBrew'] = {
            enterState = function(self, oldState) 
                self.cauldron:setState('success')
                self.timer = nil
            end,

            update = function(self, dt)
                if not self.cauldron:isAnimPlaying() then
                    if not self.timer then
                        self.timer = Timers:newTimer(0.5, function()
                            self.recipe = { }
                            self.selected = 'exit'
                            me:setBrewState('presentBrew')
                        end, false)
                    end
                end
            end
        },
        
        ['presentBrew'] = {
            enterState = function(self, oldState)
                self.cauldron:setState('present')
                self.timer = nil

                self.tweens = {
                    tween.new(0.8, self, { tweenCauldronY = 18 }, 'outQuad'),
                    tween.new(0.8, self.menuMiddle, { height = self.menuMiddle.height + 35 } )
                }
            end,

            update = function(self, dt)
                if #self.tweens > 0 then return end

                if self.cauldron.state == 'present' and not self.cauldron:isAnimPlaying() then
                    self.cauldron:setState('choose')
                end
            end,

            draw = function(self)

                if self.cauldron.state == 'choose' then
                    local textWidth = Resources.fonts.bigFont:getWidth('SUCCESS!')
                    local textHeight = Resources.fonts.bigFont:getHeight('SUCCESS!')

                    love.graphics.setFont(Resources.fonts.bigFont)
                    local x = self.window.x + ((self.window.w - textWidth) / 2) + 3
                    local y = self.window.y + self.menuMiddle.height + 12
                    Game.UI:drawOutlineText("SUCCESS!", x, y, GameSettings.Colors.Light, GameSettings.Colors.Darkest)
                    love.graphics.setFont(Resources.fonts.font)
                end
            end,
        }
    }
    self.brewState = 'mixing'

    self.cursor = { 
        texture = Resources.ui.cursor,
        bounceY = -2,
        bounceUp = true,

        update = function(self, dt) 
            if not self.bounceUp then
                dt = -dt
            end

            if self.bounceTween:update(dt) or (not self.bounceUp and self.bounceTween.clock <= 0) then
                self.bounceUp = not self.bounceUp
            end
        end,
    }
    self.cursor.bounceTween = tween.new(1.2, self.cursor, { bounceY = 2 }, 'inOutCubic')

    self.brewButton = {
        x = 0,
        y = 39,

        shadowX = 2,
        shadowY = 4,

        bounceX = 0,
        bounceY = -5,
        bounceUp = false,

        update = function(self, dt)
            if self.bounceUp then dt = -dt end

            if self.bounceTween:update(dt) or (self.bounceUp and self.bounceTween.clock <= 0) then
               self.bounceUp = not self.bounceUp
            end
        end
    }
    self.brewButton.bounceTween = tween.new(1.5, self.brewButton, { bounceY = 5 }, 'inOutQuad')

    --
    -- debug watches
    coreDebug:addWatch('brewUI tweens', function() return #self.tweens end)
    coreDebug:addWatch('cauldron State', function() return self.cauldron.state end)
    coreDebug:addWatch('brew state', function() return self.brewState end)
end

---
-- implementation
--

function BrewUI:canBrew()
    local recipeIngredients = 0
    for i=1,self.recipeSlotCount do
        if self.recipe[i] ~= nil then
            recipeIngredients = recipeIngredients + 1
        end
    end
    return recipeIngredients > 0 
end

function BrewUI:setBrewState(newState)
    local oldState = self.brewState 
    self.brewState = newState

    local state = self.brewStates[self.brewState]
    if state.enterState then state.enterState(self, oldState) end
end

---
-- query
--

function BrewUI:availableRecipeSlot()
    for i=1,self.recipeSlotCount do 
        if self.recipe[i] == nil then return i end 
    end
end


---
-- input handling
-- 
function BrewUI:handleRelease(key, action)
    if not action then return end

    if self.brewState == 'mixing' then
        if #self.tweens == 0 then
            if action:is('primary') and self.selected == 'exit' then
                Game.UI.showBrewUI = false
            end
        end
    end
end

function BrewUI:handlePress(key, action)
    if not action then
        return
    end
    
    local canBrew = self:canBrew()

    local maxSlot = 0
    local minSlot = 0

    if self.brewState ~= 'mixing' then
        if action:is('primary') or action:is('secondary') then
            if self.brewState == 'dismiss' then
                self:setBrewState('mixing')
            elseif self.cauldron.state == 'choose' then
                self:setBrewState('mixing')
            end 
        end
        return
    end

    for i=1,self.inventorySlotCount do
        local slot = Game.player:getItemSlot(i)
        if slot and slot.itemName then
            maxSlot = i
            if minSlot == 0 then
                minSlot = i
            end
        end
    end

    if maxSlot == 0 and minSlot == 0 then
        self.selected = 'exit'
        return
    end

    -- Left Action
    if action:is('left') then
        if     self.selected == 'exit' then self.selected = maxSlot
        elseif self.selected == 'brew' then self.selected = 'exit'
        else 
            local slot = { }

            self.lastSelected = self.selected

            repeat
                self.selected = self.selected - 1
                slot = Game.player:getItemSlot(self.selected)
            until (slot and slot.itemName) or self.selected < minSlot

            if self.selected < minSlot then
                if canBrew then self.selected = 'brew'
                else self.selected = 'exit'
                end
            end
        end

        return true

    -- Right Action
    elseif action:is('right') then
        if self.selected == 'exit' then
            if canBrew then self.selected = 'brew'
            else self.selected = minSlot
            end
        elseif self.selected == 'brew' then self.selected = minSlot
        else
            self.lastSelected = self.selected
            
            local slot = { }
            repeat
                self.selected = self.selected + 1
                slot = Game.player:getItemSlot(self.selected)
            until (slot and slot.itemName) or self.selected > maxSlot

            if self.selected > maxSlot then self.selected = 'exit' end
        end

        return true
   
    -- Up Action
    elseif action:is('up') then
        if type(self.selected) == 'number' then
            self.lastSelected = self.selected
            if canBrew then self.selected = 'brew'
            else  self.selected = 'exit' 
            end
        elseif self.selected == 'exit' then self.selected = self.lastSelected
        elseif self.selected == 'brew' then self.selected = 'exit' 
        end

    -- Down Action
    elseif action:is('down') then
        if type(self.selected) == 'number' then
            self.lastSelected = self.selected
            self.selected = 'exit'
        elseif self.selected == 'brew' then self.selected = self.lastSelected
        elseif self.selected == 'exit' then
            if canBrew then self.selected = 'brew'
            else self.selected = self.lastSelected
            end
        end

    -- Primary
    elseif action:is('primary') then
        if #self.tweens > 0 then
            return true
        end

        if type(self.selected) == 'number' then
            local slot = Game.player:getItemSlot(self.selected)
            if slot and slot.itemName then 
                local emptySlot = 0
                local itemCount = 0
                
                for recipeSlot=1, self.recipeSlotCount do
                    if     self.recipe[recipeSlot] == nil and emptySlot == 0 then emptySlot = recipeSlot
                    elseif self.recipe[recipeSlot] == slot.itemName          then itemCount = itemCount + 1
                    end
                end

                if emptySlot > 0 and itemCount < slot.count then
                    self.recipe[emptySlot] = slot.itemName
                    return true
                end
            end
        else
            if self.selected == 'brew' then self:setBrewState('brewing') end
        end

        return true

    -- Secondary
    elseif action:is('secondary') then
        if #self.tweens > 0 then
            return true
        end

        if type(self.selected) == 'number' then
            local slot = Game.player:getItemSlot(self.selected)
            if slot and slot.itemName then
                local removeSlot = 0
                for recipeSlot=self.recipeSlotCount, 0, -1 do
                    if self.recipe[recipeSlot] == slot.itemName then
                        self.recipe[recipeSlot] = nil
                        return true
                    elseif removeSlot == 0 and self.recipe[recipeSlot] ~= nil then
                        removeSlot = recipeSlot
                    end
                end

                if removeSlot ~= 0 then
                    self.recipe[removeSlot] = nil
                    return true
                end
           end

           self.lastSelected = self.selected
           self.selected = 'exit'
        else
            self.selected = self.lastSelected
        end
        return true
    end

    -- don't consume nothin'
    return false
end

---
-- update / draw
--

function BrewUI:update(dt)
    if self:canBrew() then
        if self.cauldron.state == 'idle' then
            self.cauldron:setState('canBrew')
            return
        end
    else
        if self.cauldron.state == 'canBrew' then
            self.cauldron:setState('idle')
            return
        end
    end

    local state = self.brewStates[self.brewState]
    if state and state.update then
        state.update(self, dt)
    end

    self.cauldron:update(dt)
    self.brewButton:update(dt)
    self.cursor:update(dt)

    table.removeIndexedMatching(self.tweens, function(tween)
        return tween:update(dt)
    end)
end

function BrewUI:draw()
    love.graphics.setLineStyle('rough')
    
    local x = self.window.x
    local y = self.window.y
    local w = self.window.w
    local h = self.window.h
    y = y + self.tweenTopY

    -- draw the window
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self.menuTop, x, y)

    -- draw the title
    y = y - (self.title.h / 2) - 3
    self.title:draw(self.window.x + (w/2), y)

    -- draw the top slots
    love.graphics.setColor(255, 255, 255, 255)
    x = self.window.x + ((self.window.w - ((self.recipeSlot.w + 4) * self.recipeSlotCount)) / 2) + 6
    y = y + self.title.h + 5
    w = self.recipeSlot.w
    h = self.recipeSlot.h

    for i=1,self.recipeSlotCount do
        love.graphics.draw(self.recipeSlot.up, x, y)
        if self.recipe[i] then
            love.graphics.draw(self.recipeSlot[self.recipe[i]], x, y)
        end
        x = x + w + 3
    end

    -- draw the inventory
    x = self.window.x
    y = self.window.y + self.menuTopH + self.menuMiddle.height + self.tweenBottomY
    love.graphics.draw(self.menuBottom, x, y)

    x = self.window.x + ((self.window.w - ((self.inventorySlot.w + 2) * self.inventorySlotCount)) / 2) + 3
    y = self.window.y + self.menuTopH + self.menuMiddle.height + 3 + self.tweenBottomY
    w = self.inventorySlot.w
    h = self.inventorySlot.h
    
    for i=1,self.inventorySlotCount do
        local drawDown = false
        local slotTexture = self.inventorySlot.up

        love.graphics.setColor(255,255,255,255)
        if self.selected == i then
            local cursorX = x - self.cursor.texture:getWidth() - 1
            local cursorY = y + ((self.inventorySlot.up:getHeight() - self.cursor.texture:getHeight()) / 2) + self.cursor.bounceY
            
            love.graphics.draw(self.cursor.texture, cursorX, cursorY)        

            if coreInput:isActionDown('primary') then
                drawDown = true
                slotTexture = self.inventorySlot.down
            end
        end

        love.graphics.draw(slotTexture, x, y)

        local inventoryItem = Game.player:getItemSlot(i)
        if inventoryItem and inventoryItem.itemName ~= nil and inventoryItem.count ~= nil then
            local itemName = inventoryItem.itemName
            local count = inventoryItem.count
            for i=1,self.recipeSlotCount do
                local recipeItem = self.recipe[i]
                if recipeItem == itemName then
                    count = count - 1
                end
            end
            
            local invX = x
            local invY = y
            if drawDown then 
                invX = invX + 1
                invY = invY + 1
            end

            love.graphics.draw(self.inventorySlot[itemName], invX, invY)

            local countX = x + 5
            local countY = y + h + 1
            count = math.floor(count)

            if count > 9 then
                countX = countX - 1
            end

            if not self.brewTween or (self.brewTween.clock / self.brewTween.duration < 0.8) then
                love.graphics.setColor(GameSettings.Colors.Dark)
                love.graphics.print(count, countX + 1, countY + 1)

                love.graphics.setColor(GameSettings.Colors.Lightest)
                love.graphics.print(count, countX, countY)
            end
        end
        x = x + w + 2
    end

    -- draw the exit button
    if self.brewState == 'mixing' then
        x = self.window.x + self.window.w - 19
        y = self.window.y + self.window.h - 3
        w = 19
        h = self.title.h    

        if self.brewTween then
            y = y - self.tweenBottomY
        end

        if self.selected == 'exit' and #self.tweens == 0 then
            if coreInput:isActionDown('primary') then
                x = x + 1
                y = y + 1
            end
        end

        love.graphics.setColor(GameSettings.Colors.Dark)
        love.graphics.rectangle('line', x - 1, y + 1, w, h)
        
        love.graphics.setColor(GameSettings.Colors.Darkest)
        love.graphics.rectangle('line', x, y, w, h)
      
        love.graphics.setColor(GameSettings.Colors.Light)
        if self.selected == 'exit' and #self.tweens == 0 then
            if coreInput:isActionDown('primary') then
                love.graphics.setColor(GameSettings.Colors.Dark)
            end
        end

        love.graphics.rectangle('fill', x, y, w-1, h-1)            
      
        if self.selected == 'exit' then
            local cursorX = x - self.cursor.texture:getWidth() - 1
            local cursorY = y + ((h - self.cursor.texture:getHeight()) / 2) + self.cursor.bounceY
            
            love.graphics.setColor(255,255,255,255)    
            love.graphics.draw(self.cursor.texture, cursorX, cursorY)
        end

        love.graphics.setColor(GameSettings.Colors.Darkest)
        love.graphics.print('Exit', x + 2, y + 2)
    end

    --
    -- draw the middle section
    love.graphics.setColor(255, 255, 255, 255)
    x = self.window.x 
    y = self.window.y + self.menuTopH
    love.graphics.draw(self.menuMiddle.topBorder, x, y)
    y = y + 2
    love.graphics.draw(self.menuMiddle.fill, x, y, 0, 1, (self.menuMiddle.height - 4) / 2) -- 2 cause its 2px
    y = y + self.menuMiddle.height - 4
    love.graphics.draw(self.menuMiddle.bottomBorder, x, y)
    
    -- draw Cauldron
    x = self.window.x + ((self.window.w - Resources.menu.logo:getWidth()) / 2) + 2
    y = self.window.y + self.menuTopH - 10 + self.tweenCauldronY
    self.cauldron:draw(x, y)

    -- if brew is selected, animate it
    if self.selected == 'brew' and self:canBrew() and self.brewState == 'mixing' then
        local textX = self.window.x + self.brewButton.x
        local textY = self.window.y + self.brewButton.y -- 39

        local shadowX = textX + (self.brewButton.shadowX or 0)
        local shadowY = textY + (self.brewButton.shadowY or 0)
        textX = textX + (self.brewButton.bounceX or 0)
        textY = textY + (self.brewButton.bounceY or 0)

        love.graphics.setColor(GameSettings.Colors.Light)
        love.graphics.draw(Resources.brewUI.brewButton, shadowX, shadowY)

        love.graphics.setColor(GameSettings.Colors.Lightest)
        love.graphics.draw(Resources.brewUI.brewButton, textX, textY)   
    end

    local brewState = self.brewStates[self.brewState]
    if brewState.draw then brewState.draw(self) end
end

---

return BrewUI()