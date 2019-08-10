hook.Add("InitPostEntity", "PK_ArenaNetClientInit", function()
	net.Start("PK_ArenaNetInitialize")
	net.SendToServer()
end)

net.Receive("PK_ArenaNetInitialize", function()
	PK.arenas = net.ReadTable()
end)

net.Receive("PK_ArenaNet", function()
	local arena = net.ReadString()
	local name = net.ReadString()
	local value = net.ReadType()

	if PK.arenas[arena] == nil then PK.arenas[arena] = {} end
	PK.arenas[arena][name] = value
end)

net.Receive("PK_ArenaNetNew", function()
	local name = net.ReadString()
	local arena = net.ReadTable()

	PK.arenas[name] = arena
end)

net.Receive("PK_ArenaNetUpdate", function()
	local arena = net.ReadString()
	local name = net.ReadString()
	local key = net.ReadType()
	local value = net.ReadType()

	if PK.arenas[arena] == nil then PK.arenas[arena] = {} end
	if PK.arenas[arena][name] == nil then PK.arenas[arena][name] = {} end

	PK.arenas[arena][name][key] = value
end)