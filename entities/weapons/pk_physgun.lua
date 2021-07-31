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
		if mv:KeyDown(IN_ATTACK) and not ply.holding then
			ply:grabEnt(ply:GetEyeTrace())
		end

		if mv:KeyReleased(IN_ATTACK) and ply.holding then
			ply:releaseEnt()
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
			ply.scrolldist = ply.scrolldist + (cmd:GetMouseWheel() < 0 and -wheelspeed or wheelspeed)
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
		phys:SetMass(500)
		self.scrolldist = self:GetPos():Distance(ent:GetPos())
		self.graboffset = tr.HitPos - ent:GetPos()
		self.holding = ent
	end

end

function meta:holdEnt(ent)
	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end

	local targetpos = (self:EyePos() + self:EyeAngles():Forward() * self.scrolldist) - self.graboffset
	local force = ((targetpos - ent:GetPos()) * phys:GetMass()) * 80

	phys:ApplyForceCenter(force - self.delta * 0.7)

	self.delta = force

end

function meta:releaseEnt()
	self.holding:GetPhysicsObject():SetMass(self.holding.originalWeight)
	self.holding = nil
end
