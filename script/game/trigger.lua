-- trigger.lua
--  babyjeans
--
-- triggers for entities to respond to
---

---
local Trigger = class('Trigger')
function Trigger:init(name, params)

    self.x = params.x
    self.y = params.y
    self.w = params.w
    self.h = params.h

    self.onTriggerEnter = params.onTriggerEnter or function() end
    self.onTriggerExit  = params.onTriggerExit or function() end
    self.onTrigger      = params.onTrigger or function() end
    self.onChunkEnter   = params.onChunkEnter or function() end
    self.onChunkExit    = params.onChunkExit or function() end
end

return Trigger