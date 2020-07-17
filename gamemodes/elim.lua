local elim = PK.NewGamemode({
	name = "Elimination2",
	abbr = "elim2",
	spawnset = "ffa",
	maxplayers = 0
})

elim:CreateTeam("Deathmatch", Color(0, 255, 0))

elim:AddRound("warmup", 3, function(self)
	local t = self:GetTeam("Deathmatch")

	for k,v in pairs(self.arena.players) do
		t:AddPlayer(v)
		v:Spawn()
		self:SpawnPlayer(v)
		v:GodEnable()
		v:ChatPrint("[Elimination] Starting in 3 seconds...")
	end
	self.arena.gmvars.begun = false
end,
function(self)
	self.arena.gmvars.gamestarted = true

	for k,v in pairs(self.arena.players) do
		v:GodDisable()
		v:ChatPrint("[Elimination] GO!!")
	end
	self.arena.gmvars.alive = table.Count(self.arena.players)
	self:StartRound("game")
end)

local function getAlive(arena)
	local alive = {}
	for k,v in pairs(arena.players) do
		if v:Alive() then
			table.insert(alive, v)
		end
	end

	return alive
end

elim:AddRound("game", 300, function(self) end, function(self)
	if self.arena.gmvars.alive == 1 then
		self.arena.gmvars.gamestarted = false
		for k,v in pairs(self.arena.players) do
			v:ChatPrint("[Elimination] " .. getAlive(self.arena)[1]:Nick() .. " won!!!")
		end
		PrintTable(getAlive(self.arena))
		self:AdvanceRound()
	end
end)

elim:AddRound("game", 4, function() end, function(self)
	self:StartRound("warmup")
end)


// hooks
elim:Hook("PlayerSpawn", "elim_PlayerSpawn", function(self, ply)
	self:SpawnPlayer(ply)
end)

elim:Hook("PlayerJoinedArena", "elim_PlayerJoinedArena", function(self, ply)
	self:GetTeam("Deathmatch"):AddPlayer(ply)

	print(not self.arena.gmvars.begun, table.Count(self.arena.players) > 1)
	if not self.arena.gmvars.begun and table.Count(self.arena.players) > 1 then
		self.arena.gmvars.begun = true
		self:StartRound("warmup")
	else
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

elim:Hook("PlayerDeath", "elim_PlayerDeath", function(self, ply)
	self.arena:Cleanup(ply)
	self.arena.gmvars.alive = self.arena.gmvars.alive - 1
	ply.NextArenaSpawnTime = CurTime() + 9999999

	timer.Simple(1, function()
		self:SpawnAsSpectator(ply)
	end)
	print("playerdeath HOOKED", ply:Alive())
end)

elim:Hook("PostPlayerDeath", "elim_postdeath", function(self, ply)
	print("POSTPLAYERDEATH", self.arena.gmvars.alive, self.round.currentRound)
	if self.arena.gmvars.alive == 1 and self.round.currentRound == "game" then
		self:AdvanceRound()
	end
end)

elim:Hook("PlayerLeaveArena", "elim_PlayerLeaveArena", function(self, ply)
	self.arena:Cleanup(ply)
	if ply:Alive() then
		self.arena.gmvars.alive = self.arena.gmvars.alive - 1
	end
end)

elim:Hook("InitializeGamemode", "elim_init", function(self)
	print("InitializeGamemode")
	self.arena.gmvars.alive = table.Count(self.arena.players)
	self.arena.gmvars.begun = false
end)


