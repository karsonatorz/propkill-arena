function PK.SaveConfig()
	file.Write("pkr_settings.txt", util.TableToJSON(PK_Config))
end

function PK.SetConfig(setting, value)
	PK.config[setting] = value
	PK.SaveConfig()
end

function PK.GetConfig(setting)
	return PK.config[setting]
end

local pk_config_file = file.Read("pkr_sv_config.txt")

if PK.config != nil and PK.config.length == 0 then
	PK.config = util.JSONToTable(pk_config_file)
else
	PK.config = {
		maxprops = 7,
		limitfrozenprops = true,
		maxfrozenprops = 3,
		toolgunenabled = false
	}
	PK.SaveConfig()
end

RunConsoleCommand("sbox_noclip", "0")
RunConsoleCommand("sbox_maxprops", PK.config.maxprops)
