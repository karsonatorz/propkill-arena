local arenameta = {}
arenameta.__index = arenameta

PK.arenameta = arenameta

arenameta.team = {}
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

include("net.lua")
include("gamemodes.lua")

// ==== Arena Player Management ==== \\

function arenameta:AddPlayer(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end

	if ply.arena == self then
		return false, "already in arena"
	end

	local canjoin, reason = self:CallGMHook("PlayerJoinArena", ply)
	if not canjoin then
		dprint(reason)
		return false, reason
	end

	if IsValid(ply.arena) then
		ply.arena:RemovePlayer(ply)
	end

	ply.arena = self
	ply:SetTeam(TEAM_DEATHMATCH)

	self.players[ply:UserID()] = ply
	self:NWPlayer(ply)
	self:CallGMHook("PlayerJoinedArena", ply)
	ply:SetNWString("arena", tostring(self))

	ply:Spawn()

	return true
end

function arenameta:RemovePlayer(ply, silent)
	if ply.arena == nil then return end

	if not silent then
		self:CallGMHook("PlayerLeaveArena", ply)
	end

	if IsValid(ply.team) then
		ply.team:RemovePlayer(self, ply)
	end

	ply.arena = nil
	self.players[ply:UserID()] = nil

	self:NWPlayer(ply, true)
	ply:SetNWString("arena", nil)

	ply:Spawn()
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

	// cleanup anything left from the previous gamemode
	self:GamemodeCleanup()
	self.gamemode = gm

	// initialize all the users hooks from the gamemode
	for k,v in pairs(gm.userHooks) do
		// check that it isnt an arena hook
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

	// setup rounds
	for k,v in pairs(gm.round) do
		self.round[k] = v
	end

	// setup teams
	for k,v in pairs(gm.teams) do
		self.teams[k] = setmetatable(table.Copy(v), PK.teammeta)
	end

	// tell the gamemode to initialize
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

	self:SetNWVar("gamemode", self:GetInfo().gamemode)
end

function arenameta:GamemodeCleanup()
	if IsValid(self.gamemode) then
		self:CallGMHook("TerminateGame", v)
	end

	self:Cleanup()

	for k,v in pairs(self.hooks) do
		hook.Remove(k, v)
	end

	self.gamemode = {}
	self.gmvars = {}
	self.round = {}
	self.teams = {}
end

// ==== Arena Utility ==== \\

function arenameta:GetInfo()
	local data = {
		name = self.name,
		icon = self.icon,
		maxplayers = self.maxplayers,
		players = self.players,
		props = self.props,
		teams = self.teams,
		round = {
			currentRound = self.round.currentRound or "",
			subRound = self.round.currentSubRound or "",
		},
		gamemode = {
			name = self.gamemode.name or "",
		},
	}
	return data
end

function arenameta:GetData()
	local data = {
		name = self.name,
		icon = self.icon,
		spawns = self.spawns,
		autoload = self.autoload,
		gamemode = self.gamemode.name or "",
	}
	return data
end

function arenameta:Cleanup()
	for k,v in pairs(self.props) do
		v:Remove()
	end
	self:SetNWVar("props", self.props)
end

function arenameta:GetTeam(name)
	return self.teams[name]
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
			if IsValid(v) then
				AddOriginToPVS(v:GetPos())
			end
		end
		for k,v in pairs(arena.props) do
			if IsValid(v) then
				AddOriginToPVS(v:GetPos())
			end
		end
	end
end)

hook.Add("PlayerSpawnedProp", "PK_Arena_PlayerSpawnedProp", function(ply, model, ent)
	local arena = ply.arena

	if IsValid(arena) then
		ent.arena = arena
		table.insert(arena.props, ent:EntIndex(), ent)
		arena:NWProp(ent)
	end
end)

hook.Add("EntityRemoved", "PK_Arena_EntityRemoved", function(ent)
	local arena = ent.arena

	if IsValid(arena) then
		arena.props[ent:EntIndex()] = nil
		arena:NWProp(ent, true)
	end
end)
