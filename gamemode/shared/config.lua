/*
	config.lua
	Defines the config object
*/

PK = PK or {
	Client = {}
}

Config = {}
Config.__index = Config

function Config.__call(self, fileName, default)
	return Config:Create(fileName or nil, default or nil)
end

setmetatable(Config, Config) -- wtf

function Config:Create(fileName, default)
	local config = {}
	setmetatable(config, Config)
	self.__index = self

	config.fileName = fileName or "pkr_sh_settings.txt"
	config.default = default or {}

	if file.Exists(config.fileName, "DATA") then
		pk_config_file = file.Read(config.fileName, "DATA")
		config.config = util.JSONToTable(pk_config_file) or {}
		for k,v in pairs(config.default) do
			if not config.config[k] then
				config.config[k] = v
			end
		end
		config:Save()
	else
		config.config = {}
		config:ResetToDefault()
	end

	return config
end

function Config:Save()
	file.Write(self.fileName, util.TableToJSON(self.config))
end

function Config:ResetToDefault()
	self.config = self.default
	for k,v in pairs(self.config) do
		self.config[k] = self.default[k]
	end
	config:Save()
end

function Config:Set(setting, value)
	if self.config[setting] == nil then
		self.config[setting] = defaultSettings[setting] or nil
		if self.config[setting] == nil then
			print("Setting does not exist!")
			return false
		end
	end
	self.config[setting].Value = value
	self:Save()
	if isfunction(PK.Client[setting]) then
		PK.Client[setting]()
	end
	print("SET " .. setting .. " TO " .. tostring(value))
end

function Config:Get(setting)
	if setting then
		return self.config[setting]
	else
		return self.config
	end
end
