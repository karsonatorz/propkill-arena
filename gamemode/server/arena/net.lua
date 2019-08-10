local arenameta = PK.arenameta

util.AddNetworkString("PK_ArenaNet")
util.AddNetworkString("PK_ArenaNetNew")
util.AddNetworkString("PK_ArenaNetUpdate")
util.AddNetworkString("PK_ArenaNetInitialize")

function arenameta:SetNWVar(name, value)
	if name == nil then return end

	net.Start("PK_ArenaNet")
		net.WriteString(tostring(self))
		net.WriteString(name)
		net.WriteType(value) //lazy
	net.Broadcast()
end

function arenameta:UpdateNWTable(name, key, value)
	if name == nil or key == nil then return end

	net.Start("PK_ArenaNetUpdate")
		net.WriteString(tostring(self))
		net.WriteString(name)
		net.WriteType(key)
		net.WriteType(value)
	net.Broadcast()
end

function arenameta:AddNWArena()
	net.Start("PK_ArenaNetNew")
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
	