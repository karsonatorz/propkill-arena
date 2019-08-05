/*------------------------------------------
				Propkill init
------------------------------------------*/

/*------------------------------------------
				Includes
------------------------------------------*/

include("shared.lua")
include("shared/config.lua")
include("server/api.lua")
include("server/player.lua")
include("server/entity.lua")
include("server/commands.lua")
include("server/base.lua")
include("shared/entity.lua")
include("server/config.lua")
include("server/arena.lua")

// Gamemodes
//include("gamemodes/ffa/init.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("shared/config.lua")
AddCSLuaFile("client/config.lua")
AddCSLuaFile("client/hud.lua")
AddCSLuaFile("client/hax.lua")
AddCSLuaFile("client/scoreboard.lua")
AddCSLuaFile("client/derma.lua")
AddCSLuaFile("client/base.lua")
AddCSLuaFile("client/commands.lua")
AddCSLuaFile("client/arena.lua")
AddCSLuaFile("shared/entity.lua")
AddCSLuaFile("client/rounds.lua")

// Settings
AddCSLuaFile("client/settings/view.lua")
AddCSLuaFile("client/settings/misc.lua")

// Scoreboard/Menu
AddCSLuaFile("client/scoreboard/frame.lua")
AddCSLuaFile("client/scoreboard/scoreboard.lua")
AddCSLuaFile("client/scoreboard/arenas.lua")
AddCSLuaFile("client/scoreboard/leaderboard.lua")
AddCSLuaFile("client/scoreboard/settings.lua")
AddCSLuaFile("client/scoreboard/duel.lua")

//AddCSLuaFile("client/derma/menu.lua")
//AddCSLuaFile("client/derma/topbar.lua")
//AddCSLuaFile("client/derma/settings.lua")
//AddCSLuaFile("client/derma/duel.lua")

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
util.AddNetworkString("PK_Config_Get")
util.AddNetworkString("PK_Config_Set")

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



