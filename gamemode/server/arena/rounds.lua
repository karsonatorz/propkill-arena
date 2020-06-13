local gamemeta = PK.gamemeta
//Class: Gamemode

/*
	Function: Gamemode:AddRound()
	Adds a round to the gamemode

	Parameters:
		name: string - The name of the round
		time: number - The length of the round
		callback: function - The callback function ran when the round ends
*/
function gamemeta:AddRound(roundName, time, callbackFinish)
	if roundName == nil or time == nil then error(roundName and "time is nil" or "round name is nil", 2) end
	if self.round[roundName] == nil then self.round[roundName] = {} end

	table.insert(self.round[roundName], {
		time = time,
		callback = callbackFinish or function() end,
	})
end

/*
	Function: Gamemode:StartRound()
	Adds a round to the gamemode

	Parameters:
		name: string - The name of the round
		arena: <Arena> - The arena to start the round in
		callback: function - The callback function ran when the round starts
*/
function gamemeta:StartRound(roundName, arena, startCallback)
	if roundName == nil or arena == nil then error(roundName and "arena is nil" or "round name is nil", 2) end
	arena.round.currentRound = roundName
	arena.round.currentSubRound = 1

	self:AdvanceRound(roundName, arena)

	if startCallback != nil then
		startCallback(arena)
	end

end

/*
	Function: Gamemode:AdvanceRound()
	Will advance the current rounds sub round. 
	
	i.e. say the round ended but you want people to be alive for a bit longer, you could advance to a sub round for a few seconds before moving onto the next round

	*incomplete* I'm not 100% sure this works yet

	Parameters:
		name: string - The name of the round
		arena: <Arena> - The arena to start the round in
		callback: function - The callback function ran when the round starts
*/
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

/*
	Function: Gamemode:AbortRound()
	Will abort the current round

	Parameters:
		name: string - The name of the round
		arena: <Arena> - The arena to start the round in
*/
function gamemeta:AbortRound(roundName, arena)
	timer.Remove(arena.round.currentRound)
	arena.round[roundName][arena.round.currentSubRound].callback(arena)
end

