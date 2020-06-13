local gamemeta = PK.gamemeta

// Class: Gamemode

/*
	Function: Gamemode:Hook()
	Creates a hook to be used in a gamemode running in an arena

	Parameters:
		event: string - The event to hook
		identifier: string - A unique name for the hook
		func: function - The function that will be called when the hook runs
*/
function gamemeta:Hook(event, uniqueid, func)
	if self.userHooks[event] == nil then return end

	self.userHooks[event][uniqueid] = func
end

/*
	Function: Gamemode:HookRemove()
	Removes a hook from a gamemode running in an arena

	*incomplete* this will also remove the hook from the global gamemode

	Parameters:
		event: string - The event to hook
		identifier: string - A unique name for the hook
		func: function - The function that will be called when the hook runs
*/
function gamemeta:HookRemove(event, uniqueid, arena)
	if event == nil or uniqueid == nil then return end

	self.userHooks[event][uniqueid] = nil

	if IsValid(arena) then
		arena.hook[event][uniqueid] = nil
	end
end

// Class: Hooks
// Hooks to be used in gamemodes

/*
	Function: PlayerJoinArena
	Called before a player joins an arena

	Parameters:
		arena: <Arena> - The arena the player wants to join
		ply: Player - The player that wants to join

	Returns:
		canjoin: bool - Return false if you don't want to allow the player to join
		reason: string - The reason that will be shown to the user why they can't join
*/
function gamemeta.hooks.customHooks.PlayerJoinArena(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.PlayerJoinArena) do
		local ret, reason = v(arena, ply)

		if ret != nil then
			return ret, reason
		end
	end

	return true, "no reason given"
end

/*
	Function: PlayerJoinedArena
	Called when a player joins the arena

	Parameters:
		arena: <Arena> - The arena that was joined
		ply: Player - The player that joined the arena
*/
function gamemeta.hooks.customHooks.PlayerJoinedArena(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.PlayerJoinedArena) do
		v(arena, ply)
	end
end

/*
	Function: PlayerLeaveArena
	Called when a player leaves the arena

	Parameters:
		arena: <Arena> - The arena that was left
		ply: Player - The player that left the arena
*/
function gamemeta.hooks.customHooks.PlayerLeaveArena(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.PlayerLeaveArena) do
		v(arena, ply)
	end
end

/*
	Function: PlayerChangedTeam
	Called when a player changes team in the arena

	Parameters:
		arena: <Arena> - The arena the player is in
		ply: Player - The player that changed team
		newTeam: string ?? - The name of the team the player joined
		oldTeam: string ?? - The name of the team the player left
*/
function gamemeta.hooks.customHooks.PlayerChangedTeam(arena, ply, newTeam, oldTeam)
	for k,v in pairs(arena.gamemode.userHooks.PlayerChangedTeam) do
		v(arena, ply, newTeam, oldTeam)
	end
end

/*
	Function: PlayerChangedTeam
	Called when a player changes team in the arena

	*incomplete* not implemented properly

	Parameters:
		arena: <Arena> - The arena that was left
		ply: Player - The player that left the arena
*/
function gamemeta.hooks.customHooks.InitializeGame(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.InitializeGame) do
		v(arena, ply)
	end
end

/*
	Function: TerminateGame
	Called when the arena is terminating

	You should do any cleanup that isn't covered by <Arena:GamemodeCleanup()> here

	Parameters:
		arena: <Arena> - The arena that's terminating
*/
function gamemeta.hooks.customHooks.TerminateGame(arena)
	for k,v in pairs(arena.gamemode.userHooks.TerminateGame) do
		v(arena, ply)
	end
end
