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

function PK.NewGamemode(name)
	local gametemplate = {
		name = name or "",
		teams = {},
		round = {},
		userHooks = {},
	}
	local newgm = setmetatable(gametemplate, gamemeta)
	PK.gamemodes[name] = newgm

	for k,v in pairs(newgm.hooks.playerHooks) do
		newgm.userHooks[v] = {}
	end
	for k,v in pairs(newgm.hooks.customHooks) do
		newgm.userHooks[k] = {}
	end

	return newgm
end

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

function gamemeta:IsValid()
	return true
end



