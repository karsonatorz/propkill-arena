local gamemeta = PK.gamemeta

function gamemeta:AddRound(roundName, time, callbackFinish)
	if roundName == nil or time == nil then error(roundName and "time is nil" or "round name is nil", 2) end
	if self.round[roundName] == nil then self.round[roundName] = {} end

	table.insert(self.round[roundName], {
		time = time,
		callback = callbackFinish or function() end,
	})
end

function gamemeta:StartRound(roundName, arena, startCallback)
	if roundName == nil or arena == nil then error(roundName and "arena is nil" or "round name is nil", 2) end
	arena.round.currentRound = roundName
	arena.round.currentSubRound = 1

	self:AdvanceRound(roundName, arena)

	if startCallback != nil then
		startCallback(arena)
	end

end

function gamemeta:AdvanceRound(roundName, arena)
	local name = tostring(arena) .. roundName .. arena.round.currentSubRound

	timer.Create(name, arena.round[roundName][arena.round.currentSubRound].time, 1, function()
		arena.round[roundName][arena.round.currentSubRound].callback(arena)

		if #arena.round[roundName] > arena.round.currentSubRound then
			arena.round.currentSubRound = arena.round.currentSubRound + 1
			self:AdvanceRound(roundName, arena)
		end
	end)

	arena.round.currentRound = roundName
end

function gamemeta:AbortRound(roundName, arena)
	timer.Remove(arena.round.currentRound)
	arena.round[roundName][arena.round.currentSubRound].callback(arena)
end

