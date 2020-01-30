hook.Add("InitPostEntity", "PK_ArenaNetClientInit", function()
	net.Start("PK_ArenaNetInitialize")
	net.SendToServer()
end)

net.Receive("PK_ArenaNetInitialize", function()
	PK.arenas = net.ReadTable()
end)

net.Receive("PK_ArenaNetArena", function()
	local arena = net.ReadString()
	local tbl = net.ReadTable()
	
	if id == nil or tbl == nil then return end
	PK.arenas[arena] = tbl
end)

net.Receive("PK_ArenaNetVar", function()
	local arena = net.ReadString()
	local name = net.ReadString()
	local value = net.ReadType()

	if PK.arenas[arena] == nil then return end
	
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
	local plyid = net.ReadInt(32)
	local ply = Entity(plyid)

	if PK.arenas[arena] == nil then return end
	
	if remove then
		PK.arenas[arena].players[plyid] = nil
	elseif IsValid(ply) then
		PK.arenas[arena].players[plyid] = ply
	end
end)

net.Receive("PK_ArenaNetTeamPlayer", function()
	local arena = net.ReadString()
	local team = net.ReadString()
	local remove = net.ReadBool()
	local plyid = net.ReadInt(32)
	local ply = Entity(plyid)

	if PK.arenas[arena] == nil then return end
	
	if remove then
		PK.arenas[arena].teams[team].players[plyid] = nil
	elseif IsValid(ply) then
		PK.arenas[arena].teams[team].players[plyid] = ply
	end
end)

net.Receive("PK_ArenaNetTeamVar", function()
	local arena = net.ReadString()
	local team = net.ReadString()
	local var = net.ReadString()
	local value = net.ReadType()

	if PK.arenas[arena] == nil then return end
	
	PK.arenas[arena].teams[team][var] = value
end)

net.Receive("PK_ArenaNetProp", function()
	local arena = net.ReadString()
	local remove = net.ReadBool()
	local ent = net.ReadInt(32)

	if PK.arenas[arena] == nil then return end
	
	if remove then
		PK.arenas[arena].props[ent] = nil
	else
		PK.arenas[arena].props[ent] = Entity(ent)
	end
end)

net.Receive("PK_ArenaNetJoinArena", function()
	local canjoin = net.ReadBool()
	local reason = net.ReadString()

	if not canjoin then
		chat.AddText(Color(255,255,255), "Failed to join arena: " .. reason)
	end

end)
