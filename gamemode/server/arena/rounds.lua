local gamemeta = PK.gamemeta

function gamemeta:AddRound(roundName, time, callbackFinish)
	if self.round[roundName] == nil then self.round[roundName] = {} end

	table.insert(self.round[roundName], {
		time = time,
		callback = callbackFinish or function() end,
	})
end

function gamemeta:StartRound(roundName, startCallback)
	self.round.currentSubRound = 1

	self:AdvanceRound(roundName)

	if startCallback != nil then
		startCallback(self.arena, roundName)
	end

end

function gamemeta:AdvanceRound(roundName)
	local name = tostring(self) .. roundName .. self.round.currentSubRound
	
	timer.Create(name, self.round[roundName][self.round.currentSubRound].time, 1, function()
		self.round[roundName][self.round.currentSubRound].callback(self.arena)

		if #self.round[roundName] > self.round.currentSubRound then
			self.round.currentSubRound = self.round.currentSubRound + 1
			self:AdvanceRound(roundName)
		end
	end)

	self.round.currentRound = name
end

function gamemeta:AbortRound(roundName)
	timer.Remove(self.round.currentRound)
	self.round[roundName][self.round.currentSubRound].callback(self.arena)
end
