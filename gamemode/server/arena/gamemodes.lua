local gamemeta = {}
gamemeta.__index = gamemeta

PK.gamemeta = gamemeta

gamemeta.hooks = {
	playerHooks = {
		"PlayerSpawn",
		"PlayerSpawnProp",
		"PlayerSpawnedProp",
		"DoPlayerDeath",
		"PlayerDeath",
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

	Parameters:
		name: string - The name of the gamemode e.g. Team Deathmatch
		abbr: string - Name abbreviation e.g. TDM - this is what the gamemode will be identified and accessed via

	Returns:
		gamemode: <Gamemode>
*/
function PK.NewGamemode(longname, shortname)
	local gametemplate = {
		name = longname or "",
		abbr = shortname,
		teams = {},
		round = {},
		userHooks = {},
	}
	local newgm = setmetatable(gametemplate, gamemeta)
	PK.gamemodes[shortname] = newgm

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
	Function: Gamemode:IsValid()
	Checks if the gamemode is valid

	Returns:
		valid: bool - true if the gamemode is valid
*/
function gamemeta:IsValid()
	return true
end



