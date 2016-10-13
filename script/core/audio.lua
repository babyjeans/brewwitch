-- audio.lua
--  babyeans
--
-- the result of making an audio manager late at night
---
local Audio = class ('coreAudio')
function Audio:init(audioResources)
	self.currentTracks = vector()
	self.foleyPlaying = vector()
end

function Audio:playTrack(track)
	love.audio.play(track)
	self.currentTracks:add(track)
end

function Audio:playFoley(foley)
end

return Audio()