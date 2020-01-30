local editor = {}
editor.__index = editor

PK.editor = editor

function PK.EditArena(arenaid)
	local arena = (isstring(arenaid) and PK.arenas[arenaid] or arenaid)
	if not IsValid(arena) then
		print("PK.EditArena: arena not valid")
		return
	end

	arena.editing = true

	local editdata = {
		spawneditor = false,
		objeditor = false,
		arena = arena,
		positions = table.Copy(arena.positions)
	}
		
	return setmetatable(editdata, PK.editor)
end

function editor:CreatePosEnt(pos, ang, color, spawn)
	if spawn == true then
		local ent = ents.Create("ent_pos")
		ent:SetModel("models/editor/playerstart.mdl")
		ent:SetColor(color or Color(255,0,255))
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		return ent
	else
		local ent = ents.Create("ent_pos")
		ent:SetModel("models/props_c17/oildrum001.mdl")
		ent:SetColor(color or Color(255,0,255))
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()

		return ent
	end
end

function editor:EditSpawns()
	if self:IsEditingSpawns() then
		print("editor.EditSpawns: already editing spawns")
		return
	end

	self.spawneditor = true

	for gamemode, v in pairs(self.positions.spawns) do
		for team, v2 in pairs(v) do
			for k3, spawn in pairs(v2) do
				local ent = self:CreatePosEnt(spawn.pos, spawn.ang, self.arena.gamemode.teams[team].color, true)
				spawn.ent = ent
			end
		end
	end

end

function editor:EditObjectives()
	if self:IsEditingObjectives() then
		print("editor.EditObjectives: already editing objectives")
		return
	end

	self.objeditor = true

	for gamemode, v in pairs(self.positions.objectives) do
		for k2, obj in pairs(v) do
			local ent = self:CreatePosEnt(obj.pos, obj.ang, Color(255,255,255), false)
			obj.ent = ent
		end
	end

end

function editor:SaveSpawns()
	if not self:IsEditingSpawns() then
		print("editor.SaveSpawns: not editing spawns")
		return
	end

	local newspawns = {}
	
	for gamemode, v in pairs(self.positions.spawns) do
		if newspawns[gamemode] == nil then newspawns[gamemode] = {} end
		for team, v2 in pairs(v) do
			if newspawns[gamemode][team] == nil then newspawns[gamemode][team] = {} end
			for k3, spawn in pairs(v2) do
				if IsValid(spawn.ent) then spawn.ent:Remove() end

				table.insert(newspawns[gamemode][team], {pos = spawn.pos, ang = spawn.ang})
			end
		end
	end

	self.arena.positions.spawns = newspawns
	self.spawneditor = false
end

function editor:SaveObjectives()
	if not self:IsEditingObjectives() then
		print("editor.SaveObjectives: not editing objectives")
		return
	end

	local newobjectives = {}

	for gamemode, v in pairs(self.positions.objectives) do
		if newobjectives[gamemode] == nil then newobjectives[gamemode] = {} end
		for k2, obj in pairs(v) do
			if IsValid(obj.ent) then obj.ent:Remove() end

			table.insert(newobjectives[gamemode], {pos = obj.pos, ang = obj.ang, data = obj.data})
		end
	end


	self.arena.positions.objectives = newobjectives
	self.objeditor = false
end

function editor:Finish()
	if self.arena.editing == false then
		print("editor.Finish: not editing")
		return
	end

	for gamemode, v in pairs(self.positions.spawns) do
		for team, v2 in pairs(v) do
			for k3, spawn in pairs(v2) do
				if IsValid(spawn.ent) then spawn.ent:Remove() end
			end
		end
	end

	for gamemode, v in pairs(self.positions.objectives) do
		for k2, obj in pairs(v) do
			if IsValid(obj.ent) then obj.ent:Remove() end
		end
	end

	PK.SaveArena(self.arena)

	self.arena.editor = nil
	self.arena.editing = false
end

function editor:AddSpawn(pos, ang, team)
	if not self:IsEditingSpawns() then
		print("editor.AddSpawn: not editing")
		return
	end

	local ent = self:CreatePosEnt(pos, ang, team, true)

	if not IsValid(ent) then
		print("editor.AddSpawn: entity not valid")
		return
	end

	local gmabbr = self.arena.gamemode.abbr

	if self.positions.spawns[gmabbr] == nil then self.positions.spawns[gmabbr] = {} end
	if self.positions.spawns[gmabbr][team] == nil then self.positions.spawns[gmabbr][team] = {} end

	table.insert(self.positions.spawns[gmabbr][team], {pos = pos, ang = ang, ent = ent})
end

function editor:RemoveSpawn(id)
	if not self:IsEditingSpawns() then return end

end

function editor:AddObjective(pos, ang, data)
	if not self:IsEditingObjectives() then return end

	local ent = self:CreatePosEnt(pos, ang, Color(255,255,255), false)

	if not IsValid(ent) then
		print("editor.AddObjective: entity not valid")
		return
	end

	local gmabbr = self.arena.gamemode.abbr

	if self.positions.objectives[gmabbr] == nil then self.positions.objectives[gmabbr] = {} end

	table.insert(self.positions.objectives[gmabbr], {pos = pos, ang = ang, data = data, ent = ent})
end

function editor:RemoveObjective(id)
	if not self:IsEditingObjectives() then return end

end

function editor:IsEditingSpawns()
	return self.spawneditor or false
end

function editor:IsEditingObjectives()
	return self.objeditor or false
end

function editor:IsValid()
	return true
end

concommand.Add("pk_editarena", function(ply, cmd, args)
	if not ply:IsAdmin() then return end

	if not IsValid(ply.arena) then
		ply:ChatPrint("you aren't in an arena")
		return
	end

	if ply.arena.editing == true then
		ply:ChatPrint("arena is alread being edited")
		return
	end

	ply.arena.editor = PK.EditArena(ply.arena)
	ply:ChatPrint("editing arena " .. ply.arena.name)
end)

concommand.Add("pk_editor_editspawns", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not IsValid(ply.arena) then print("pk_editor_addspawn: invalid arena") end
	if not IsValid(ply.arena.editor) then print("pk_editor_addspawn: invalid arena editor") return end

	ply.arena.editor:EditSpawns()
	ply:ChatPrint("editing spawns in " .. ply.arena.name)
end)

concommand.Add("pk_editor_editobjectives", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not IsValid(ply.arena) then print("pk_editor_addspawn: invalid arena") end
	if not IsValid(ply.arena.editor) then print("pk_editor_addspawn: invalid arena editor") return end

	ply.arena.editor:EditObjectives()
	ply:ChatPrint("editing objective in " .. ply.arena.name)
end)

concommand.Add("pk_editor_addobjective", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not IsValid(ply.arena) then print("pk_editor_addspawn: invalid arena") end
	if not IsValid(ply.arena.editor) then print("pk_editor_addspawn: invalid arena editor") return end

	ply.arena.editor:AddObjective(ply:GetPos(), ply:GetAngles(), {hello = true})
	ply:ChatPrint("added objective in " .. ply.arena.name)
end)

concommand.Add("pk_editor_savespawns", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not IsValid(ply.arena) then print("pk_editor_addspawn: invalid arena") end
	if not IsValid(ply.arena.editor) then print("pk_editor_addspawn: invalid arena editor") return end

	ply.arena.editor:SaveSpawns()
	ply:ChatPrint("saved spawns in " .. ply.arena.name)
end)

concommand.Add("pk_editor_saveobjectives", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not IsValid(ply.arena) then print("pk_editor_addspawn: invalid arena") end
	if not IsValid(ply.arena.editor) then print("pk_editor_addspawn: invalid arena editor") return end

	ply.arena.editor:SaveObjectives()
	ply:ChatPrint("saved objective in " .. ply.arena.name)
end)

concommand.Add("pk_editor_finish", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not IsValid(ply.arena) then print("pk_editor_addspawn: invalid arena") end
	if not IsValid(ply.arena.editor) then print("pk_editor_addspawn: invalid arena editor") return end

	ply.arena.editor:Finish()
	ply:ChatPrint("finished editing " .. ply.arena.name)
end)