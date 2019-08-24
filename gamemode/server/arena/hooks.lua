local gamemeta = PK.gamemeta

function gamemeta:Hook(event, uniqueid, func)
	if self.userHooks[event] == nil then return end

	self.userHooks[event][uniqueid] = func
end

function gamemeta:HookRemove(event, uniqueid, arena)
	if event == nil or uniqueid == nil then return end

	self.userHooks[event][uniqueid] = nil

	if IsValid(arena) then
		arena.hook[event][uniqueid] = nil
	end
end

/*
function gamemeta:HookCall(event, ...)
	if self.hooks.customHooks[event] == nil then
		error("Attempt to call non-existent arena hook", 2)
		return
	end

	return self.hooks.customHooks[event](self.arena, ...)
end
*/

function gamemeta.hooks.customHooks.PlayerJoinArena(arena, arenaGame, ply)
	for k,v in pairs(arena.gamemode.userHooks.PlayerJoinArena) do
		local ret, reason = v(arena, ply)

		if ret != nil then
			return ret, reason
		end
	end

	return true, ""
end

function gamemeta.hooks.customHooks.PlayerJoinedArena(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.PlayerJoinedArena) do
		v(arena, ply)
	end
end

function gamemeta.hooks.customHooks.PlayerLeaveArena(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.PlayerLeaveArena) do
		v(arena, ply)
	end
end

function gamemeta.hooks.customHooks.PlayerChangedTeam(arena, ply, newTeam, oldTeam)
	for k,v in pairs(arena.gamemode.userHooks.PlayerChangedTeam) do
		v(arena, ply, newTeam, oldTeam)
	end
end

function gamemeta.hooks.customHooks.InitializeGame(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.InitializeGame) do
		v(arena, ply)
	end
end

function gamemeta.hooks.customHooks.TerminateGame(arena, ply)
	for k,v in pairs(arena.gamemode.userHooks.TerminateGame) do
		v(arena, ply)
	end
end
