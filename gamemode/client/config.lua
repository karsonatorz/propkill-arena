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
    return PK.ServerConfig
end)

PK.GetServerConfig()