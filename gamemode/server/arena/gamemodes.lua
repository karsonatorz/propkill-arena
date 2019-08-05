local gamemeta = {}
gamemeta.__index = gamemeta

PK.gamemeta = gamemeta

gamemeta.teams = {}
gamemeta.round = {}
gamemeta.userHooks = {}
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
	local newgm = setmetatable({}, gamemeta)

	newgm.name = name

	// hook setup

	//hooks with ply as the first argument
	for k,v in pairs(newgm.hooks.playerHooks) do
		newgm.userHooks[v] = {}

		hook.Add(v, tostring(newgm), function(ply, ...)
			if ply.arena != newgm.arena then return end

			for kk, vv in pairs(newgm.userHooks[v]) do
				local ret = vv(newgm.arena, ply, ...)
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

function gamemeta:CreateTeam(name, color)
	if name == nil then return false end

	self.teams[name] = setmetatable({}, PK.teammeta)

	self.teams[name].name = name
	self.teams[name].arena = self
	self.teams[name].color = color or Color(0,0,0)

	return self.teams[name]
end

function gamemeta:IsValid()
	return true
end



