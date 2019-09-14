include("arena/meta.lua")
include("arena/defaults.lua")

local arenaDir = "pk_arenas"

local function setupNewArena()
	local arenatemplate = {
		name = "Arena" .. #PK.arenas + 1,
		//spawns = {},
		maxplayers = 0,
		icon = "propkill/arena/downtown.png",
		players = {},
		props = {},
		hooks = {},
		timers = {},
		round = {},
		teams = {},
		gamemode = {},
		gmvars = {},
		autoload = false,
	}

	return setmetatable(arenatemplate, PK.arenameta)
end

function PK.NewArena(data)
	local arena = setupNewArena()

	if type(data) == "table" then
		local gm = PK.gamemodes[data.gamemode]
		data.gamemode = nil

		for k,v in pairs(data) do
			arena[k] = v
		end
		print(gm)
		if IsValid(gm) then
			arena:SetGamemode(gm)
		end
	end

	PK.arenas[tostring(arena)] = arena
	arena:NWArena()
	
	return arena
end

local function cleanFileName(name)
	if name == nil then error("name is nil") end
	if #name > 64 or #name < 2 then error("bad name length") end
	
	local filename = ""
	for k,v in string.gmatch(name, "([%w-+_ ,.']*)") do
		filename = filename .. k
	end

	return filename
end

local function checkArenaFolders()
	if not file.IsDir(arenaDir, "DATA") or not file.IsDir(arenaDir .. "/" .. cleanFileName(game.GetMap()), "DATA") then
		file.Delete(arenaDir)
		file.CreateDir(arenaDir)
		file.CreateDir(arenaDir .. "/" .. cleanFileName(game.GetMap()))
	end
end

function PK.SaveArena(arena)
	if not IsValid(arena) then return end

	checkArenaFolders()
	local data = arena:GetData()
	print(arenaDir .. "/" .. cleanFileName(game.GetMap()) .. "/" .. cleanFileName(data.name) .. ".txt")
	file.Write(arenaDir .. "/" .. cleanFileName(game.GetMap()) .. "/" .. cleanFileName(data.name) .. ".txt", util.TableToJSON(data, true))
end

function PK.LoadArena(name, map)
	if name == nil then return end

	local data = util.JSONToTable(file.Read(arenaDir .. "/" .. cleanFileName(map or game.GetMap()) .. "/" .. cleanFileName(name) .. ".txt", "DATA"))
	local arena = PK.NewArena(data)

	return arena
end

function PK.LoadArenas(map)
	local files = file.Find(arenaDir .. "/" .. cleanFileName(map or game.GetMap()) .. "/" .. "*.txt", "DATA")

	for k,v in pairs(files) do
		local data = util.JSONToTable(file.Read(arenaDir .. "/" .. cleanFileName(map or game.GetMap()) .. "/" .. v, "DATA"))

		if data.autoload then
			PK.NewArena(data)
		end
	end
end

hook.Add("InitPostEntity", "load autoload arenas", function()
	//load gamemodes
	local files, folders = file.Find(GAMEMODE.FolderName .. "/gamemodes/*", "LUA")
	for k,v in pairs(files) do
		include(GAMEMODE.FolderName .. "/gamemodes/" .. v)
	end
	for k,v in pairs(folders) do
		include(GAMEMODE.FolderName .. "/gamemodes/" .. v .. "/init.lua")
	end

	PK.LoadArenas()
end)
