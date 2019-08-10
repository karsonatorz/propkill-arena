local gamemeta = PK.gamemeta

function gamemeta:AddRound(roundName, time, callbackFinish)
	if self.round[roundName] == nil then self.round[roundName] = {} end

	table.insert(self.round[roundName], {
		time = time,
		callback = callbackFinish or function() end,
	})
end

function gamemeta:StartRound(roundName, arena, startCallback)
	arena.gmvars.round.currentSubRound = 1

	self:AdvanceRound(roundName, arena)

	if startCallback != nil then
		startCallback(arena)
	end

end

function gamemeta:AdvanceRound(roundName, arena)
	local name = tostring(arena) .. roundName .. arena.gmvars.round.currentSubRound

	timer.Create(name, arena.gmvars.round[roundName][arena.gmvars.round.currentSubRound].time, 1, function()
		arena.gmvars.round[roundName][arena.gmvars.round.currentSubRound].callback(arena)

		if #arena.gmvars.round[roundName] > arena.gmvars.round.currentSubRound then
			arena.gmvars.round.currentSubRound = arena.gmvars.round.currentSubRound + 1
			self:AdvanceRound(roundName, arena)
		end
	end)

	arena.gmvars.round.currentRound = name
end

function gamemeta:AbortRound(roundName, arena)
	timer.Remove(arena.gmvars.round.currentRound)
	arena.gmvars.round[roundName][arena.gmvars.round.currentSubRound].callback(arena)
end

