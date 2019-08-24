PK.Config = PK.CreateConfig("pkr_sv_config.txt", {
	MaxProps = {LongName = "Max props", Type = "number", DecimalPoints = 0, Default = 7},
	LimitFrozenProps = {LongName = "Limit frozen props", Type = "bool", Default = true},
	MaxFrozenProps = {LongName = "Max Frozen Props", Type = "number", DecimalPoints = 0, Default = 3},
	ToolgunEnabled = {LongName = "Enable toolgun", Type = "bool", Default = false},
	EnablePKAPI = {LongName = "Enable PK API", Type = "bool", Default = true},
	PKAPIAddress = {LongName = "PK API URL", Type = "string", Default = "127.0.0.1:8080"}
})

RunConsoleCommand("sbox_maxprops", PK.Config:Get("MaxProps").Value)

net.Receive("PK_Config_Get", function(len, ply)
	if ply:IsSuperAdmin() then
		net.Start("PK_Config_Get")
			net.WriteTable(PK.Config:Get())
		net.Send(ply)
	end
end)

net.Receive("PK_Config_Set", function(len, ply)
	if ply:IsSuperAdmin() then
		local setting = net.ReadString()
		local value = net.ReadTable()[1]
		dprint("SET " .. setting .. " TO " .. tostring(value))
		PK.Config:Set(setting, value)
		if isfunction(PK.Config[setting]) then
			PK.Config[setting]()
		end
	end
end)

function PK.Config.ToolgunEnabled()
	ChatMsg({"Changed " .. string.lower(PK.Config:Get("ToolgunEnabled").LongName) .. " to " .. tostring(PK.Config:Get("ToolgunEnabled").Value)})
end

function PK.Config.MaxFrozenProps()
	ChatMsg({"Changed " .. string.lower(PK.Config:Get("MaxFrozenProps").LongName) .. " to " .. PK.Config:Get("MaxFrozenProps").Value})
end

function PK.Config.MaxProps()
	RunConsoleCommand("sbox_maxprops", PK.Config:Get("MaxProps").Value)
end

function PK.Config.EnablePKAPI()
	ChatMsg({"Changed " .. string.lower(PK.Config:Get("EnablePKAPI").LongName) .. " to " .. tostring(PK.Config:Get("EnablePKAPI").Value)})
end

function PK.Config.LimitFrozenProps()
	ChatMsg({"Changed " .. string.lower(PK.Config:Get("LimitFrozenProps").LongName) .. " to " .. tostring(PK.Config:Get("LimitFrozenProps").Value)})
end

function PK.Config.EnablePKAPI()
	if PK.Config:Get("EnablePKAPI").Value then
		hook.Add("Initialize", "PK_API_Create", function()
			PK.API = PKAPI()
		end)
	else
		hook.Remove("Initialize", "PK_API_Create")
	end
end