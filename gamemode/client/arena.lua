local arenameta = {}
arenameta.__index = arenameta

include("arena/net.lua")
include("arena/teams.lua")
// Class: Global

/*
	Function: PK.GetArena()
	*Client* Gets an arena by its ID

	Parameters:
		id: string - The array index of the arena from the servers PK.arenas[] table

	Returns:
		arena: <Arena> - The arena table with metatable applied
*/
function PK.GetArena(arenaid)
	if type(arenaid) != "string" then return end
	if PK.arenas[arenaid] == nil then return end
	return setmetatable(PK.arenas[arenaid], arenameta)
end

/*
	Function: PK.RegisterArena()
	*Client* Registers the arena clientside

	Parameters:
		id: string - The array index of the arena on the server
		arena: table - The arena data table
		
	Returns:
		arena: <Arena> - The arena table with metatable applied
*/
function PK.RegisterArena(id, tbl)
	tbl.arenaid = id
	PK.arenas[id] = setmetatable(tbl, arenameta)
	return PK.arenas[id]
end

// Class: Arena

/*
	Function: Arena:GetTeams()
	*Client* Gets the team table from the arena

	Returns:
		teams: table - the teams from the arena
*/
function arenameta:GetTeams()
	local teams = {}

	for k,v in pairs(self.teams) do
		teams[k] = setmetatable(v, PK.teammeta)
	end

	return teams
end

/*
	Function: Arena:GetTeam()
	*Client* Gets a specified team from the arena

	Parameters:
		name: string - The name of the team

	Returns:
		team: <Team> - the team table with metatable applied

*/
function arenameta:GetTeam(name)
	return setmetatable(self.teams[name], PK.teammeta)
end

/*
	Function: Arena:RequestArena()
	*Client* Sends a request to setup an arena to the server

	Parameters:
		gamemode: string - the gamemode ID
*/
function arenameta:RequestArena(gm)
	net.Start("PK_ArenaNetRequestArena")
		net.WriteString(self.arenaid or "")
		net.WriteString(gm or "")
	net.SendToServer()
end

function arenameta:IsValid()
	return true 
end
