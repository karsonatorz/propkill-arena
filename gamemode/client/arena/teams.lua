local teammeta = {}
teammeta.__index = teammeta

PK.teammeta = teammeta

function teammeta:GetPlayers()
	return self.players or {}
end

function teammeta:GetColor()
	return self.color or Color()
end

function teammeta:GetName()
	return self.name or "unnamed team"
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