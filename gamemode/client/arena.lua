local arenameta = {}
arenameta.__index = arenameta

include("arena/net.lua")
include("arena/teams.lua")


function PK.GetArena(id)
	if type(id) != "string" then return end
	return setmetatable(PK.arenas[id], arenameta)
end

function arenameta:GetTeams()
	local teams = {}

	for k,v in pairs(self.teams) do
		teams[k] = setmetatable(v, PK.teammeta)
	end

	return teams
end

function arenameta:TotalFrags(name)
	return setmetatable(self.teams[name], PK.teammeta)
end