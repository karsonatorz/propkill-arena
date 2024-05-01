if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Propkill Physgun"
SWEP.Author = "aaaaaaaaaaaaaaaaaaa"
SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.Description = "aaaaaaaaaaaaaaaaa"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "aaaaaaaaaaaaaaaaaaaaaaaaaa"

SWEP.Spawnable = true
//SWEP.AdminOnly = false
SWEP.Category = "Propkill"

SWEP.ViewModel = "models/weapons/c_superphyscannon.mdl"
SWEP.WorldModel = "models/weapons/w_Physics.mdl"
SWEP.UseHands = true


function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end


if not SERVER then return end

hook.Add("SetupMove", "pk_physgun", function(ply, mv, cmd)
	local activeweapon = ply:GetActiveWeapon()
	if IsValid(activeweapon) and activeweapon:GetClass() == "pk_physgun" then
		if mv:KeyDown(IN_ATTACK) and not ply.holding and ply.grabcooldown < CurTime() then
			ply:grabEnt(ply:GetEyeTrace())
		end

		if mv:KeyDown(IN_ATTACK) and mv:KeyDown(IN_ATTACK2) and ply.grabcooldown < CurTime() then
			ply:freezeEnt()
		end

		if mv:KeyReleased(IN_ATTACK) and ply.holding then
			ply:releaseEnt()
		end

		if mv:KeyReleased(IN_ATTACK) then
			ply.grabcooldown = CurTime()
		end

		if ply.holding == NULL then
			ply.holding = nil
		end

		if IsValid(ply.holding) then
			local forward = mv:GetAngles():Forward()
			//ply.holding:SetPos()
			ply:holdEnt(ply.holding)
			cmd:RemoveKey(IN_JUMP)
		end

		if cmd:GetMouseWheel() != 0 then
			local wheelspeed = ply:GetInfoNum("physgun_wheelspeed", 100)
			ply.scrolldist = ply.scrolldist + wheelspeed * cmd:GetMouseWheel()
			ply.scrolldist = math.Clamp(ply.scrolldist, 30, 4096)
		end
	end

end)

hook.Add("PlayerSpawnedProp", "grab bitch", function(ply, model, ent)
	local activeweapon = ply:GetActiveWeapon()
	if IsValid(activeweapon) and activeweapon:GetClass() == "pk_physgun" then
		ply.grabcooldown = CurTime()
		if ply:KeyDown(IN_ATTACK) then
			ply:grabEnt(ply:GetEyeTrace())
		end
	end
end)

local meta = FindMetaTable("Player")

function meta:grabEnt(tr)
	local ent = tr.Entity
	if not IsValid(ent) then return end
	local canpickup = hook.Run("PhysgunPickup", self, ent)
	
	if canpickup then
		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) then return end

		self.delta = Vector(0, 0, 0)
		ent.originalWeight = phys:GetMass()
		phys:SetMass(45678)
		phys:EnableMotion(true)
		self.scrolldist = self:GetShootPos():Distance(tr.HitPos)
		self.graboffset = tr.HitPos - ent:GetPos()
		self.grabangle = ent:GetAngles()
		self.playerangle = self:EyeAngles()
		self.holding = ent
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
	end

end

function meta:holdEnt(ent)
	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end

	local ang = self:EyeAngles()

	ang.p = 0
	self.playerangle.p = 0

	//ent:SetAngles(self.grabangle + ang - self.playerangle)
	//phys:SetAngleVelocity(Vector())


	local targetpos = (self:EyePos() + self:EyeAngles():Forward() * self.scrolldist)
	local force = ((targetpos - ent:GetPos()) * phys:GetMass()) * 20

	phys:ApplyForceOffset(force - self.delta * 0.50, ent:GetPos() + self.graboffset)

	self.delta = force

end

function meta:releaseEnt()
	if not IsValid(self.holding) then
		self.holding = nil
		return
	end

	local phys = self.holding:GetPhysicsObject()

	if IsValid(self.holding) then
		phys:SetMass(self.holding.originalWeight)
		phys:ClearGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
	end

	self.holding = nil
end

function meta:freezeEnt()
	local phys = self.holding:GetPhysicsObject()
	phys:EnableMotion(false)
	self.grabcooldown = CurTime() + 1
	self:releaseEnt()
end

// test
