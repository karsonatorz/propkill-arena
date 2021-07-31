local obll = PK.NewGamemode({
	name = "Oddball",
	abbr = "obll",
	spawnset = "ffa",
	maxplayers = 0
})

obll:CreateTeam("Deathmatch", Color(0, 255, 0))
obll:CreateTeam("Leader", Color(255, 215, 0))

local times = {}
local leader = NULL

local function coolTimer()
	if IsValid(leader) then
		local gm = leader.arena.gamemode
		if times[leader:EntIndex()] > 60 && gm.round.currentRound == "game" then
			gm:AdvanceRound()
		end

		if not times[leader:EntIndex()] then times[leader:EntIndex()] = 0 end

		times[leader:EntIndex()] = times[leader:EntIndex()] + 1 // increment :)
	end
end

local function notifyTime(gm, new)
	for k,v in pairs(gm.arena.players) do
		v:ChatPrint(string.format("[Oddball] %s is the new leader! (previously %s with %ds)", new:Nick(), (IsValid(leader) and leader:Nick() or "Nobody"), (IsValid(leader) and tostring(times[leader:EntIndex()]) or "0")))
	end
end

obll:AddRound("warmup", 3, function(self)
	self.arena:Cleanup()
	local t = self:GetTeam("Deathmatch")
	
	times = {}
	leader = NULL
	if timer.Exists("obll_Timer") then timer.Destroy("obll_Timer") end

	for k,v in pairs(self.arena.players) do
		times[v:EntIndex()] = 0
		t:AddPlayer(v)
		v:Spawn()
		self:SpawnPlayer(v)
		v:GodEnable()
		v:ChatPrint("[Oddball] Starting in 3 seconds...")
	end
end,
function(self)
	self.arena.gmvars.gamestarted = true

	for k,v in pairs(self.arena.players) do
		v:GodDisable()
		v:ChatPrint("[Oddball] GO!")
	end

	timer.Create("obll_Timer", 1, 0, coolTimer)

	self:StartRound("game")
end)

obll:AddRound("game", 300, function(self) end, function(self)
	self.arena.gmvars.gamestarted = false
	for k,v in pairs(self.arena.players) do
		v:ChatPrint("[Oddball] " .. (IsValid(leader) and leader:Nick() or "Nobody") .. " won!")
	end

	self:AdvanceRound()
end)

obll:AddRound("game", 4, function() end, function(self)
	self:StartRound("warmup")
end)

// hooks
obll:Hook("PlayerSpawn", "obll_PlayerSpawn", function(self, ply)
	self:SpawnPlayer(ply)
end)

obll:Hook("PlayerJoinedArena", "obll_PlayerJoinedArena", function(self, ply)
	self:GetTeam("Deathmatch"):AddPlayer(ply)

	if not self.arena.gmvars.gamestarted and table.Count(self.arena.players) > 1 then
		self:StartRound("warmup")
	elseif not self.arena.gmvars.gamestarted then
		for k,v in pairs(self.arena.players) do
			v:ChatPrint("waiting on 1 more player")
		end
	end

	if self.round.currentRound == "warmup" then
		self:SpawnPlayer(ply)
		ply:GodEnable()
	else
		ply:KillSilent()
		self:SpawnAsSpectator(ply)
	end
end)

obll:Hook("PlayerDeath", "obll_PlayerDeath", function(self, victim, inflictor, attacker)
	self.arena:Cleanup(victim)
	
	if not self.arena.gmvars.gamestarted then return end

	if victim == attacker and victim == leader then
		for k,v in pairs(self.arena.players) do
			v:ChatPrint(string.format("[Oddball] %s has suicided with %ds!\nThe next kill will be the leader!", victim:Nick(), times[victim:EntIndex()]))
		end
		self:GetTeam("Deathmatch"):AddPlayer(victim)
		leader = NULL
		return 
	end
	
	if victim != attacker and (victim == leader or leader == NULL) then
		self:GetTeam("Deathmatch"):AddPlayer(victim)
		self:GetTeam("Leader"):AddPlayer(attacker)
		notifyTime(self, attacker)
		leader = attacker
	end
end)

obll:Hook("PostPlayerDeath", "obll_postdeath", function(self, ply)
	if self.arena.gmvars.alive == 1 and self.round.currentRound == "game" then
		self:AdvanceRound()
	end
end)

obll:Hook("PlayerLeaveArena", "obll_PlayerLeaveArena", function(self, ply)
	self.arena:Cleanup(ply)
end)

obll:Hook("InitializeGamemode", "obll_init", function(self) 
	self.arena.gmvars.begun = false
end)