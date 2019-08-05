/*
Rounds
*/

Round = {}
Round.__index = Round

function Round.__call(self, id)
	return Round:Create(id or nil)
end

setmetatable(Round, Round)

function Round:Create(id)
	local round = {}
	setmetatable(round, Round)
	round.timeRemaining = 0
	round.timeBased = true
	round.length = 1
	round.id = id or "PK_Round_Generic"
	round.warmupId = round.id .. "_Warmup"
	round.players = {}
	round.active = false
	round.warmup = true
	round.warmupLength = 1
	round.teamBased = false
	round.scoreBased = false -- score is used in CTF etc.
	round.teams = {}
	round.duel = false
	return round
end

function Round:GetPlayers()
	return self.players
end

function Round:AddPlayers(plys)
	if istable(plys) then
		for k,v in pairs(plys) do
			if IsValid(v) then
				table.insert(self.players, v)
			end
		end
	else
		if IsValid(plys) then
			table.insert(self.players, plys)
		end
	end
end

function Round:RemovePlayers(plys)
	if istable(plys) then
		for k,v in pairs(plys) do
			if IsValid(v) then
				table.remove(self.players, v)
			end
		end
	else
		if IsValid(plys) then
			table.remove(self.players, plys)
		end
	end
end

function Round:ChatPrint(...)
	for k,ply in pairs(self.players) do
		if IsValid(ply) then
			net.Start("pk_chatmsg")
				net.WriteTable({Color(255,0,0), ...})
			net.Send(ply)
		end
	end
end

function Round:TimeRemaining()
	return timer.TimeLeft(self.id)
end

function Round:ClearPlayerScores()
	for k,ply in pairs(self:GetPlayers()) do
		if IsValid(ply) then
			ply:SetDeaths(0)
			ply:SetFrags(0)
		end
	end
	if self.teamBased then
		for k,v in pairs(self.teams) do
			team.SetScore(v, 0)
		end
	end
end

function Round:Start()
	local function startRound()
		if self.timeBased then
			local function endRound()
				self:End()
			end
			timer.Create(self.id, self.length, 1, endRound)
		end
		self:ClearPlayerScores()
		self.timeRemaining = self.length
		self.active = true
		self:ChatPrint("Round started!")
	end

	local function startWarmup()
		self:ClearPlayerScores()
		timer.Create(self.warmupId, self.warmupLength, 1, startRound)
	end

	if self.warmup then
		startWarmup()
	else
		startRound()
	end
end

function Round:End()
	if timer.Exists(self.id) then
		timer.Remove(self.id)
	elseif timer.Exists(self.warmupId) then
		timer.Remove(self.warmupId)
	end

	self.timeRemaining = 0
	self.active = false

	self.results = {}
	if self.teamBased then
		for k,v in pairs(self.teams) do
			self.results[v] = {
				TeamScore = {team.GetScore(v)},
				TeamFrags = {team.TotalFrags(v)},
				TeamDeaths = {team.TotalDeaths(v)},
				PlayerKDs = {}
			}
			for k2,ply in pairs(team.GetPlayers(v)) do
				self.results[ply] = {PlayerKDs = {}}
				table.insert(self.results[ply]["PlayerKDs"], {
					[ply:SteamID()] = {
						Frags = ply:Frags(),
						Deaths = ply:Deaths()
					}
				})
			end
		end
	else
		self.results = {PlayerKDs = {}}
		for k,ply in pairs(self:GetPlayers()) do
			table.insert(self.results["PlayerKDs"], {
				SteamID = ply:SteamID(),
				Frags = ply:Frags(),
				Deaths = ply:Deaths()
			})
		end
	end

	self:ChatPrint("Round finished!")
	PrintTable(self:GetWinners())
end

local function getWinners(results, sortBy, sortOrder)
	local winners = {}
	table.SortByMember(results, sortBy, sortOrder or false)
	for k,v in pairs(results) do
		if v[sortBy] == results[1][sortBy] then
			table.insert(winners, v)
		end
	end
	return winners
end

function Round:GetWinners()
	if self.teamBased and not self.scoreBased then
		return getWinners(self.results["PlayerKDs"], "TeamDeaths", true)
	elseif self.teamBased and self.scoreBased then
		return getWinners(self.results["PlayerKDs"], "TeamScore")
	elseif not self.teamBased and not self.duel then
		return getWinners(self.results["PlayerKDs"], "Frags")
	elseif not self.teamBased and self.duel then
		return getWinners(self.results["PlayerKDs"], "Deaths", true)
	end
end