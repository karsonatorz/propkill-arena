local ffa = PK.NewGamemode({
	name = "Free-for-all",
	abbr = "ffa",
	spawnset = "ffa",
	maxplayers = 0
})

ffa:CreateTeam("Deathmatch", Color(0,255,0))

ffa:Hook("PlayerSpawn", "game1_playerpsawn", function(arena, ply)
	ffa:SpawnPlayer(ply, arena)
end)

ffa:Hook("PlayerJoinedArena", "asdasd", function(arena, ply)
	local team1 = arena:GetTeam("Deathmatch")
	team1:AddPlayer(arena, ply)
end)

ffa:Hook("PlayerLeaveArena", "fuck", function(arena, ply)
	/*if table.Count(arena.players) == 0 then
		arena:GamemodeCleanup()
	end*/
end)
