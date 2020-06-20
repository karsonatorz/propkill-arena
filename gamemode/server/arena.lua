include("arena/meta.lua")
include("arena/defaults.lua")
include("arena/editor.lua")

local arenaDir = "pk_arenas"

/*
	Class: Global
	Arena global funcs
*/

local function setupNewArena()
	local arenatemplate = {
		name = "Arena" .. #PK.arenas + 1,
		positions = {
			spawns = {},
			objectives = {}
		},
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
		default = false,
		editing = false,
		initialized = false,
	}

	return setmetatable(arenatemplate, PK.arenameta)
end

/*
	Function: PK.NewArena()
	Sets up a new arena

	Parameters:
		data: table - optional

		* name: string
		* positions: table
			* spawns: table
			* objectives: table
		* icon: string path
		* maxplayers: number
		* gamemode: <Gamemode>
		* default: bool
	
	Returns:
		arena: <Arena>
*/
function PK.NewArena(data)
	local arena = setupNewArena()

	if type(data) == "table" then
		local gm = PK.gamemodes[data.gamemode]
		data.gamemode = nil

		if data.default then
			PK.defaultarena = arena
		end

		for k,v in pairs(data) do
			arena[k] = v
		end

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

/*
	Function: PK.SaveArena()
	Saves the arena data to file

	Parameters:
		arena: <Arena> - The arena to save
*/
function PK.SaveArena(arena)
	if not IsValid(arena) then return end

	checkArenaFolders()
	local data = arena:GetData()
	print(arenaDir .. "/" .. cleanFileName(game.GetMap()) .. "/" .. cleanFileName(data.name) .. ".txt")
	file.Write(arenaDir .. "/" .. cleanFileName(game.GetMap()) .. "/" .. cleanFileName(data.name) .. ".txt", util.TableToJSON(data, true))
end

/*
	Function: PK.LoadArena()
	Loads an arena from file

	Parameters:
		name: string - The name of the arena to load
		map: string - optional - The name of the map to load the arena from

	Returns:
		arena: <Arena> - The newly loaded arena
*/
function PK.LoadArena(name, map)
	if name == nil then return end
	map = map or game.GetMap()

	local data = util.JSONToTable(file.Read(arenaDir .. "/" .. cleanFileName(map) .. "/" .. cleanFileName(name) .. ".txt", "DATA"))
	local arena = PK.NewArena(data)

	return arena
end

/*
	Function: PK.LoadArenas()
	Loads all the arenas for the specified or current map

	Parameters:
		map: string - optional - The name of the map to load the arenas from
*/
function PK.LoadArenas(map)
	map = map or game.GetMap()
	local files = file.Find(arenaDir .. "/" .. cleanFileName(map) .. "/" .. "*.txt", "DATA")

	for k,v in pairs(files) do
		local data = util.JSONToTable(file.Read(arenaDir .. "/" .. cleanFileName(map) .. "/" .. v, "DATA"))
		PK.NewArena(data)
	end
end

/*
	Function: PK.LoadGamemodes()
	Loads all the gamemodes ready for use
*/
function PK.LoadGamemodes()
	local files, folders = file.Find(GAMEMODE.FolderName .. "/gamemodes/*", "LUA")
	for k,v in pairs(files) do
		include(GAMEMODE.FolderName .. "/gamemodes/" .. v)
	end
	for k,v in pairs(folders) do
		include(GAMEMODE.FolderName .. "/gamemodes/" .. v .. "/init.lua")
	end
end

hook.Add("InitPostEntity", "load autoload arenas", function()
	PK.LoadGamemodes()
	PK.LoadArenas()
end)

