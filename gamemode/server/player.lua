function GM:PlayerInitialSpawn(ply)
	if ply:IsBot() then
		ply:SetTeam(TEAM_DEATHMATCH)
		local keys = table.GetKeys(PK.arenas)
		PK.arenas[keys[math.ceil(math.random(1, #keys))]]:AddPlayer(ply)
	elseif IsValid(PK.defaultarena) then
		PK.defaultarena:AddPlayer(ply)
	else
		ply:Spawn()
	end
end

concommand.Add("shit", function()
	local keys = table.GetKeys(PK.arenas)
	
	for k,v in pairs(player.GetBots()) do
		local rand = math.ceil(math.random(1, #keys))
		local arena = PK.arenas[keys[rand]]
		if not IsValid(arena) then
			print(arena)
		end
		arena:AddPlayer(v)
	end
end)

function GM:PlayerSetModel(ply)
	local cl_playermodel = ply:GetInfo("cl_playermodel")
	local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
	util.PrecacheModel(modelname)
	ply:SetModel(modelname)

	local col = ply:GetInfo("cl_playercolor")
	ply:SetPlayerColor(Vector(col))
end

hook.Add("PlayerLoadout", "PK_PlayerSpawn", function(ply)
	if ply:Team() != TEAM_UNASSIGNED then
		ply:SetHealth(1)
		ply:Give("weapon_physgun")
	end

	local col = ply:GetInfo("cl_weaponcolor")
	ply:SetWeaponColor(Vector(col))
end)


function GM:PlayerSpawn(ply)
	player_manager.OnPlayerSpawn(ply)
	player_manager.RunClass(ply, "Spawn")

	hook.Call("PlayerLoadout", GAMEMODE, ply)
	hook.Call("PlayerSetModel", GAMEMODE, ply)
	ply:SetupHands()

	ply:SetCustomCollisionCheck(true)

	/*if ply:Team() == TEAM_UNASSIGNED then
		ply:SetCollisionGroup(COLLISION_GROUP_NONE)
		ply:SetSolid(SOLID_NONE)
		ply:StripWeapons()
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		ply:Spectate(OBS_MODE_ROAMING)
	else
		ply:UnSpectate()
		ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		ply:SetSolid(SOLID_BBOX)
	end*/

	ply.streak = 0
	ply:SetWalkSpeed(400)
	ply:SetRunSpeed(400)
	ply:SetJumpPower(200)
end

function GM:DoPlayerDeath(ply, attacker, dmg)
	ply:CreateRagdoll()
	ply:AddDeaths(1)

	if IsValid(attacker) and attacker:IsPlayer() and attacker != ply then
		attacker:AddFrags(1)
	end
end

function GM:PlayerDeath(ply, inflictor, attacker)
	if IsValid(inflictor) and inflictor:GetClass() == "prop_physics" then
		attacker = inflictor.Owner
		attacker:SendLua("surface.PlaySound(\"/buttons/lightswitch2.wav\")")
		attacker.streak = attacker.streak + 1
	end

	ply.streak = 0
	ply.NextSpawnTime = CurTime() + 2

	net.Start("KilledByProp")
		net.WriteEntity(ply)
		net.WriteString(inflictor:GetClass())
		net.WriteEntity(attacker)
	net.Broadcast()
end

function GM:PlayerConnect(name, ip)
	ChatMsg({Color(120,120,255), name, Color(255,255,255), " is connecting"})
end

function GM:PlayerDisconnected(ply)
	ChatMsg({Color(120,120,255), ply:Nick(), Color(255,255,255), " has disconnected"})
end

hook.Add("PlayerShouldTakeDamage", "PK_PlayerShouldTakeDamage", function(ply, attacker)
	if ply:Team() == TEAM_UNASSIGNED then
		return false
	end

	if IsValid(attacker) and attacker:IsPlayer() then
		if attacker:Team() == TEAM_UNASSIGNED then
			return false
		end
	elseif IsValid(attacker) and attacker:GetClass() == "trigger_hurt" then
		return true
	end
end)

function GM:EntityTakeDamage(target, dmg)
	local inflictor = dmg:GetInflictor()

	if not target:IsPlayer() then return end
	if inflictor == game.GetWorld() then return end // TODO: find closest prop if world damages

	if IsValid(inflictor) and IsValid(inflictor.Owner) and inflictor.Owner:IsPlayer() then
		dmg:SetAttacker(inflictor.Owner)
	end

	dmg:AddDamage(target:Health()+10000)
end

function GM:PlayerDeathSound()
	// disables flatline sound
	return true
end

function GM:GetFallDamage()
	// disable fall crunch
	return 0
end

function GetNextPlayer(spectator, spectating)
	local players = spectator.spectating.players
	local picknext = false
	local choice = NULL

	for k,v in pairs(players) do
		if v == spectating then
			picknext = true
			continue
		end

		if picknext then
			choice = v
			break
		end
	end

	if not IsValid(choice) then
		for k,v in pairs(players) do
			choice = v
			break
		end
	end

	return choice
end

hook.Add("KeyPress", "speccontrols", function(ply, key)
	if ply:GetObserverMode() != OBS_MODE_NONE then
		if key == IN_ATTACK then
			local target = GetNextPlayer(ply, ply:GetObserverTarget())

			if IsValid(target) then
				ply:SpectateEntity(target)
			end
		end
	end
end)

function GM:ShowTeam(ply) net.Start("pk_teamselect") net.Send(ply) end
function GM:ShowHelp(ply) net.Start("pk_helpmenu") net.Send(ply) end
function GM:ShowSpare2(ply) net.Start("pk_settingsmenu") net.Send(ply) end
