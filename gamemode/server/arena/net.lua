local arenameta = PK.arenameta

util.AddNetworkString("PK_ArenaNetVar")
util.AddNetworkString("PK_ArenaNetProp")
util.AddNetworkString("PK_ArenaNetArena")
util.AddNetworkString("PK_ArenaNetPlayer")
util.AddNetworkString("PK_ArenaNetTeamVar")
util.AddNetworkString("PK_ArenaNetJoinArena")
util.AddNetworkString("PK_ArenaNetTeamPlayer")
util.AddNetworkString("PK_ArenaNetInitialize")

function arenameta:SetNWVar(name, value)
	if name == nil then return end
	
	net.Start("PK_ArenaNetVar")
		net.WriteString(tostring(self))
		net.WriteString(name)
		net.WriteType(value)
	net.Broadcast()
end

function arenameta:NWPlayer(ply, remove)
	if ply == nil then return end

	net.Start("PK_ArenaNetPlayer")
		net.WriteString(tostring(self))
		net.WriteBool(remove and true or false)
		net.WriteInt(ply:EntIndex(), 32)
	net.Broadcast()
end

function arenameta:NWTeamPlayer(ply, teamName, remove)
	if ply == nil or teamName == nil then return end

	net.Start("PK_ArenaNetTeamPlayer")
		net.WriteString(tostring(self))
		net.WriteString(teamName)
		net.WriteBool(remove and true or false)
		net.WriteInt(ply:EntIndex(), 32)
	net.Broadcast()
end

function arenameta:NWTeamVar(teamName, var, value)
	if teamName == nil or var == nil then return end

	net.Start("PK_ArenaNetTeamVar")
		net.WriteString(tostring(self))
		net.WriteString(teamName)
		net.WriteString(var)
		net.WriteType(value)
	net.Broadcast()
end

function arenameta:NWProp(ent, remove)
	if ent == nil then return end

	net.Start("PK_ArenaNetProp")
		net.WriteString(tostring(self))
		net.WriteBool(remove and true or false)
		net.WriteInt(ent:EntIndex(), 32)
	net.Broadcast()
end

function arenameta:NWArena()
	net.Start("PK_ArenaNetArena")
		net.WriteString(tostring(self))
		net.WriteTable(self:GetInfo())
	net.Broadcast()
end

net.Receive("PK_ArenaNetInitialize", function(len, ply)
	if ply.arenaInit then return end

	ply.arenaInit = true
	local tosend = {}

	for k,v in pairs(PK.arenas) do
		if not IsValid(v) then continue end
		tosend[tostring(v)] = v:GetInfo()
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