local arenameta = {}
arenameta.__index = arenameta

include("arena/net.lua")
include("arena/teams.lua")

function PK.GetArena(arenaid)
	if type(arenaid) != "string" then return end
	if PK.arenas[arenaid] == nil then return end
	return setmetatable(PK.arenas[arenaid], arenameta)
end

function arenameta:GetTeams()
	local teams = {}

	for k,v in pairs(self.teams) do
		teams[k] = setmetatable(v, PK.teammeta)
	end

	return teams
end

function arenameta:GetTeam(name)
	return setmetatable(self.teams[name], PK.teammeta)
end

function arenameta:IsValid()
	return true 
end
