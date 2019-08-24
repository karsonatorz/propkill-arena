hook.Add("InitPostEntity", "PK_ArenaNetClientInit", function()
	net.Start("PK_ArenaNetInitialize")
	net.SendToServer()
end)

net.Receive("PK_ArenaNetInitialize", function()
	PK.arenas = net.ReadTable()
end)

net.Receive("PK_ArenaNetVar", function()
	local arena = net.ReadString()
	local name = net.ReadString()
	local value = net.ReadType()

	if PK.arenas[arena] == nil then PK.arenas[arena] = {} end
	PK.arenas[arena][name] = value
end)

net.Receive("PK_ArenaNetNew", function()
	local arena = net.ReadString()
	local data = net.ReadTable()

	PK.arenas[arena] = data
end)

net.Receive("PK_ArenaNetPlayer", function()
	local arena = net.ReadString()
	local remove = net.ReadBool()
	local ply = net.ReadEntity()

	if PK.arenas[arena] == nil then
		PK.arenas[arena] = {}
		PK.arenas[arena].players = {}
	end
	
	if remove and IsValid(ply) then
		PK.arenas[arena].players[ply:EntIndex()] = nil
	elseif IsValid(ply) then
		table.insert(PK.arenas[arena].players, ply:EntIndex(), ply)
	end
end)

net.Receive("PK_ArenaNetTeamPlayer", function()
	local arena = net.ReadString()
	local team = net.ReadString()
	local remove = net.ReadBool()
	local ply = net.ReadEntity()

	if PK.arenas[arena] == nil then
		PK.arenas[arena] = {}
		PK.arenas[arena].teams = {}
		PK.arenas[arena].teams[team] = {}
		PK.arenas[arena].teams[team].players = {}
	end
	
	if remove and IsValid(ply) then
		PK.arenas[arena].teams[team].players[ply:EntIndex()] = nil
	elseif IsValid(ply) then
		table.insert(PK.arenas[arena].teams[team].players, ply:EntIndex(), ply)
	end
end)

net.Receive("PK_ArenaNetTeamVar", function()
	local arena = net.ReadString()
	local team = net.ReadString()
	local var = net.ReadString()
	local value = net.ReadType()

	if PK.arenas[arena] == nil then
		PK.arenas[arena] = {}
		PK.arenas[arena].teams = {}
		PK.arenas[arena].teams[team] = {}
	end
	
	PK.arenas[arena].teams[team][var] = value
end)

net.Receive("PK_ArenaNetProp", function()
	local arena = net.ReadString()
	local remove = net.ReadBool()
	local ent = net.ReadInt(16)

	if PK.arenas[arena] == nil then
		PK.arenas[arena] = {}
		PK.arenas[arena].props = {}
	end
	
	if remove then
		PK.arenas[arena].props[ent] = nil
	else
		table.insert(PK.arenas[arena].props, ent, Entity(ent))
	end
end)
