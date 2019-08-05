/*------------------------------------------
				Propkill init
------------------------------------------*/ 

/*------------------------------------------
				Includes
------------------------------------------*/ 

include("shared.lua")
include("server/player.lua")
include("server/entity.lua")
include("server/commands.lua")
include("server/base.lua")
include("shared/entity.lua")
include("server/config.lua")
include("server/arena.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("client/hud.lua")
AddCSLuaFile("client/hax.lua")
AddCSLuaFile("client/scoreboard.lua")
AddCSLuaFile("client/derma.lua")
AddCSLuaFile("client/base.lua")
AddCSLuaFile("client/commands.lua")
AddCSLuaFile("client/arena.lua")
AddCSLuaFile("shared/entity.lua")

// scoreboard shit
AddCSLuaFile("client/scoreboard/frame.lua")
AddCSLuaFile("client/scoreboard/scoreboard.lua")
AddCSLuaFile("client/scoreboard/arenas.lua")
AddCSLuaFile("client/scoreboard/leaderboard.lua")
AddCSLuaFile("client/scoreboard/settings.lua")

/*------------------------------------------
				Network Strings
------------------------------------------*/ 

util.AddNetworkString("KilledByProp")
util.AddNetworkString("pk_chatmsg")
util.AddNetworkString("pk_notify")
util.AddNetworkString("pk_teamselect")
util.AddNetworkString("pk_helpmenu")
util.AddNetworkString("pk_settingsmenu")
util.AddNetworkString("pk_gamenotify")
util.AddNetworkString("pk_leaderboard")
util.AddNetworkString("pk_duelinvite")
util.AddNetworkString("pk_acceptduel")
util.AddNetworkString("pk_declineduel")
util.AddNetworkString("pk_matchhistory")

function GM:Initialize()
	LogPrint("Initializing...")

	if PK.config.arenas != nil then
		
	end
end

-- Show notification when lua is updated live
if pk_gminitialized and !timer.Exists("PK_UpdateAntiSpam") then
	ChatMsg({Color(0,200,0), "[PK:R]: ", Color(200,200,200), "Gamemode was updated!"})
	timer.Create("PK_UpdateAntiSpam", 4, 1, function() end) -- stop spam as each server file is live updated
end
pk_gminitialized = true



