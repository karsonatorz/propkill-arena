local teammeta = {}
teammeta.__index = teammeta

PK.teammeta = teammeta

function teammeta:AddPlayer(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end

	self.players[ply:UserID()] = ply
	ply.team = self

	return true
end

function teammeta:RemovePlayer(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	self.players[ply:UserID()] = nil
	ply.team = nil
end

function teammeta:AddPoints(amount)
	self.points = self.points + (amount or 1)
end

function teammeta:GetPoints()
	return self.points
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