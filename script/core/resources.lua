-- resources.lua
--	babyjeans
--
-- a wrapper / manager of sorts to keep shit.
---
local loadedStages = { }
resources = { }

---
-- loader functions
--

function processAudioSource(audioSource, params) 
	params = params or { }
	if params.loop then
		audioSource:setLooping(true)
	else
		audioSource:setLooping(GameSettings.Defaults.AudioLoop or false)
	end
end

function loadAnimation(texture, frameCount, fps, looping)
	texture = love.graphics.newImage(texture)
	local textureWidth = texture:getWidth()
	local textureHeight = texture:getHeight()
	local frameW = textureWidth / frameCount
	local frameH = textureHeight
	local frames = { }
	local x = 0
	for i=1,frameCount do
		frames[#frames+1] = love.graphics.newQuad(x, 0, frameW, frameH, textureWidth, textureHeight)
		x = x + frameW
	end
	if looping == nil then looping = true end

	return {
		texture = texture,
		frameCount = frameCount,
		frameW = frameW,
		frameH = frameH,
		frames = frames,
		fps = fps or 30,
		looping = looping,
	}
end

---
-- implementation
--

function resources.loadStage(stage)
	if not stage or not ResourceList[stage] then
		coreDebug:warn('resources', 'unable to load stage: ' .. stage .. '. it does not exist')
		return
	end

	resources[stage] = { }
	for key, resource in pairs(ResourceList[stage]) do
		if resource[1] == 'font' then
			resources[stage][key] = love.graphics.newFont(resource[2], resource[3])
		elseif resource[1] == 'image' then
			resources[stage][key] = love.graphics.newImage(resource[2])
		elseif resource[1] == 'animation' then			
			resources[stage][key] = loadAnimation(resource[2], resource[3], resource[4], resource[5])
		elseif resource[1] == 'track' then
			local newAudioSource = love.audio.newSource(resource[2], 'stream')
			resources[stage][key] = newAudioSource
			processAudioSource(newAudioSource, resource[3])
		elseif resource[1] == 'foley' then
			local newAudioSource = love.audio.newSource(resource[2], 'static')
			resources[stage][key] = newAudioSource
			processAudioSource(newAudioSource, resource[3])
		end
	end

	loadedStages[#loadedStages + 1] = stage
end

function resources.unloadStage(stage)
	for i, stageName in ipairs(loadedStages) do
		if stageName == stage then
			table.remove(loadedStages, i)
			resources[stage] = { } -- anything with a reference to resources still has them at this point though
			return
		end
	end
end

---

return resources