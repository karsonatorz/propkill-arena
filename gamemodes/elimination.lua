local elim = PK.NewGamemode({
	name = "Elimination",
	abbr = "elim",
	spawnset = "ffa",
	maxplayers = 0
})
 
elim:CreateTeam("Alive", Color(0, 255, 0))
elim:CreateTeam("Dead", Color(128, 128, 128))
 
// temp settings - should probably be settable when making the arena
local starting = false
local minPlayers = 2
local waitTime = 5     // seconds ("intermission time")
 
// helpers
local function PKPrint(plys, ...) // maybe make a centralized netmsg chat.AddText thing? - found the funcs in base.lua just too lazy to fix
	for k,v in pairs(plys) do
		if IsValid(v) then
			v:ChatPrint("[PK-A] - " .. unpack({...}))
		end
	end
end
 
local function IsArenaValid(self)
	local alive = self:GetTeam("Alive")
   
	return table.Count(alive.players) <= 2
end
 
// functions
local function StartRound(self)
	PKPrint(self.arena.players, "Round started!")
 
	local alive = self:GetTeam("Alive")
	for k,v in pairs(self.arena.players) do
		alive:AddPlayer( v)
		v:SetTeam(TEAM_DEATHMATCH)
		v:UnSpectate()
		v:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		v:SetSolid(SOLID_BBOX)
		v:Spawn()
		v.spectating = nil
		self:SpawnPlayer(v, "ffa", "Deathmatch")
	end

	starting = false
end
 
// hooks
elim:Hook("PlayerSpawn", "elim_PlayerSpawn", function(self, ply)
	if ply:Team() == TEAM_SPECTATOR then
		ply:StripWeapons()
	elseif ply.team.name == "Alive" then
		self:SpawnPlayer(ply, "ffa", "Deathmatch")
	end
	
end)
 
elim:Hook("PlayerJoinedArena", "elim_PlayerJoinedArena", function(self, ply)
	if #self.arena.players < minPlayers then
		PKPrint(self.arena.players, string.format("%d/%d required players to play.", #self.arena.players, minPlayers))
	end
   
	local dead = self:GetTeam("Dead")
	dead:AddPlayer(ply)

	if IsArenaValid(self) and not starting then
		starting = true
		PKPrint(self.arena.players, string.format("Starting a new round of elimination in %d seconds.", waitTime))
   
		timer.Simple(waitTime, function() StartRound(self) end)
	end
end)
 
elim:Hook("PlayerDeath", "elim_PlayerDeath", function(self, ply)
	self.arena:Cleanup(ply)
 
	local alive = self:GetTeam("Alive")
	local dead = self:GetTeam("Dead")
	dead:AddPlayer(ply)
	ply.NextArenaSpawnTime = CurTime() + 99999

	timer.Simple(2, function()
		self:SpawnAsSpectator(ply)
	end)

	if IsArenaValid(self) then
		starting = true
		local alivePlayers = alive.players
		if table.Count(alivePlayers) == 1 then
			PKPrint(self.arena.players, string.format("%s won elimination!\nStarting a new round in %d seconds!", alivePlayers[next(alivePlayers)]:Nick(), waitTime))
			timer.Simple(waitTime, function() StartRound(self) end)
		end
		
	end
end)
 
elim:Hook("PlayerLeaveArena", "elim_PlayerLeaveArena", function(self, ply)
	self.arena:Cleanup(ply)
end)
