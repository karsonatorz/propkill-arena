local gm = PK.NewGamemode({
	name = "Lobby",
	abbr = "lobby",
	spawnset = "ffa",
	adminonly = true,
})
gm:CreateTeam("Deathmatch", Color(0,255,0))

gm:AddRound("test", 5, function(self)
	for k,v in pairs(self.arena.players) do 
		v:ChatPrint("test round start")
	end
end,
function(self)
	for k,v in pairs(self.arena.players) do 
		v:ChatPrint("test round end")
	end
end)

gm:AddRound("test", 5, function(self)
	for k,v in pairs(self.arena.players) do 
		v:ChatPrint("test sub round 1 start")
	end
end,
function(self)
	for k,v in pairs(self.arena.players) do 
		v:ChatPrint("test sub round 1 end")
	end
end)

gm:Hook("PlayerSpawn", "game1_playerpsawn", function(self, ply)
	self:SpawnPlayer(ply)
end)

gm:Hook("PlayerJoinedArena", "asdasd", function(self, ply)
	local team1 = self:GetTeam("Deathmatch")
	team1:AddPlayer(ply)
	self:StartRound("test")
end)
