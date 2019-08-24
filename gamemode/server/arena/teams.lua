local teammeta = {}
teammeta.__index = teammeta

PK.teammeta = teammeta

function teammeta:AddPlayer(arena, ply)
	if not IsValid(ply) or not ply:IsPlayer() or not IsValid(arena) then return false end

	self.players[ply:UserID()] = ply
	ply.team = self

	arena:NWTeamPlayer(ply, self.name)

	return true
end

function teammeta:RemovePlayer(arena, ply)
	if not IsValid(ply) or not ply:IsPlayer() or not IsValid(arena) then return end

	self.players[ply:UserID()] = nil
	ply.team = nil

	arena:NWTeamPlayer(ply, self.name, true)
end

function teammeta:AddPoints(arena, amount)
	if not IsValid(arena) then return end

	self.points = self.points + (amount or 1)

	arena:NWTeamVar(self.name, "points", self.points)
end

function teammeta:GetPoints()
	return self.points or 0
end

function teammeta:TotalFrags()
	local total = 0
	
	for k,v in pairs(self.players) do
		total = total + v:Frags()
	end

	return total
end

function teammeta:TotalDeaths()
	local total = 0
	
	for k,v in pairs(self.players) do
		total = total + v:Deaths()
	end
	
	return total
end

function teammeta:IsValid()
	return true
end