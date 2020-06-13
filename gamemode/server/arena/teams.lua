local teammeta = {}
teammeta.__index = teammeta

PK.teammeta = teammeta

/*
	Class: Team
	The team class used in arenas

	*incomplete* this possibly needs to be made better i.e. attaching the team to the arena?
*/ 

/*
	Function: Team:AddPlayer()
	Adds a player to the team

	Parameters:
		arena: <Arena> - the arena that the player is in
		ply: Player - the player to add to the team

	Returns:
		success: bool - true if adding the player succeeded
*/
function teammeta:AddPlayer(arena, ply)
	if not IsValid(ply) or not ply:IsPlayer() or not IsValid(arena) then return false end

	self.players[ply:EntIndex()] = ply
	ply.team = self

	arena:NWTeamPlayer(ply, self.name)

	return true
end

/*
	Function: Team:RemovePlayer()
	Removes a player from the team

	Parameters:
		arena: <Arena> - the arena that the player is in
		ply: Player - the player to remove from the team
*/
function teammeta:RemovePlayer(arena, ply)
	if not IsValid(ply) or not ply:IsPlayer() or not IsValid(arena) then return end

	self.players[ply:EntIndex()] = nil
	ply.team = nil

	arena:NWTeamPlayer(ply, self.name, true)
end

/*
	Function: Team:AddPoints()
	Removes a player from the team

	Parameters:
		arena: <Arena> - The arena that the team is in
		amount: number - The amount of points to add to the teams score
*/
function teammeta:AddPoints(arena, amount)
	if not IsValid(arena) then return end

	self.points = self.points + (amount or 1)

	arena:NWTeamVar(self.name, "points", self.points)
end

/*
	Function: Team:AddPoints()
	Removes a player from the team

	Returns:
		points: number - The amount of points the team has
*/
function teammeta:GetPoints()
	return self.points or 0
end

/*
	Function: Team:TotalFrags()
	Gets the total amount of frags the team has

	Returns:
		points: number - The amount of frags the team has
*/
function teammeta:TotalFrags()
	local total = 0
	
	for k,v in pairs(self.players) do
		total = total + v:Frags()
	end

	return total
end

/*
	Function: Team:TotalDeaths()
	Gets the total amount of deaths the team has

	Returns:
		points: number - The amount of deaths the team has
*/
function teammeta:TotalDeaths()
	local total = 0
	
	for k,v in pairs(self.players) do
		total = total + v:Deaths()
	end
	
	return total
end

/*
	Function: Team:IsValid()
	Check if the team is valid

	Returns:
		valid: bool - True if valid
*/
function teammeta:IsValid()
	return true
end
