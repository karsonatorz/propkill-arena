/*------------------------------------------
				Propkill init
------------------------------------------*/

/*------------------------------------------
				Includes
------------------------------------------*/

//include("shared.lua")
//include("server/player.lua")
//include("server/commands.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("client/hud.lua")

LogPrint("Loaded FFA")
SetGlobalString("PK_CurrentMode", "Free For All")
SetGlobalString("PK_CurrentLeader", "Nobody")

game1 = PK.NewGamemode("testGM")

team1 = game1:CreateTeam("Team1", Color(255,0,0))
team2 = game1:CreateTeam("Team2", Color(0,255,0))

game1:AddRound("test", 10, function(arena)
	for k,v in pairs(arena.players) do
		//v:Spawn()
		v:ChatPrint("Warmup over")
		v:ChatPrint("Game starting")
	end
	//arena:Cleanup()
end)

game1:AddRound("test", 30, function(arena)
	for k,v in pairs(arena.players) do
		v:ChatPrint("Game over!")
	end
end)

game1:Hook("PlayerJoinedArena", "PK_Arena_PlayerJoined", function(arena, ply)
	ply:ChatPrint("Welcome to " .. arena.name .. ", now playing " .. game1.name or "gamemode")
end)

game1:Hook("PlayerSpawn", "game1_playerpsawn", function(arena, ply)
	if math.Round(math.random(0,1)) then
		team1:AddPlayer()
	else
	end
	local spawn = math.random(1, #arena.spawns.ffa)
	ply:SetPos(arena.spawns.ffa[spawn].pos)
	ply:SetEyeAngles(arena.spawns.ffa[spawn].ang)
end)

game1:Hook("InitializeGame", "game1_initializegame", function(arena)
	game1:StartRound("test", function(arena)
		for k,v in pairs(arena.players) do
			//v:Spawn()
			team1:AddPoints(5)
			team1:AddPoints(-2)
			v:ChatPrint("Warmup started " .. team1:TotalFrags() .. " " .. team1:TotalDeaths() .. " " .. team1:GetPoints())
		end
	end)
end)

