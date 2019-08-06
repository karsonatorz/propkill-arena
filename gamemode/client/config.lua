PK.Client.Config = PK.CreateConfig("pkr_cl_settings.txt", {
	RemoveSkybox = {LongName = "Replace skybox with grey", Type = "bool", Default = false},
	RoofTiles = {LongName = "Enable rooftiles in skybox", Type = "bool", Default = false},
	UseLerpCommand = {LongName = "Use lerp command (more responsive props)", Type = "bool", Default = false},
	UseCustomFOV = {LongName = "Use Custom FOV", Type = "bool", Default = false},
	CustomFOV = {LongName = "Custom FOV", Type = "number", DecimalPoints = 0, Default = 100},
	UseCustomViewmodelOffset = {LongName = "Use Custom Viewmodel Offset", Type = "bool", Default = false},
	CustomViewmodelOffset = {LongName = "Custom Viewmodel Offset", Type = "vector", Default = Vector(0, 0, 0)},
	HideViewmodel = {LongName = "Hide viewmodel", Type = "bool", Default = false},
	EnableBhop = {LongName = "Enable bhop", Type = "bool", Default = true},
	TrackPlayers = {LongName = "Track Players", Type = "bool", Default = false},
	WeaponSelectEnabled = {LongName = "Weapon Select Enabled", Type = "bool", Default = false}
})

function PK.GetServerConfig()
	net.Start("PK_Config_Get")
	net.SendToServer()
end

function PK.SetServerConfig(setting, value)
	if not setting or not value then print("Cannot set blank setting or value!") end
	net.Start("PK_Config_Set")
		net.WriteString(setting)
		net.WriteTable({value})
	net.SendToServer()
end

net.Receive("PK_Config_Get", function(len)
	PK.ServerConfig = net.ReadTable()
end)

hook.Add("InitPostEntity", "PK_Config_GetServerConfig", function()
	PK.GetServerConfig()
end)
