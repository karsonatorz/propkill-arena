hook.Add("PlayerSpawnedProp", "pk_setpropowner", function(ply, model, ent)
	ent.Owner = ply
	ent:SetNW2Entity("Owner", ply)
end)

function GM:OnPhysgunReload() return false end
function GM:PlayerSpawnSENT(ply) Notify(ply, "You can only spawn props!") return false end
function GM:PlayerSpawnSWEP(ply) Notify(ply, "You can only spawn props!") return false end
function GM:PlayerGiveSWEP(ply) Notify(ply, "You can only spawn props!") return false end
function GM:PlayerSpawnEffect(ply) Notify(ply, "You can only spawn props!") return false end
function GM:PlayerSpawnVehicle(ply) Notify(ply, "You can only spawn props!") return false end
function GM:PlayerSpawnNPC(ply) Notify(ply, "You can only spawn props!") return false end
function GM:PlayerSpawnRagdoll(ply) Notify(ply, "You can only spawn props!") return false end

hook.Add("PlayerSpawnProp", "pk_canspawnprop", function(ply, model)
	if not ply:Alive() then
		return false
	end
	if model == "models/props/de_tides/gate_large.mdl" and GetGlobalBool("PK_LockersOnly") == true then
		Notify(ply, "Lockers only is enabled!")
		return false
	end

	if ply:Team() == TEAM_UNASSIGNED then
		Notify(ply, "You can't spawn props as a Spectator!")
		return false
	end
end)

function GM:InitPostEntity()
	physenv.SetPerformanceSettings(
		{
			LookAheadTimeObjectsVsObject = 2,
			LookAheadTimeObjectsVsWorld = 21,
			MaxAngularVelocity = 3636,
			MaxCollisionChecksPerTimestep = 5000,
			MaxCollisionsPerObjectPerTimestep = 48,
			MaxFrictionMass = 1,
			MaxVelocity = 2200,
			MinFrictionMass = 99999,
		}
	)
	game.ConsoleCommand("physgun_DampingFactor 1\n")
	game.ConsoleCommand("physgun_timeToArrive 0.01\n")
	game.ConsoleCommand("sv_sticktoground 0\n")
	game.ConsoleCommand("sv_airaccelerate 2000\n")
end

hook.Add("CanProperty", "block_remover_property", function(ply, property, ent)
	return false
end)

hook.Add("PlayerFrozeObject", "PK_Limit_Frozen", function(ply, ent, physobj)
	if PK.config.limitfrozenprops then
		ply.frozenprops = ply.frozenprops or {}
		if not table.HasValue(ply.frozenprops, ent) then
			table.insert(ply.frozenprops, ent)
			if #ply.frozenprops > PK.GetConfig("maxfrozenprops") then
				ply.frozenprops[1]:Remove()
			end
		end
	end
end)

hook.Add("PlayerUnfrozeObject", "PK_Limit_Frozen2", function(ply, ent)
	if IsValid(ply) and ply.frozenprops then
		table.RemoveByValue(ply.frozenprops, ent)
	end
end)

hook.Add("EntityRemoved", "PK_Limit_Frozen3", function(ent)
	local ply = ent.Owner
	if IsValid(ply) and ply.frozenprops then
		table.RemoveByValue(ply.frozenprops, ent)
	end
end)
