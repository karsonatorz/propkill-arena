function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_UNASSIGNED)

	if ply:IsBot() then
		ply:SetTeam(TEAM_DEATHMATCH)
	end
	ply:Spawn()
end

function GM:PlayerSetModel(ply)
	local cl_playermodel = ply:GetInfo("cl_playermodel")
	local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
	util.PrecacheModel(modelname)
	ply:SetModel(modelname)

	local col = ply:GetInfo("cl_playercolor")
	ply:SetPlayerColor(Vector(col))
end

function PK_PlayerLoadout(ply)
	if ply:Team() != TEAM_UNASSIGNED then
		ply:SetHealth(1)
		ply:Give("weapon_physgun")
	end

	local col = ply:GetInfo("cl_weaponcolor")
	ply:SetWeaponColor(Vector(col))
end
hook.Add("PlayerLoadout", "PK_PlayerSpawn", PK_PlayerLoadout)


function GM:PlayerSpawn(ply)
	player_manager.OnPlayerSpawn(ply)
	player_manager.RunClass(ply, "Spawn")

	hook.Call("PlayerLoadout", GAMEMODE, ply)
	hook.Call("PlayerSetModel", GAMEMODE, ply)
	ply:SetupHands()

	ply:SetCustomCollisionCheck(true)

	if ply:Team() == TEAM_UNASSIGNED then
		ply:SetCollisionGroup(COLLISION_GROUP_NONE)
		ply:SetSolid(SOLID_NONE)
		ply:StripWeapons()
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		ply:Spectate(OBS_MODE_ROAMING)
	else
		ply:UnSpectate()
		ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		ply:SetSolid(SOLID_BBOX)
	end

	ply.streak = 0
	ply:SetWalkSpeed(400)
	ply:SetRunSpeed(400)
	ply:SetJumpPower(200)
end

function GM:OnPlayerChangedTeam(ply, old, new)
	ChatMsg({team.GetColor(old), ply:Nick(), cwhite, " has joined team ", team.GetColor(new), team.GetName(new), "!"})
	ply.NextSpawnTime = CurTime()
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

		if propOwner != ply then
			attacker:SendLua("surface.PlaySound(\"/buttons/lightswitch2.wav\")")
			attacker.streak = attacker.streak + 1
		end
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
	ChatMsg({Color(120,120,255), name, Color(255,255,255), " is connecting."})
end

function GM:PlayerDisconnected(ply)
	ChatMsg({Color(120,120,255), ply:Nick(), Color(255,255,255), " has disconnected."})
end

hook.Add("PlayerShouldTakeDamage", "PK_PlayerShouldTakeDamage", function(ply, attacker)
	if ply:Team() == TEAM_UNASSIGNED then
		return false
	end

	if attacker:IsPlayer() then
		if attacker:Team() == TEAM_UNASSIGNED then
			return false
		end

		if GAMEMODE.TeamBased and attacker:Team() == ply:Team() then
			return false
		end
	else
		if attacker:GetClass() == "trigger_hurt" then
			return true
		end
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
	// DISABLES FUCKING ANNOYING CRUNCH FALL SOUND OF HELL
	return 0
end

function GetAlivePlayers()
	local aliveplayers = {}
	for k,v in pairs( player.GetAll() ) do
		if v:Alive() and v:Team() != 0 then table.insert( aliveplayers, v ) end
	end
	return aliveplayers or nil
end

function GetNextAlivePlayer( ply )
   local alive = GetAlivePlayers()

   if #alive < 1 then return nil end

   local prev = nil
   local choice = nil

   if IsValid( ply ) then
	  for k, p in pairs( alive ) do
		 if prev == ply then
			choice = p
		 end

		 prev = p
	  end
   end

   if not IsValid( choice ) then
	  choice = alive[1]
   end

   return choice
end

hook.Add("KeyPress", "speccontrols", function(ply, key)
	if ply:GetObserverMode() != 0 then
	  if key == IN_ATTACK then
		 ply:Spectate( OBS_MODE_ROAMING )
		 ply:SpectateEntity( nil )
		 local alive = GetAlivePlayers()
		 if #alive < 1 then return end
		 local target = table.Random( alive )
		 if IsValid( target ) then
			ply:SetPos( target:EyePos() )
		 end
	  elseif key == IN_ATTACK2 then
		 local target = GetNextAlivePlayer( ply:GetObserverTarget() )
		 if IsValid( target ) then
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity( target )
		 end
	  elseif key == IN_DUCK then
		 local pos = ply:GetPos()
		 local ang = ply:EyeAngles()
		 local target = ply:GetObserverTarget()
		 if IsValid( target ) and target:IsPlayer() then
			pos = target:EyePos()
			ang = target:EyeAngles()
		 end
		 ply:Spectate( OBS_MODE_ROAMING )
		 ply:SpectateEntity( nil )
		 ply:SetPos( pos )
		 ply:SetEyeAngles( ang )
		 return true
	  elseif key == IN_JUMP then
		 if not ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then
			ply:SetMoveType( MOVETYPE_NOCLIP )
		 end
	  elseif key == IN_RELOAD then
		 local tgt = ply:GetObserverTarget()
		 if not IsValid( tgt ) or not tgt:IsPlayer() then return end
			ply:SetObserverMode(OBS_MODE_IN_EYE)
		 elseif ply:GetObserverMode() == OBS_MODE_IN_EYE then
			ply:SetObserverMode(OBS_MODE_CHASE)
		 end
   end
end)

function GM:ShowTeam(ply) net.Start("pk_teamselect") net.Send(ply) end
function GM:ShowHelp(ply) net.Start("pk_helpmenu") net.Send(ply) end
function GM:ShowSpare2(ply) net.Start("pk_settingsmenu") net.Send(ply) end
