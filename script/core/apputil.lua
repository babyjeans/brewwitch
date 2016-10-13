-- apputil.lua
--   babyjeans
--
---
return {

	----
	--- addHook(self, hookName)
	--- simple listener / sync system to be attached to any object for convenience
	--- pass it an instance object and name to refer hooks with.
	--    adds
	--    *  self.[hookName]Hooks vector
	--    *  hook[hookName] / unhook[hookname] - add / remove a function call
	--    *  call[hookname] - will return from the call if a hook function returns true
	---

	addHook = function(self, hookName)
		local hookVec = vector()
		self[hookName .. 'Hooks'] = hookVec
		self['hook' .. hookName] = function(self, hook) hookVec:addUnique(hook) ; return hook  end
		self['unhook' .. hookName] = function(self, hook) return hookVec:remove(hook) end
		self['call' .. hookName] = function(self, ...) for i, func in ipairs(hookVec.contents) do if func(...) then return end end end
	end,

	----
	--- addTableHelpers()
	--- table helpers
	--- adds functionality to the table Lua object for convenience
	--
	-- findIndex(t, elem) - return index of elem in t 
	-- removeIndexedMatching(t, matchFunc, (opt)removeMultiple) - iterate over t, calling matchFunc on each e. removes anything func returns true for
	-- removeIndexedElem(t, elem, (opt)removeMultiple) - remove 'elem' from the array t 
	-- clone(dst, srt) - attempt at deep copy of src into dst
	-- cloneR(dst, src) - attempt at deep copy of src into dst, using recursion as opposed to a list
	--

	addTableHelpers = function() 
		table.findIndex = function(t, elem)
			for i, e in ipairs(t) do if elem == e then return i end end
		end

		table.removeIndexedMatching = function(t, matchFunc, removeMultiple)
			local r = { }
			if removeMultiple == nil or removeMultiple then
				for i, e in ipairs(t) do if matchFunc(e) then r[#r+1]=i end end
				for i, j in ipairs(r) do table.remove(t, j) end
			else
				for i, e in ipairs(t) do if matchFunc(e) then table.remove(t, i); return end end
			end
		end

		table.removeIndexedElem = function(t, elem, removeMultiple)
			local m = removeMultiple
			local r = { }
			if removeMultiple then table.removeIndexedMatching(t, function(e) return elem == e end) 
			else 
				for i, e in ipairs(t) do 
					if elem == e then 
						if not removeMultiple then table.remove(t, i); return end
						r[#r+1]=i 
					end
				end	
			end
		end

		-- memory intensive version of clone
		table.clone = function(dst, src)
			local tables = { { dst, src } }
			while #tables > 0 do
				local cdst = tables[1][1]
				local csrc = tables[1][2]

				for key, value in pairs(csrc) do
					if type(value) == 'table' then dst[key] = { } ;  tables[#table+1] = { { dst[key], value } }
					else dst[key] = value end
				end

				table.remove(tables, 1)
			end
		end

		-- recursive verison of clone
		table.cloneR = function(dst, src)
			for key, value in pairs(src) do
				if type(value) == 'table' then dst[key] = { } ; table.clone(dst[key], value)
				else dst[key] = value end
			end
		end

		table.rim = table.removeIndexedMatching
		table.rie = table.removeIndexedElem
	end
}