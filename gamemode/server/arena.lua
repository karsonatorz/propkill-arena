local arenameta = {}
arenameta.__index = arenameta

PK.arenameta = arenameta

arenameta.players = {}
arenameta.props = {}
arenameta.gamemode = {}
arenameta.hooks = {}
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
	local newarena = setmetatable({}, arenameta)

	//newarena.name = data.name or "Arena"
	//newarena.spawns = data.spawns or {}
	//newarena.maxplayers = data.maxplayers or 0


	//hook setup

	return newarena
end

// ==== Arena Player Management ==== \\

function arenameta:AddPlayer(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end

	local canjoin, reason = self:CallGameHook("PlayerJoinArena", ply)
	if not canjoin then
		print(reason)
		return false
	end

	if ply.arena != nil then 
		ply.arena:RemovePlayer(ply)
	end

	self.players[ply:UserID()] = ply
	ply.arena = self
	ply:Spawn()
	self:CallGameHook("PlayerJoinedArena", ply)
	return true
end

function arenameta:RemovePlayer(ply, silent)
	if ply.arena == nil then return end

	if not silent then
		self:CallGameHook("PlayerLeaveArena", ply)
	end

	if IsValid(ply.team) then
		ply.team:RemovePlayer(ply)
	end

	ply.arena = nil
	self.players[ply:UserID()] = nil
end


// ==== Arena Hooks ==== \\

function arenameta:CallGameHook(event, ...)
	local gm = self.gamemode
	if not IsValid(gm) then return false end

	if gm.hooks.customHooks[event] == nil then
		error("Attempt to call non-existent gamemode hook", 2)
		return
	end

	return gm.hooks.customHooks[event](self, ...)
end


// ==== Arena Util ==== \\

function arenameta:SetGamemode(gm, keepPlayers)
	if not IsValid(gm) then return end

	if IsValid(self.gamemode) then
		self:CallGameHook("TerminateGame", v)
	end

	self:Cleanup()
	self.gamemode = gm
	gm.arena = self

	self:CallGameHook("InitializeGame", v)

	if keepPlayers then 
		for k,v in pairs(self.players) do
			local canjoin, reason = self:CallGameHook("PlayerJoinArena", v)

			if canjoin then
				self:CallGameHook("PlayerJoinedArena", v)
			end
		end
	else
		for k,v in pairs(self.players) do
			self:RemovePlayer(v)
		end
	end
end

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




arena1 = PK.NewArena()

game1 = PK.NewGamemode("oog")

team1 = game1:CreateTeam("nigs", Color(255,0,0))
team2 = game1:CreateTeam("jews", Color(0,255,0))

game1:AddRound("test", 10, function(arena)
	for k,v in pairs(arena.players) do
		//v:Spawn()
		v:ChatPrint("warmup over")
		v:ChatPrint("game starting")
	end
	//arena:Cleanup()
end)

game1:AddRound("test", 30, function(arena)
	for k,v in pairs(arena.players) do
		v:ChatPrint("game over")
	end
end)

game1:Hook("PlayerJoinedArena", "ass", function(arena, ply)
	ply:ChatPrint("welcome to " .. (game1.name or "gamemode"))
end)

game1:Hook("PlayerSpawn", "nigger", function(arena, ply)
	if math.Round(math.random(0,1)) then
		team1:AddPlayer()
	else
		team2:AddPlayer()
	end
	local spawn = math.random(1, #arena.spawns.ffa)
	ply:SetPos(arena.spawns.ffa[spawn].pos)
	ply:SetEyeAngles(arena.spawns.ffa[spawn].ang)
end)

game1:Hook("InitializeGame", "fat", function(arena)
	game1:StartRound("test", function(arena)
		for k,v in pairs(arena.players) do
			//v:Spawn()
			team1:AddPoints(5)
			team1:AddPoints(-2)
			v:ChatPrint("warmup started " .. team1:TotalFrags() .. " " .. team1:TotalDeaths() .. " " .. team1:GetPoints())
		end
	end)
end)

arena1:SetGamemode(game1)

