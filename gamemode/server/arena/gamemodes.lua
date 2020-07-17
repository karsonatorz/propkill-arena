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
		// Function: PostPlayerDeath
		"PostPlayerDeath",
		// Function: PlayerDeath
		"PlayerDeath",
		// Function: PlayerSay
		"PlayerSay",
		// Function: PhysgunDrop
		"PhysgunDrop",
		// Function: PhysgunPickup
		"PhysgunPickup",
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
		* maxplayers: number  Maxmimum amount of players allowed in the gamemode, 0 being unlimited - Default: 0

	Returns:
		gamemode: <Gamemode>
*/
function PK.NewGamemode(data)
	local gametemplate = {
		name = data.name or "",
		abbr = data.abbr or "",
		spawnset = data.spawnset or "ffa",
		adminonly = data.adminonly or false,
		maxplayers = data.maxplayers or 0,
		teams = {},
		round = {},
		userHooks = {},
		IsValid = function() return true end,
	}
	local newgm = setmetatable(gametemplate, gamemeta)
	PK.gamemodes[newgm.abbr] = newgm

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
	Function: Gamemode:GetTeam()
	Gets a team from the arena

	Returns:
		team: <Team> - Team from arena
*/
function gamemeta:GetTeam(name)
	return self.teams[name]
end

/*
	Function: Gamemode:SpawnPlayer()
	Spawn manager function. Call this in a PlayerSpawn hook in your gamemode

	Parameters:
		ply: Player - The player to spawn
		spawnset: string - Optional - The spawnset to use
		teamname: string - Optional - The teams spawn to use
*/
function gamemeta:SpawnPlayer(ply, spawnset, teamname)
	if ply:Team() == TEAM_SPECTATOR then
		ply:SetTeam(TEAM_DEATHMATCH)
		ply:UnSpectate()
		ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		ply:SetSolid(SOLID_BBOX)
		ply.spectating = nil
	end

	local teamname = teamname or ply.team.name
	local spawnset = spawnset or self.spawnset

	if self.arena.positions.spawns[spawnset] == nil then
		ply:ChatPrint("no spawns for this arena")
		return
	elseif self.arena.positions.spawns[spawnset][teamname] == nil then
		ply:ChatPrint("no spawns for this team")
		return
	end

	local spawn = math.random(1, #self.arena.positions.spawns[spawnset][teamname])

	ply:SetPos(self.arena.positions.spawns[spawnset][teamname][spawn].pos)
	ply:SetEyeAngles(self.arena.positions.spawns[spawnset][teamname][spawn].ang)
end

/*
	Function: Gamemode:SpawnAsSpectator()
	Spawn the player as a spectator. Useful for spectating players while eliminated from a round.

	Parameters:
		ply: Player - The player to spawn
		spawnset: string - Optional - The spawnset to use
		teamname: string - Optional - The teams spawn to use
*/
function gamemeta:SpawnAsSpectator(ply, spawnset, teamname)
	ply:SetTeam(TEAM_SPECTATOR)
	ply:SetCollisionGroup(COLLISION_GROUP_NONE)
	ply:SetSolid(SOLID_NONE)
	ply:StripWeapons()
	GAMEMODE:PlayerSpawnAsSpectator(ply)
	ply:Spectate(OBS_MODE_IN_EYE)
	ply:SpectateEntity(self:GetTeam(ply.team.name).players[next(self:GetTeam(ply.team.name).players)])
	ply.spectating = self.arena
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



