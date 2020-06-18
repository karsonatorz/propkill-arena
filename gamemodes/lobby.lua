local gm = PK.NewGamemode({
	name = "Lobby",
	abbr = "lobby",
	spawnset = "ffa",
	adminonly = true,
})
gm:CreateTeam("Player", Color(0,255,0))

gm:Hook("PlayerSpawn", "game1_playerpsawn", function(arena, ply)
	gm:SpawnPlayer(ply, arena)
end)

gm:Hook("PlayerJoinedArena", "asdasd", function(arena, ply)
	local team1 = arena:GetTeam("Player")
	team1:AddPlayer(arena, ply)
end)
