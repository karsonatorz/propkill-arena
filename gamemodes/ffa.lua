local ffa = PK.NewGamemode("Free-for-all")

ffa:CreateTeam("Deathmatch", Color(0,255,0))

ffa:Hook("PlayerSpawn", "game1_playerpsawn", function(arena, ply)
	local spawn = math.random(1, #arena.spawns.ffa)
	ply:SetPos(arena.spawns.ffa[spawn].pos)
	ply:SetEyeAngles(arena.spawns.ffa[spawn].ang)
end)

ffa:Hook("PlayerJoinedArena", "asdasd", function(arena, ply)
	local team1 = arena:GetTeam("Deathmatch")
	team1:AddPlayer(arena, ply)
end)
