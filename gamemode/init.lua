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

function reloadarenas()
	PK.LoadGamemodes()
	for k,v in pairs(PK.arenas) do
		setmetatable(v, PK.arenameta)
		if v.initialized then
			v:SetGamemode(PK.gamemodes[v.gamemode.abbr], true)
		end
	end
end

function GM:Initialize()
	LogPrint("Initializing...")
	reloadarenas()
end

-- Show notification when lua is updated live
if pk_gminitialized and !timer.Exists("PK_UpdateAntiSpam") then
	ChatMsg({Color(0,200,0), "[PK:A]: ", Color(200,200,200), "Gamemode was updated!"})
	timer.Create("PK_UpdateAntiSpam", 4, 1, function() end) -- stop spam as each server file is live updated
end

if pk_gminitialized then
	reloadarenas()
end

pk_gminitialized = true

// for development


concommand.Add("latencytest", function(ply)
	print(CurTime())
end)

hook.Remove("StartCommand", "ffsd", function(ply, cmd)
	if cmd:KeyDown(IN_ATTACK) then
		print("aaaa", CurTime())
		print(ply:GetEyeTrace().Entity)
	end
end)

local function spawnProp(ply, model, weight, angle, pos)
	local start = pos
	pos.z = ply:GetShootPos().z
	local forward = angle:Forward()//ply:GetAimVector()
	
	local trace = {}
	trace.start = start
	trace.endpos = start + (forward * 2048)
	trace.filter = ply // dont hit ourselves
	
	local tr = util.TraceLine(trace)
	
	local ent = ents.Create("prop_physics")
	if not IsValid(ent) then return false end
	
	local pos = tr.HitPos // + offset
	
	ent:SetModel(model)
	//ent:SetAngles(angle)
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()


	// this is called after the inital spawn pos in commands.lua
	// replace this with a hull trace?
	local flushPoint = pos - (tr.HitNormal * 512)
	flushPoint = ent:NearestPoint(flushPoint)
	flushPoint = ent:GetPos() - flushPoint
	flushPoint = tr.HitPos + flushPoint
	
	ent:SetPos(flushPoint)
	
	gamemode.Call("PlayerSpawnedProp", ply, model, ent)
	
	// add weight
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) and weight != 0 then
		phys:SetMass(weight)	
	end
	
	undo.Create("Prop")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish("Prop (" .. tostring(model) .. ")")
	
	ply:AddCleanup("props", ent)
	
	ply:SendLua("achievements.SpawnedProp()")
end

function PKSpawn(ply, command, args)
	if not IsValid(ply) then return end // dont run as server
	
	if args[1] == nil then // no initial arg, disregard call
		ply:PrintMessage(HUD_PRINTCONSOLE, "pk_spawn <model> <weight> <pitch> <yaw> <roll>")
		return
	end
	if args[1]:find("%.[/\\]") then return end
	
	local model = args[1]
	model = model:gsub("\\\\+", "/")
	model = model:gsub("//+", "/")
	model = model:gsub("\\/+", "/")
	model = model:gsub("/\\+", "/")
		
	if not gamemode.Call("PlayerSpawnObject", ply, model, 0) then return end
	if not util.IsValidModel(model) then return end
	
	local weight = args[2] or 0
	weight = math.Clamp(weight, 0, 5000) // shouldnt exceed 5k, or any limit you wish to set -> maybe add a variable

	local ang = Angle(0, ply:EyeAngles().yaw + 180, 0)
	if args[3] then ang.pitch = ang.pitch + args[3] end
	if args[4] then ang.yaw = ang.yaw + args[4] end
	if args[5] then ang.roll = ang.roll + args[5] end
	
	if util.IsValidProp(model) then
		if not ply.spawnQueue then ply.spawnQueue = {} end
		table.insert(ply.spawnQueue, {["model"] = model, ["weight"] = weight, ["angle"] = ang})
		//spawnProp(ply, model, weight, ang)
	end
end

hook.Add("Move", "spawnprops", function(ply, mv, cmd)
	if not ply.spawnQueue then return end

	for k,v in pairs(ply.spawnQueue) do
		spawnProp(ply, v.model, v.weight, mv:GetAngles(), mv:GetOrigin() + mv:GetVelocity()/66)
	end

	ply.spawnQueue = {}
end)

concommand.Add("pk_spawn", PKSpawn)
