local ffa = PK.NewGamemode({
	name = "Free-for-all",
	abbr = "ffa",
	spawnset = "ffa",
	maxplayers = 0
})

ffa:CreateTeam("Deathmatch", Color(0,255,0))

ffa:Hook("PlayerSpawn", "game1_playerpsawn", function(self, ply)
	self:SpawnPlayer(ply)
end)

ffa:Hook("PlayerJoinedArena", "asdasd", function(self, ply)
	local team1 = self:GetTeam("Deathmatch")
	print("adding player to team", team1, getmetatable(team1))
	team1:AddPlayer(ply)
end)

ffa:Hook("PlayerDeath", "cleanup on death", function(self, ply)
	self.arena:Cleanup(ply)
end)

ffa:Hook("PlayerLeaveArena", "fuck", function(self, ply)
	self.arena:Cleanup(ply)
	/*if table.Count(arena.players) == 0 then
		arena:GamemodeCleanup()
	end*/
end)
