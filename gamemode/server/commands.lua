concommand.Add("rserver", function(ply)
	if ply == NULL or ply:IsSuperAdmin() then
		RunConsoleCommand("changelevel", game.GetMap(), engine.ActiveGamemode())
	end
end)

local function ConfigSet(ply, cmd, args)
	if #args == 0 then return false end

	if PK.config[args[1]] == nil then
		ply:ChatPrint("Config option '".. args[1] .."' does not exist")
		return false
	else
		if args[2] and !args[3] then
			if args[2] == "true" then
				PK.config[args[1]] = true
				ply:ChatPrint("Set " .. args[1] .. " to true")
			elseif args[2] == "false" then
				PK.config[args[1]] = false
				ply:ChatPrint("Set " .. args[1] .. " to false")
			end
		elseif args[2] and args[3] and istable(PK.config[args[1]]) then
			local tbl = {}
			for k,v in pairs(args) do
				if k == 1 then continue end
				table.insert(tbl, tostring(args[k]))
			end
			PK.config[args[1]] = tbl
		else
			ply:ChatPrint("Invalid or no value specified!")
			return false
		end
	end
end
concommand.Add("pk_setconfig", ConfigSet)

local function ConfigGet(ply, cmd, args)
	PrintTable(PK.config)
	for k,v in pairs(PK.config) do
		if !istable(v) then
			ply:ChatPrint(tostring(k) .. " = " .. tostring(v) .. " - " .. type(v))
		else
			ply:ChatPrint(tostring(k) .. " = " .. "{" .. table.concat(v, ", ") .. "}" .. " - " .. type(v))
		end
	end
end
concommand.Add("pk_getconfig", ConfigGet)
