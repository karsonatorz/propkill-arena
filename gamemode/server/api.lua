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

	print("PK API object created!")

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

function PKAPI:GetPlayerData(ply)
	local url = "http://" .. self.address .. "/api/player/" .. ply:SteamID()
	http.Fetch(
		url,
		function(responseText, contentLength, responseHeaders, statusCode) print(statusCode) print(responseText) end,
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
	PrintTable(plys)
	http.Post(
		url,
		{players = util.TableToJSON(plys)},
		function(responseText, contentLength, responseHeaders, statusCode) print(statusCode) print(responseText) end,
		function(result) print(result) end
	)
end



function PKAPI:UploadQueue()
	local newQueue = {Players = {}}
	if #self.queue.Players == 0 then
		return false
	end
	for k,v in pairs(self.queue.Players or {}) do
		table.insert(newQueue.Players, {SteamID = k, Kills = v.Frags, Deaths = v.Deaths})
	end
	PrintTable(newQueue)
	local queue = tostring(util.TableToJSON(newQueue))
	http.Post(
		"http://" .. self.address .. "/api/uploadQueue", {queue = queue},
		function(responseText, contentLength, responseHeaders, statusCode) print(statusCode) print(responseText) end,
		function(result) print(result) end
	)
end

function PKAPI:AddInt(ply, name)
	if not self.queue.Players[ply:SteamID()] then
		self.queue.Players[ply:SteamID()] = {}
		self.queue.Players[ply:SteamID()][name] = 1
	else
		self.queue.Players[ply:SteamID()][name] = self.queue.Players[ply:SteamID()][name] + 1
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

PK.API = PK.SetupAPI()
