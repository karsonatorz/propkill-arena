local gamemeta = PK.gamemeta
//Class: Gamemode

/*
	Function: Gamemode:AddRound()
	Adds a round to the gamemode

	Parameters:
		name: string - The name of the round
		time: number - The length of the round
		startCallback: function - The callback function ran when the round starts
		endCallback: function - The callback function ran when the round ends
*/
function gamemeta:AddRound(roundName, time, startCallback, endCallback)
	if roundName == nil or time == nil then error(roundName and "time is nil" or "round name is nil", 2) end
	if self.round[roundName] == nil then self.round[roundName] = {} end

	table.insert(self.round[roundName], {
		time = time,
		startCallback = startCallback or function() end,
		endCallback = endCallback or function() end,
	})
end

/*
	Function: Gamemode:StartRound()
	Adds a round to the gamemode

	Parameters:
		name: string - The name of the round
*/
function gamemeta:StartRound(roundName)
	if roundName == nil or self.arena == nil then error(roundName and "arena is nil" or "round name is nil", 2) end

	if timer.Exists(self.round.currentRoundTimer or "") then
		timer.Remove(self.round.currentRoundTimer)
	end

	self.round.currentRound = roundName
	self.round.currentSubRound = 1

	self:AdvanceRound()
end

/*
	Function: Gamemode:AdvanceRound()
	Will advance the current rounds sub round. 
	
	i.e. say the round ended but you want people to be alive for a bit longer, you could advance to a sub round for a few seconds before moving onto the next round
*/
function gamemeta:AdvanceRound()
	local curRound = self.round.currentRound
	local subRound = self.round.currentSubRound or 1
	local curTimer = self.round.currentRoundTimer or ""

	// if AdvanceRound is called early
	// for some reason the timer still exists after the callback so we'll check timeleft to see if it's actually over
	if timer.Exists(curTimer) and timer.TimeLeft(curTimer) then
		print("timer exists, removing")
		timer.Remove(curTimer)
		self.round[curRound][subRound].endCallback(self)
		
		if #self.round[curRound] > subRound then
			self.round.currentSubRound = subRound + 1
			subRound = self.round.currentSubRound
		else
			return 
		end
	end

	local name = tostring(self.arena) .. curRound .. self.round.currentSubRound
	timer.Create(name, self.round[curRound][self.round.currentSubRound].time, 1, function()
		self.round[curRound][subRound].endCallback(self)
		
		// if curRound is different to currentRound then the user has changed the round manually and we shouldn't increment
		if curRound == self.round.currentRound and #self.round[self.round.currentRound] > self.round.currentSubRound then
			self.round.currentSubRound = self.round.currentSubRound + 1
			self:AdvanceRound()
		end
	end)

	self.round.currentRoundTimer = name
	self.round[curRound][self.round.currentSubRound].startCallback(self)

end

/*
	Function: Gamemode:AbortRound()
	Will abort the current round

	Parameters:
		shouldCallback: boolean - Should we call the end callback?
*/
function gamemeta:AbortRound(shouldCallback)
	timer.Remove(self.round.currentRoundTimer)
	if shouldCallback then
		self.round[self.round.currentRound][self.round.currentSubRound].endCallback(self)
	end
end
