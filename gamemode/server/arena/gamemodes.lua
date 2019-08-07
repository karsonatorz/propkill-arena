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

/*
function PK.NewGamemode(name)
	local gametemplate = {
		name = name or "",
		teams = {},
		round = {},
		userHooks = {},
	}
	local newgm = setmetatable(gametemplate, gamemeta)

	// hook setup

	//hooks with ply as the first argument
	for k,v in pairs(newgm.hooks.playerHooks) do
		newgm.userHooks[v] = {}

		hook.Add(v, tostring(newgm), function(ply, ...)
			local arena = ply.arena
			if not IsValid(arena) then return end
			if arena.gamemode != newgm then return end

			for kk, vv in pairs(newgm.userHooks[v]) do
				local ret = vv(arena, ply, ...)
				if type(ret) != "nil" then
					return ret
				end
			end
		end)
	end

	//custom hooks - these are called from the gamemode/arena base code
	for k,v in pairs(newgm.hooks.customHooks) do
		newgm.userHooks[k] = {}
	end

	return newgm
end
*/

function gamemeta:CreateTeam(name, color)
	if name == nil then return false end

	local teamtemplate = {
		points = 0,
		players = {},
		name = name,
		arena = self,
		color = color or Color(),
	}
	self.teams[name] = setmetatable(teamtemplate, PK.teammeta)

	return self.teams[name]
end

function gamemeta:IsValid()
	return true
end



