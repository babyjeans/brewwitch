-- cauldron.lua
--  babyjeans
--
-- brewui cauldron animation thing
---
local Cauldron = class('cauldron')
function Cauldron:init()
    self.states = {
    	['idle']    = { img   = Resources.brewUI.cauldronIdle                                                      },
        ['canBrew'] = { anim  = Anim(Resources.brewUI.cauldronCanBrew)                                             },
        ['brew']    = { anims = { Anim(Resources.brewUI.cauldronCanBrew), Anim(Resources.brewUI.cauldronBrewing) } },
        ['failed']  = { anim  = Anim(Resources.brewUI.cauldronFail)                                                }, 
        ['success'] = { anim  = Anim(Resources.brewUI.cauldronSuccess)                                             },
        ['present'] = { anim  = Anim(Resources.brewUI.cauldronPotion)                                              },
        ['choose']  = { anim  = Anim(Resources.brewUI.potion)                                                      },
    }

    self.state = 'idle'

    coreDebug:addWatch('cauldronAnimFrame', function()
        local text = 'No Anim'
        local state = self.states[self.state]
        if state then
            if state.anim then
                text = state.anim.frame
            elseif state.anims then
                text = ''
                for i,anim in ipairs(state.anims) do
                    local frameNumber = anim.frame
                    text = text .. frameNumber .. ' ' 
                end
            end
        end
        return text
    end)
end

function Cauldron:isAnimPlaying()
    local state = self.states[self.state]
    if state then
        if state.anim then
            return state.anim.isPlaying
        elseif state.anims then
            for i,anim in ipairs(state.anims) do
                if anim.isPlaying then return true end
            end
        end
    end
    
    return false
end

function Cauldron:setState(stateName) 
    self.state = stateName
    local state = self.states[self.state]
    if state then
        if state.anim then
            state.anim:play()
        elseif state.anims then
            for i,anim in ipairs(state.anims) do
                anim:play()
            end
        end
    end
end

function Cauldron:update(dt)
    local state = self.states[self.state]
    if state then
        if state.anim then
            state.anim:update(dt)
        elseif state.anims then
            for i, anim in ipairs(state.anims) do
                anim:update(dt)
            end
        end
    end
end

function Cauldron:draw(x, y)
    local state = self.states[self.state]
    if state then
        if state.anim then
            state.anim:draw(x, y)
        elseif state.img then
            love.graphics.draw(state.img, x, y)
        elseif state.anims then
            for i, anim in ipairs(state.anims) do
                anim:draw(x, y)
            end
        end
    end
end

return Cauldron