hook.Add("InitPostEntity", "PK_ArenaNetClientInit", function()
	net.Start("PK_ArenaNetInitialize")
	net.SendToServer()
end)

net.Receive("PK_ArenaNetInitialize", function()
	local data = net.ReadTable()
	for k,v in pairs(data.arenas) do
		PK.RegisterArena(k, v)
	end
	PK.gamemodes  = data.gamemodes
end)

net.Receive("PK_ArenaNetArena", function()
	local arena = net.ReadString()
	local tbl = net.ReadTable()

	if arena == nil or tbl == nil then return end
	
	PK.RegisterArena(arena, tbl)
end)

net.Receive("PK_ArenaNetVar", function()
	local arena = net.ReadString()
	local name = net.ReadString()
	local value = net.ReadType()

	if not IsValid(PK.arenas[arena]) then return end
	
	PK.arenas[arena][name] = value
end)

net.Receive("PK_ArenaNetPlayer", function()
	local arena = net.ReadString()
	local remove = net.ReadBool()
	local plyid = net.ReadInt(32)
	local ply = Entity(plyid)

	if not IsValid(PK.arenas[arena]) then return end
	
	if remove then
		PK.arenas[arena].players[plyid] = nil
	elseif IsValid(ply) then
		PK.arenas[arena].players[plyid] = ply
	end
end)

net.Receive("PK_ArenaNetSpectator", function()
	local arena = net.ReadString()
	local remove = net.ReadBool()
	local plyid = net.ReadInt(32)
	local ply = Entity(plyid)

	if not IsValid(PK.arenas[arena]) then return end
	
	if remove then
		PK.arenas[arena].spectators[plyid] = nil
	elseif IsValid(ply) then
		PK.arenas[arena].spectators[plyid] = ply
	end
end)

net.Receive("PK_ArenaNetTeamPlayer", function()
	local arena = net.ReadString()
	local team = net.ReadString()
	local remove = net.ReadBool()
	local plyid = net.ReadInt(32)
	local ply = Entity(plyid)

	if not IsValid(PK.arenas[arena]) then return end
	if not PK.arenas[arena].initialized then return end
	
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

	if not IsValid(PK.arenas[arena]) then return end
	
	PK.arenas[arena].teams[team][var] = value
end)

net.Receive("PK_ArenaNetProp", function()
	local arena = net.ReadString()
	local remove = net.ReadBool()
	local ent = net.ReadInt(32)

	if not IsValid(PK.arenas[arena]) then return end
	
	if remove then
		PK.arenas[arena].props[ent] = nil
	else
		PK.arenas[arena].props[ent] = Entity(ent)
	end
end)

net.Receive("PK_ArenaNetJoinArena", function()
	local canjoin = net.ReadBool()
	local arenaid = net.ReadString()
	local reason = net.ReadString()

	if not canjoin then
		chat.AddText(Color(255,255,255), "Failed to join arena: " .. reason)
	end

end)
