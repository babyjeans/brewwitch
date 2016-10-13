-- debug
--  babyjeans
-- 
-- logging wrapper
---
local Rectangle       = require('script/core/rectangle')
local coreDebug = class('coreDebug')
function coreDebug:init()
    self.watchWindow = Rectangle(20, 26*4, 45*4, 45*4)
    self.showWatches = false
    self.watches = { }
end

function coreDebug:err(systemName, errorMsg)
    print(systemName .. ' - ' .. errorMsg)
end

function coreDebug:log(systemName, log)
    print(systemName .. ' - ' .. log)
end

function coreDebug:warn(systemName, warning)
    print(systemName .. ' - ' .. warning)
end

function coreDebug:assert(condition, systemname, errorMsg)
    if condition then
        return true
    end

    coreDebug:err(systemname, errorMsg)
end

function coreDebug:addWatch(watchName, valueFunc)
    for i, watch in ipairs(self.watches) do
        if watch.name == watchName then
            watch.valueFunc = valueFunc
            return
        end
    end

    self.watches[#self.watches + 1] = { name=watchName, valueFunc=valueFunc, value="" }
end

function coreDebug:removeWatch(watchName)
    for i, watch in ipairs(self.watches) do
        if watch.name == watchName then
            table.remove(self.watches, i)
            return
        end
    end
end

function coreDebug:update(dt)
    if not self.showWatches or #self.watches == 0 then
        return
    end
    
    for i, watch in ipairs(self.watches) do
        watch.value = watch.valueFunc(dt)
        watch.value = tostring(watch.value or 'nil')
    end
end

function coreDebug:draw()
    if not self.showWatches or #self.watches == 0 then
        return
    end

    self.watchWindow.h = #self.watches * 8
    -- draw container
    love.graphics.setColor(170, 168, 128, 128)
    love.graphics.rectangle('fill', self.watchWindow.x, self.watchWindow.y, 
        self.watchWindow.w, self.watchWindow.h)

    love.graphics.setColor(0, 0, 0, 255)

    -- draw each line
    local watchY = 0
    for i, watch in ipairs(self.watches) do
        love.graphics.print(watch.name .. ': ' ..   watch.value, self.watchWindow.x + 2, self.watchWindow.y + watchY)
        watchY = watchY + 8
    end
end

return coreDebug()