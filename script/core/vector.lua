-- vector.lua
--	babyjeans
--
-- just a wrapper container for conveinence
---
local vector = class('coreVector')
function vector:init()
	self.contents = { }
end

---
-- size
--

function vector:empty() return #self.contents == 0 end
function vector:count() return #self.contents end

---
-- container manipulation
--

function vector:add(item)
	local count = #self.contents
	self.contents[count + 1] = item
end

function vector:addUnique(item)
	for i, val in ipairs(self.contents) do
		if val == item then return end	
	end

	self:add(item)
end

function vector:remove(item)
	for i, val in ipairs(self.contents) do
		if val == item then table.remove(self.contents, i) end
	end
end

function vector:removeIndex(index)
	return table.remove(self.contents, index)
end

function vector:insert(index, item)
	table.insert(index, item)
end

function vector:clear() 
	self.contents = { } 
end

---
-- container iteration
--

function vector:forEach(func)
    for i, node in ipairs(self.contents) do
        func(node)
    end
end

function vector:swap(index1, index2)
	local thing = self.contents[index1]
	self.contents[index1] = self.contents[index2]
	self.contents[index2] = thing
end


---

return vector