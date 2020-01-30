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
include("server/elo.lua")
include("shared/networking.lua")


AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("shared/config.lua")
AddCSLuaFile("client/config.lua")
AddCSLuaFile("client/hud.lua")
AddCSLuaFile("client/hax.lua")
AddCSLuaFile("client/derma.lua")
AddCSLuaFile("client/base.lua")
AddCSLuaFile("client/commands.lua")
AddCSLuaFile("client/arena.lua")
AddCSLuaFile("shared/entity.lua")
AddCSLuaFile("shared/networking.lua")

// Arena
AddCSLuaFile("client/arena/gamemodes.lua")
AddCSLuaFile("client/arena/editor.lua")
AddCSLuaFile("client/arena/rounds.lua")
AddCSLuaFile("client/arena/teams.lua")
AddCSLuaFile("client/arena/hooks.lua")
AddCSLuaFile("client/arena/net.lua")

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


resource.AddFile("materials/propkill/arena/downtown.png")
resource.AddFile("materials/propkill/arena/testmap.png")
resource.AddFile("materials/propkill/arena/joust.png")
resource.AddFile("materials/propkill/arena/flatgrass.png")

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
end

-- Show notification when lua is updated live
if pk_gminitialized and !timer.Exists("PK_UpdateAntiSpam") then
	ChatMsg({Color(0,200,0), "[PK:R]: ", Color(200,200,200), "Gamemode was updated!"})
	timer.Create("PK_UpdateAntiSpam", 4, 1, function() end) -- stop spam as each server file is live updated
end
pk_gminitialized = true



