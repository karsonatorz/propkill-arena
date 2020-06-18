local gamemeta = {}
gamemeta.__index = gamemeta

PK.gamemeta = gamemeta

// Class: GModHooks
// These hooks just have the arena prepended onto their parameters

gamemeta.hooks = {
	playerHooks = {
		// Function: PlayerSpawn
		"PlayerSpawn",
		// Function: PlayerSpawnProp
		"PlayerSpawnProp",
		// Function: PlayerSpawnedProp
		"PlayerSpawnedProp",
		// Function: DoPlayerDeath
		"DoPlayerDeath",
		// Function: PlayerDeath
		"PlayerDeath",
		// Function: PlayerSay
		"PlayerSay"
	},
	customHooks = {}
}

include("hooks.lua")
include("rounds.lua")
include("teams.lua")

//Class: Global

/*
	Function: PK.NewGamemode()
	Creates a new gamemode

	Parameters:
		data: table - A table containing the following:

		* name: string  The name of the gamemode e.g. Team Deathmatch
		* abbr: string  Name abbreviation e.g. TDM - This is what the gamemode will be identified and accessed via
		* spawnset: string  The spawnset used when you call <Gamemode:SpawnPlayer()> - Default: ffa
		* adminonly: bool  Only allow admins to create arenas with this gamemode - Default: false

	Returns:
		gamemode: <Gamemode>
*/
function PK.NewGamemode(data)
	local gametemplate = {
		name = data.name or "",
		abbr = data.abbr or "",
		spawnset = data.spawnset or "ffa",
		adminonly = data.adminonly or false,
		teams = {},
		round = {},
		userHooks = {},
	}
	local newgm = setmetatable(gametemplate, gamemeta)
	PK.gamemodes[gametemplate.abbr] = newgm

	for k,v in pairs(newgm.hooks.playerHooks) do
		newgm.userHooks[v] = {}
	end
	for k,v in pairs(newgm.hooks.customHooks) do
		newgm.userHooks[k] = {}
	end

	return newgm
end

/*
	Class: Gamemode
	Used for creating arena gamemodes
*/

/*
	Function: Gamemode:CreateTeam()
	Creates a new team for the gamemode

	Parameters:
		name: string - Name of the team
		color: Color - Team color
*/
function gamemeta:CreateTeam(name, color)
	if name == nil then return false end

	local teamtemplate = {
		points = 0,
		players = {},
		name = name,
		color = color or Color(),
	}
	self.teams[name] = teamtemplate

	return self.teams[name]
end


/*
	Function: Gamemode:SpawnPlayer()
	Spawn manager function. Call this in a PlayerSpawn hook in your gamemode

	Parameters:
		ply: Player - The player to spawn
		arena: <Arena> - The arena to spawn the player in
*/
function gamemeta:SpawnPlayer(ply, arena)
	local teamname = ply.team.name
	local spawn = math.random(1, #arena.positions.spawns[self.spawnset][teamname])

	ply:SetPos(arena.positions.spawns[self.spawnset][teamname][spawn].pos)
	ply:SetEyeAngles(arena.positions.spawns[self.spawnset][teamname][spawn].ang)
end

/*
	Function: Gamemode:IsValid()
	Checks if the gamemode is valid

	Returns:
		valid: bool - true if the gamemode is valid
*/
function gamemeta:IsValid()
	return true
end



