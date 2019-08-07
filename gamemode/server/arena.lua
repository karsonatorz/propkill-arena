local arenameta = {}
arenameta.__index = arenameta

PK.arenameta = arenameta

arenameta.spawns = {
	ffa = {
		{ pos = Vector(6596.689453, -4628.974609, 471.107269), ang = Angle(0, -90, 0) },
		{ pos = Vector(7318.069824, -14784.813477, 471.107269), ang = Angle(0, 90, 0) },
	},
	duel = {
		{ pos = Vector(6596.689453, -4628.974609, 471.107269), ang = Angle(0, -90, 0) },
		{ pos = Vector(7318.069824, -14784.813477, 471.107269), ang = Angle(0, 90, 0) },
	}
}

include("arena/gamemodes.lua")

function PK.NewArena(data)
	local tbl = data or {}
	local arenatemplate = {
		name = tbl.name or "Arena",
		maxplayers = tbl.maxplayers or 0,
		//spawns = tbl.spawns or {},
		players = {},
		props = {},
		hooks = {},
		gamemode = {},
	}

	local newarena = setmetatable(arenatemplate, arenameta)

	//newarena.spawns = data.spawns or {}
	//newarena.maxplayers = data.maxplayers or 0

	return newarena
end

// ==== Arena Player Management ==== \\

function arenameta:AddPlayer(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end

	local canjoin, reason = self:CallGMHook("PlayerJoinArena", ply)
	if not canjoin then
		print(reason)
		return false
	end

	if IsValid(ply.arena) then
		ply.arena:RemovePlayer(ply)
	end

	self.players[ply:UserID()] = ply
	ply.arena = self
	ply:Spawn()
	self:CallGMHook("PlayerJoinedArena", ply)
	return true
end

function arenameta:RemovePlayer(ply, silent)
	if ply.arena == nil then return end

	if not silent then
		self:CallGMHook("PlayerLeaveArena", ply)
	end

	if IsValid(ply.team) then
		ply.team:RemovePlayer(ply)
	end

	ply.arena = nil
	self.players[ply:UserID()] = nil
end


// ==== Arena Hooks ==== \\

function arenameta:CallGMHook(event, ...)
	local gm = self.gamemode
	if not IsValid(gm) then return false end

	if gm.hooks.customHooks[event] == nil then
		error("Attempt to call non-existent gamemode hook", 2)
		return
	end

	return gm.hooks.customHooks[event](self, ...)
end


// ==== Arena Gamemode ==== \\

function arenameta:SetGamemode(gm, keepPlayers)
	if not IsValid(gm) then return end

	self:GamemodeCleanup()
	self.gamemode = gm

	for k,v in pairs(gm.userHooks) do
		if gm.hooks.customHooks[k] == nil then
			self.hooks[k] = tostring(self)

			hook.Add(k, tostring(self), function(ply, ...)
				if not IsValid(self) then return end
				if ply.arena != self then return end

				for kk, vv in pairs(v) do
					local ret = vv(self, ply, ...)
					
					if type(ret) != "nil" then
						return ret
					end
				end
			end)
		end
	end

	self:CallGMHook("InitializeGame", v)

	if keepPlayers then
		for k,v in pairs(self.players) do
			local canjoin, reason = self:CallGMHook("PlayerJoinArena", v)
			if canjoin then
				self:CallGMHook("PlayerJoinedArena", v)
			end
		end
	else
		for k,v in pairs(self.players) do
			self:RemovePlayer(v)
		end
	end
end

function arenameta:GamemodeCleanup()
	if IsValid(self.gamemode) then
		self:CallGMHook("TerminateGame", v)
	end

	self:Cleanup()

	for k,v in pairs(self.hooks) do
		hook.Remove(k, v)
	end

	self.gamemode = nil
end

// ==== Arena Utility ==== \\

function arenameta:Cleanup()
	for k,v in pairs(self.props) do
		v:Remove()
	end
end

function arenameta:IsValid()
	return true
end

// ==== Arena Default Hooks ==== \\

hook.Add("PlayerDisconnected", "PK_Arena_PlayerDisconnect", function(ply)
	if IsValid(ply.arena) then
		ply.arena:RemovePlayer(ply)
	end
end)

hook.Add("SetupPlayerVisibility", "PK_Arena_SetupPlayerVisibility", function(ply)
	local arena = ply.arena

	if IsValid(arena) then
		for k,v in pairs(arena.players) do
			AddOriginToPVS(v:GetPos())
		end
		for k,v in pairs(arena.props) do
			AddOriginToPVS(v:GetPos())
		end
	end
end)

hook.Add("PlayerSpawnedProp", "PK_Arena_PlayerSpawnedProp", function(ply, model, ent)
	local arena = ply.arena

	if IsValid(arena) then
		ent.arena = arena
		table.insert(arena.props, ent:EntIndex(), ent)
	end
end)

hook.Add("EntityRemoved", "PK_Arena_EntityRemoved", function(ent)
	local arena = ent.arena

	if IsValid(arena) then
		arena.props[ent:EntIndex()] = nil
	end
end)



arena1 = arena1 or PK.NewArena()
game1 = PK.NewGamemode("oog")

game1:Hook("PlayerSpawn", "game1_playerpsawn", function(arena, ply)
	local spawn = math.random(1, #arena.spawns.ffa)
	ply:SetPos(arena.spawns.ffa[spawn].pos)
	ply:SetEyeAngles(arena.spawns.ffa[spawn].ang)
end)

game1:Hook("PlayerSpawnedProp", "game1_playerpsawn", function(arena, ply, model, ent)
	print(model)
end)

game1:Hook("PlayerJoinedArena", "asdasd", function(arena, ply)
	ply:ChatPrint("welcome 2 " .. game1.name)
end)

arena1:SetGamemode(game1, true)

/*

arena1 = PK.NewArena()
arena2 = PK.NewArena()

game1 = PK.NewGamemode("oog")

team1 = game1:CreateTeam("Team1", Color(255,0,0))
team2 = game1:CreateTeam("Team2", Color(0,255,0))

game1:AddRound("test", 10, function(arena)
	for k,v in pairs(arena.players) do
		//v:Spawn()
		v:ChatPrint("Warmup over")
		v:ChatPrint("Game starting")
	end
	//arena:Cleanup()
end)

game1:AddRound("test", 30, function(arena)
	for k,v in pairs(arena.players) do
		v:ChatPrint("Game over!")
	end
end)

game1:Hook("PlayerJoinedArena", "PK_Arena_PlayerJoined", function(arena, ply)
	ply:ChatPrint("Welcome to " .. arena.name .. ", now playing " .. game1.name or "gamemode")
end)

game1:Hook("PlayerSpawn", "game1_playerpsawn", function(arena, ply)
	if math.Round(math.random(0,1)) then
		team1:AddPlayer()
	else
		team2:AddPlayer()
	end
	local spawn = math.random(1, #arena.spawns.ffa)
	ply:SetPos(arena.spawns.ffa[spawn].pos)
	ply:SetEyeAngles(arena.spawns.ffa[spawn].ang)
end)

game1:Hook("InitializeGame", "game1_initializegame", function(arena)
	game1:StartRound("test", function(arena)
		for k,v in pairs(arena.players) do
			//v:Spawn()
			team1:AddPoints(5)
			team1:AddPoints(-2)
			v:ChatPrint("Warmup started " .. team1:TotalFrags() .. " " .. team1:TotalDeaths() .. " " .. team1:GetPoints())
		end
	end)
end)


arena1:SetGamemode(game1)*/