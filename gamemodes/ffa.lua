local ffa = PK.NewGamemode("Free-for-all", "ffa")

ffa:CreateTeam("Deathmatch", Color(0,255,0))

ffa:Hook("PlayerSpawn", "game1_playerpsawn", function(arena, ply)
	local teamname = ply.team.name
	local spawn = math.random(1, #arena.positions.spawns.ffa[teamname])
	ply:SetPos(arena.positions.spawns.ffa[teamname][spawn].pos)
	ply:SetEyeAngles(arena.positions.spawns.ffa[teamname][spawn].ang)
end)

ffa:Hook("PlayerJoinedArena", "asdasd", function(arena, ply)
	local team1 = arena:GetTeam("Deathmatch")
	team1:AddPlayer(arena, ply)
end)
