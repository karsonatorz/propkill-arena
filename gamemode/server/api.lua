/*
	api.lua
	Interacts with the Propkill web API
	Uploads prop spawn stats, total kills, deaths etc
	Also will be used for duel/round results
*/

local PKAPI = {}
PKAPI.__index = PKAPI

function PK.SetupAPI(address, apiKey)
	local api = {}
	setmetatable(api, PKAPI)

	api.address = address or "127.0.0.1:8080"
	api.apiKey = apiKey or "none"
	api.queueUploadInterval = 60
	api.queue = {
		Players = {},
		Matches = {}
	}
	self = api

	timer.Create("PK_API_Queue_Upload", api.queueUploadInterval, 0, function()
		self:UploadQueue()
	end)

	return api
end

function PKAPI:ClearQueue()
	self.queue = {
		Players = {},
		Matches = {}
	}
end

function PKAPI:GetPlayerData(ply)
	local url = "http://" .. self.address .. "/api/player/" .. ply:SteamID()
	http.Fetch(
		url,
		function(responseText, contentLength, responseHeaders, statusCode)
			local data = util.JSONToTable(responseText)
			ply.TotalKills = data["Kills"]
			ply.TotalDeaths = data["Deaths"]
			ply.Elo = data["Elo"]
			ply:SetNWInt("TotalKills", data["Kills"])
			ply:SetNWInt("TotalDeaths", data["Deaths"])
			ply:SetNWInt("Elo", data["Elo"])
		end,
		function(result) print(result) end
	)
end

function PKAPI:GetActivePlayersData()
	local url = "http://" .. self.address .. "/api/players"
	local plys = {}
	for k,ply in pairs(player.GetAll()) do
		if IsValid(ply) then
			table.insert(plys, ply:SteamID())
		end
	end
	http.Post(
		url,
		{players = util.TableToJSON(plys)},
		function(responseText, contentLength, responseHeaders, statusCode)
			local data = util.JSONToTable(responseText)
			PrintTable(data)
			for k,v in pairs(data["Players"]) do
				local ply = player.GetBySteamID(v["SteamID"])
				ply:SetNWInt("TotalKills", v["Kills"])
				ply:SetNWInt("TotalDeaths", v["Deaths"])
				ply:SetNWInt("Elo", v["Elo"])
			end
		end,
		function(result) print(result) end
	)
end

function PKAPI:UploadQueue()
	local newQueue = {Players = {}}
	local count = 0
	for k,v in pairs(self.queue.Players) do
		count = count + 1
	end
	if count == 0 then
		return false
	end
	for k,v in pairs(self.queue.Players or {}) do
		local index = table.insert(newQueue.Players, {SteamID = k})
		newQueue.Players[index].Kills = v.Frags
		newQueue.Players[index].Deaths = v.Deaths
		newQueue.Players[index].Elo = v.Elo
	end
	local queue = tostring(util.TableToJSON(newQueue))
	http.Post(
		"http://" .. self.address .. "/api/uploadQueue", {queue = queue},
		function(responseText, contentLength, responseHeaders, statusCode) self:ClearQueue() end,
		function(result) end
	)
end

function PKAPI:AddInt(ply, name)
	if not self.queue.Players[ply:SteamID()] then
		self.queue.Players[ply:SteamID()] = {}
	end
	if not self.queue.Players[ply:SteamID()][name] then
		self.queue.Players[ply:SteamID()][name] = 1
	else
		self.queue.Players[ply:SteamID()][name] = self.queue.Players[ply:SteamID()][name] + 1
	end
end

function PKAPI:ChangeInt(ply, name, number)
	print("set elo")
	if not self.queue.Players[ply:SteamID()] then
		self.queue.Players[ply:SteamID()] = {}
		self.queue.Players[ply:SteamID()][name] = number
	else
		self.queue.Players[ply:SteamID()][name] = self.queue.Players[ply:SteamID()][name] + number
	end
end

function PKAPI:AddModelStat(ply, name, model)
	if not self.queue.Players[ply:SteamID()] then
		self.queue.Players[ply:SteamID()] = {name = {}}
		self.queue.Players[ply:SteamID()][name][model] = 1
	else
		self.queue.Players[ply:SteamID()][name][model] = self.queue.Players[ply:SteamID()][name][model] + 1
	end
end

function PKAPI:AddScore(ply)
	self:AddInt(ply, "Score")
end

function PKAPI:AddFrag(ply)
	self:AddInt(ply, "Frags")
end

function PKAPI:AddDeath(ply)
	self:AddInt(ply, "Deaths")
end

function PKAPI:AddKillWithProp(ply, model)
	self:AddModelStat(ply, "KillWithModels", model)
end

function PKAPI:AddPropSpawn(ply, model)
	self:AddModelStat(ply, "PropSpawns", model)
end

if not PK.API then
	PK.API = PK.SetupAPI()
end

PK.API:GetActivePlayersData()

hook.Add("PlayerInitialSpawn", "PK_API_GetPlayerData", function(ply)
	PK.API:GetPlayerData(ply)
end)

hook.Add("PlayerDeath", "PK_API_PlayerDeath", function(ply, inflictor, attacker)
	PK.API:AddInt(ply, "Deaths")
	ply:SetNWInt("TotalDeaths", ply:GetNWInt("TotalDeaths") + 1)

	if attacker:IsPlayer() and ply != attacker then
		PK.API:AddInt(attacker, "Kills")
		ply:SetNWInt("TotalKills", ply:GetNWInt("TotalKills") + 1)
	end
end)