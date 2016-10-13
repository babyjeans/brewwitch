-- input.lua
--  babyjeans
--
-- input from your baby
---
local Input = class('coreInput')

--- 
-- hook prototypes
--
local pressedHook = function(key, scancode, isrepeat) end
local releasedHook = function(key, scancode) end

----
--- coreInput defintion
--
--

function Input:init(controlMap)
	Input.inputInstance = self
	
	-- sink our hooks
	if love then
		love.keypressed = self.onKeyPressed
		love.keyreleased = self.onKeyReleased
	end

	-- hooks
	AppUtil.addHook(self, 'Pressed')
	AppUtil.addHook(self, 'Released')
	
	-- lookups
	self.actionToKey = { }	
	self.keyToAction = { }		
	self.actions = vector()

	-- setup control map
	self:updateControlMap(controlMap)
end

---
-- key / action conversion
--

function Input:convertKey(key)
	local action = self.keyToAction[key]
	return action 
end

function Input:convertAction(action, retrieveCopy)
	local keys = self.actionToKey[action]
	if not keys then 
		return
	end

	if retrieveCopy or retrieveCopy == nil then
		local returnKeys = { }
		for i, key in ipairs(keys) do
			returnKeys[i]=key
		end
		
		return returnKeys
	else
		return keys
	end
end

function Input:updateControlMap(controlMap)
	self.actionToKey = { }
	self.keyToAction = { }	

	if not controlMap then
		return
	end

	for actionName, keys in pairs(controlMap) do
		local action = actionName:lower()		
		local actionKeys = self.actionToKey[action] or { }
		
		for keyIndex, key in ipairs(keys) do
			local keyName = key:lower()
			-- associate each key with this action
			actionKeys[#actionKeys+1]=keyName
			
			-- assocation action to key
			local keyActions = self.keyToAction[keyName] or { is = function(self, action) for i, actionName in ipairs(self) do if actionName == action then return true end end end } 
			keyActions[#keyActions+1] = action
			self.keyToAction[keyName] = keyActions
 		end

 		-- make sure the table set set
		self.actionToKey[action] = actionKeys
	end
end

---
-- key / action checks
--

function Input:isActionDown(action)
	if type(action) == 'string' then
		for i, actionName in ipairs(self.actions.contents) do 
			if actionName == action then return true end
		end
	else for i, actionName in ipairs(action) do
		if self:isActionDown(actionName) then return true end
	end end

	return false
end

function Input:isKeyDown(key)
	return love.keyboard.isDown(key)
end

function Input:isScancodeDown(scancode)
	return love.keybaord.isScancodeDown(scancode)
end

---
-- love input handlers
--

function Input.onKeyPressed(key, scancode, isrepeat)
	local self = Input.inputInstance

	local action = self:convertKey(key)
	if action then
		for i, actionName in ipairs(action) do 
			self.actions:addUnique(actionName)
		end
	end

	self:callPressed(key, scancode, isrepeat)
end

function Input.onKeyReleased(key, scancode)
	local self = Input.inputInstance
	
	local action = self:convertKey(key)
	if action and self:isActionDown(action) then
		for i, actionName in ipairs(action) do 
			self.actions:remove(actionName)
		end
	end

	self:callReleased(key, scancode)
end

---

return Input()