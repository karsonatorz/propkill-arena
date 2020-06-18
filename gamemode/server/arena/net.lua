local arenameta = PK.arenameta

util.AddNetworkString("PK_ArenaNetVar")
util.AddNetworkString("PK_ArenaNetProp")
util.AddNetworkString("PK_ArenaNetArena")
util.AddNetworkString("PK_ArenaNetPlayer")
util.AddNetworkString("PK_ArenaNetTeamVar")
util.AddNetworkString("PK_ArenaNetJoinArena")
util.AddNetworkString("PK_ArenaNetTeamPlayer")
util.AddNetworkString("PK_ArenaNetInitialize")
util.AddNetworkString("PK_ArenaNetRequestArena")

// Class: Arena

/*
	Function: Arena:SetNWVar()
	Sets a variable to be networked to clients

	Parameters:
		name: string - the name of the variable to be networked
		value: any - the value to be networked
*/
function arenameta:SetNWVar(name, value)
	if name == nil then return end
	
	net.Start("PK_ArenaNetVar")
		net.WriteString(tostring(self))
		net.WriteString(name)
		net.WriteType(value)
	net.Broadcast()
end

/*
	Function: Arena:NWPlayer()
	Updates the arena with adding or removing a player

	Parameters:
		ply: Player - The player to be added or removed
		remove: bool - true to remove the player from the arena
*/
function arenameta:NWPlayer(ply, remove)
	if ply == nil then return end

	net.Start("PK_ArenaNetPlayer")
		net.WriteString(tostring(self))
		net.WriteBool(remove and true or false)
		net.WriteInt(ply:EntIndex(), 32)
	net.Broadcast()
end

/*
	Function: Arena:NWTeamPlayer()
	Updates a team with adding or removing a player

	Parameters:
		ply: Player - The player to be added or removed
		remove: bool - Pass true to remove the player from the arena
*/
function arenameta:NWTeamPlayer(ply, teamName, remove)
	if ply == nil or teamName == nil then return end

	net.Start("PK_ArenaNetTeamPlayer")
		net.WriteString(tostring(self))
		net.WriteString(teamName)
		net.WriteBool(remove and true or false)
		net.WriteInt(ply:EntIndex(), 32)
	net.Broadcast()
end

/*
	Function: Arena:NWTeamVar()
	Networks a variable relating to a specific team

	Parameters:
		teamName: string - the name of the team
		name: string - the name of the variable
		value: any - the value to send
*/
function arenameta:NWTeamVar(teamName, var, value)
	if teamName == nil or var == nil then return end

	net.Start("PK_ArenaNetTeamVar")
		net.WriteString(tostring(self))
		net.WriteString(teamName)
		net.WriteString(var)
		net.WriteType(value)
	net.Broadcast()
end

/*
	Function: Arena:NWProp()
	Updates the arena with adding or removing a prop

	Parameters:
		ent: Entity - The entity to be added or removed
		remove: bool - true to remove the entity from the arena
*/
function arenameta:NWProp(ent, remove)
	if ent == nil then return end

	net.Start("PK_ArenaNetProp")
		net.WriteString(tostring(self))
		net.WriteBool(remove and true or false)
		net.WriteInt(ent:EntIndex(), 32)
	net.Broadcast()
end

/*
	Function: Arena:NWArena()
	Sends all the info required for an arena to the client

	Usually only used once when a new arena is created
*/
function arenameta:NWArena()
	net.Start("PK_ArenaNetArena")
		net.WriteString(tostring(self))
		net.WriteTable(self:GetInfo())
	net.Broadcast()
end

net.Receive("PK_ArenaNetInitialize", function(len, ply)
	if ply.arenaInit then return end

	ply.arenaInit = true
	local tosend = {
		arenas = {},
		gamemodes = {}
	}

	for k,v in pairs(PK.arenas) do
		if not IsValid(v) then continue end
		tosend.arenas[tostring(v)] = v:GetInfo()
	end

	for k,v in pairs(PK.gamemodes) do
		if not IsValid(v) then continue end
		tosend.gamemodes[v.abbr] = {
			name = v.name,
			abbr = v.abbr,
			adminonly = v.adminonly
		}
	end

	net.Start("PK_ArenaNetInitialize")
		net.WriteTable(tosend)
	net.Send(ply)
end)

net.Receive("PK_ArenaNetJoinArena", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	local arenaid = net.ReadString()
	print("server:", arenaid)
	local arena = PK.arenas[arenaid]

	if not IsValid(arena) then dprint(ply:Nick(), "attempted to join invalid arena") return end

	local canjoin, reason = arena:AddPlayer(ply)

	net.Start("PK_ArenaNetJoinArena")
		net.WriteBool(canjoin)
		net.WriteString(not canjoin and reason or "")
	net.Send(ply)

end)

net.Receive("PK_ArenaNetRequestArena", function(len, ply)
	local arena = PK.arenas[net.ReadString()]
	local gm = PK.gamemodes[net.ReadString()]
	local createcooldown = 120

	//move all this into an arena function at some point
	if ply.LastCreated and ply.LastCreated > CurTime() then
		ply:ChatPrint("please wait another " .. math.ceil(ply.LastCreated - CurTime()) .. " seconds before creating another arena")
		return
	elseif not IsValid(arena) then
		ply:ChatPrint("invalid map")
		return
	elseif not IsValid(gm) then
		ply:ChatPrint("invalid gamemode")
		return
	elseif gm.adminonly and not ply:IsAdmin() then
		ply:ChatPrint(gm.name or "gamemode" .. " can only be used by admins")
	elseif arena.initialized then
		ply:ChatPrint(arena.name .. " is already in use")
		return
	end

	arena:SetGamemode(gm)
	arena:AddPlayer(ply)
	ply.LastCreated = CurTime() + createcooldown
end)
