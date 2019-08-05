/*------------------------------------------
					Fonts
------------------------------------------*/
surface.CreateFont( "team_font", {
	font = "Trebuchet24",
	size = 32,
	weight = 650,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "menu_header_font", {
	font = "Trebuchet24",
	size = 48,
	weight = 650,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "menu_subheader_font", {
	font = "Trebuchet24",
	size = 32,
	weight = 650,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "loading_font", {
	font = "Default",
	size = 64,
	weight = 650,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

/*------------------------------------------
				F1 Propkill Menu
------------------------------------------*/
pk_leaderboard_names = {}

function PKMenu()
	PK_RequestLeaderboard()
	PK_RequestMatchHistory()
	for k,v in pairs(pk_leaderboard) do
		steamworks.RequestPlayerInfo(util.SteamIDTo64(v["steamid"]))
	end

	-------------------------------------------- HELP PANEL
	local mainframe = vgui.Create("DFrame")
	mainframe:SetSize(ScrW() - 200, ScrH() - 150)
	mainframe:Center()
	mainframe:ShowCloseButton(true)
	mainframe:SetDraggable(false)
	mainframe:SetTitle("Propkill Menu")
	function mainframe:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 170))
	end
	function mainframe:OnClose()
		mainframe:Clear()
		timer.Destroy("PK_Update_Leaderboard_Rows")
		timer.Destroy("PK_Update_Match_History_Rows")
		mainframe:Remove()
	end
	mainframe:MakePopup()

	local sheet = vgui.Create("DPropertySheet", mainframe)
	sheet:Dock(FILL)
	sheet:SetPadding(0)
	function sheet:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 170))
	end

	local helppanel = vgui.Create("DPanel", sheet)
	helppanel:Dock(FILL)
	function helppanel:Paint(w, h)
		return
	end

	local html = vgui.Create("HTML", helppanel)
	html:StretchToParent(0,0,0,0)
	html:DockMargin( 0, 0, 0, 0 )
	html:OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=572479773")
	sheet:AddSheet("Help", html, "icon16/html.png")

	--------------------------------------------

	-------------------------------------------- SETTINGS PANEL

	local settingssheet = vgui.Create("DColumnSheet", sheet)
	settingssheet:Dock(FILL)

	local settingsscrollpanel = vgui.Create("DScrollPanel", sheet)
	settingsscrollpanel:SetSize(ScrW() - 190, ScrH() - 135)
	settingsscrollpanel:SetPos(0, 25)
	function settingsscrollpanel:Paint(w, h)
		return
	end
	settingssheet:AddSheet("Client", settingsscrollpanel, "icon16/cog.png")

	local physics_checkbox = vgui.Create("DCheckBoxLabel")
	physics_checkbox:SetParent(settingsscrollpanel)
	physics_checkbox:SetPos(25, 50)
	physics_checkbox:SetText("Use lerp command (more responsive props)")
	physics_checkbox:SetValue(PK_GetConfig("UseLerpCommand"))
	physics_checkbox:SizeToContents()
	function physics_checkbox:OnChange(val)
		PK_SetConfig("UseLerpCommand", val)
	end

	local visuals_checkbox = vgui.Create("DCheckBoxLabel")
	visuals_checkbox:SetParent(settingsscrollpanel)
	visuals_checkbox:SetPos(25, 75)
	visuals_checkbox:SetText("Enable built-in wallhack and ESP")
	visuals_checkbox:SetValue(pk_ms_settings_table.PlayerWalls)
	visuals_checkbox:SizeToContents()
	function visuals_checkbox:OnChange(val)
		RunConsoleCommand("pk_visuals")
	end

	local rooftiles_checkbox = vgui.Create("DCheckBoxLabel")
	rooftiles_checkbox:SetParent(settingsscrollpanel)
	rooftiles_checkbox:SetPos(25, 100)
	--rooftiles_checkbox:Toggle()
	rooftiles_checkbox:SetText("Enable rooftiles in skybox")
	rooftiles_checkbox:SetValue(PK_GetConfig("RoofTiles"))
	rooftiles_checkbox:SizeToContents()
	function rooftiles_checkbox:OnChange(val)
		PK_SetConfig("RoofTiles", val)
	end

	local removeskybox_checkbox = vgui.Create("DCheckBoxLabel")
	removeskybox_checkbox:SetParent(settingsscrollpanel)
	removeskybox_checkbox:SetPos(25, 125)
	--removeskybox_checkbox:Toggle()
	removeskybox_checkbox:SetText("Replace skybox with grey")
	removeskybox_checkbox:SetValue(PK_GetConfig("RemoveSkybox"))
	removeskybox_checkbox:SizeToContents()
	function removeskybox_checkbox:OnChange(val)
		PK_SetConfig("RemoveSkybox", val)
	end

	local vertbeam_checkbox = vgui.Create("DCheckBoxLabel")
	vertbeam_checkbox:SetParent(settingsscrollpanel)
	vertbeam_checkbox:SetPos(25, 150)
	--vertbeam_checkbox:Toggle()
	vertbeam_checkbox:SetText("Vertical beam on players")
	vertbeam_checkbox:SetValue(pk_ms_settings_table.VertBeam)
	vertbeam_checkbox:SizeToContents()
	function vertbeam_checkbox:OnChange(val)
		RunConsoleCommand("pk_vertbeam")
	end

	local usecustomfov_checkbox = vgui.Create("DCheckBoxLabel")
	usecustomfov_checkbox:SetParent(settingsscrollpanel)
	usecustomfov_checkbox:SetPos(25, 175)
	--usecustomfov_checkbox:Toggle()
	usecustomfov_checkbox:SetText("Use Custom FOV")
	usecustomfov_checkbox:SetValue(PK_GetConfig("UseCustomFOV"))
	usecustomfov_checkbox:SizeToContents()
	function usecustomfov_checkbox:OnChange(val)
		PK_SetConfig("UseCustomFOV", val)
	end

	local customfov_numslider = vgui.Create("DNumSlider", settingsscrollpanel)
	customfov_numslider:SetPos(25, 200)
	customfov_numslider:SetText("Custom FOV")
	customfov_numslider:SetMin(40)
	customfov_numslider:SetMax(170)
	customfov_numslider:SetDecimals(0)
	if PK_GetConfig("CustomFOV") == nil then
		PK_SetConfig("CustomFOV", 100)
	end
	customfov_numslider:SetDefaultValue(PK_GetConfig("CustomFOV"))
	customfov_numslider:ResetToDefaultValue()
	customfov_numslider:SetSize(400, 15)
	function customfov_numslider:OnValueChanged(val)
		PK_SetConfig("CustomFOV", val)
		PK_SetConfig("UseCustomFOV", PK_GetConfig("UseCustomFOV"))
	end

	local usecustomviewmodeloffset_checkbox = vgui.Create("DCheckBoxLabel")
	usecustomviewmodeloffset_checkbox:SetParent(settingsscrollpanel)
	usecustomviewmodeloffset_checkbox:SetPos(25, 225)
	--usecustomviewmodeloffset_checkbox:Toggle()
	usecustomviewmodeloffset_checkbox:SetText("Use Custom Viewmodel Offset")
	usecustomviewmodeloffset_checkbox:SetValue(PK_GetConfig("UseCustomViewmodelOffset"))
	usecustomviewmodeloffset_checkbox:SizeToContents()
	function usecustomviewmodeloffset_checkbox:OnChange(val)
		PK_SetConfig("UseCustomViewmodelOffset", val)
	end

	local customviewmodeloffsetx_numslider = vgui.Create("DNumSlider", settingsscrollpanel)
	customviewmodeloffsetx_numslider:SetPos(25, 250)
	customviewmodeloffsetx_numslider:SetText("Custom Viewmodel Offset X")
	customviewmodeloffsetx_numslider:SetMin(-100)
	customviewmodeloffsetx_numslider:SetMax(100)
	customviewmodeloffsetx_numslider:SetDecimals(0)
	if PK_GetConfig("CustomViewmodelOffset") == nil then
		PK_SetConfig("CustomViewmodelOffset", Vector(0,0,0))
	end
	customviewmodeloffsetx_numslider:SetDefaultValue(PK_GetConfig("CustomViewmodelOffset").x)
	customviewmodeloffsetx_numslider:ResetToDefaultValue()
	customviewmodeloffsetx_numslider:SetSize(400, 15)
	function customviewmodeloffsetx_numslider:OnValueChanged(val)
		curr = PK_GetConfig("CustomViewmodelOffset")
		PK_SetConfig("CustomViewmodelOffset", Vector(val, curr.y, curr.z))
		PK_SetConfig("CustomViewmodelOffset", PK_GetConfig("CustomViewmodelOffset"))
	end

	local customviewmodeloffsety_numslider = vgui.Create("DNumSlider", settingsscrollpanel)
	customviewmodeloffsety_numslider:SetPos(25, 275)
	customviewmodeloffsety_numslider:SetText("Custom Viewmodel Offset Y")
	customviewmodeloffsety_numslider:SetMin(-100)
	customviewmodeloffsety_numslider:SetMax(100)
	customviewmodeloffsety_numslider:SetDecimals(0)
	if PK_GetConfig("CustomViewmodelOffset") == nil then
		PK_SetConfig("CustomViewmodelOffset", Vector(0,0,0))
	end
	customviewmodeloffsety_numslider:SetDefaultValue(PK_GetConfig("CustomViewmodelOffset").y)
	customviewmodeloffsety_numslider:ResetToDefaultValue()
	customviewmodeloffsety_numslider:SetSize(400, 15)
	function customviewmodeloffsety_numslider:OnValueChanged(val)
		curr = PK_GetConfig("CustomViewmodelOffset")
		PK_SetConfig("CustomViewmodelOffset", Vector(curr.x, val, curr.z))
		PK_SetConfig("CustomViewmodelOffset", PK_GetConfig("CustomViewmodelOffset"))
	end

	local customviewmodeloffsetz_numslider = vgui.Create("DNumSlider", settingsscrollpanel)
	customviewmodeloffsetz_numslider:SetPos(25, 300)
	customviewmodeloffsetz_numslider:SetText("Custom Viewmodel Offset Z")
	customviewmodeloffsetz_numslider:SetMin(-100)
	customviewmodeloffsetz_numslider:SetMax(100)
	customviewmodeloffsetz_numslider:SetDecimals(0)
	if PK_GetConfig("CustomViewmodelOffset") == nil then
		PK_SetConfig("CustomViewmodelOffset", Vector(0,0,0))
	end
	customviewmodeloffsetz_numslider:SetDefaultValue(PK_GetConfig("CustomViewmodelOffset").z)
	customviewmodeloffsetz_numslider:ResetToDefaultValue()
	customviewmodeloffsetz_numslider:SetSize(400, 15)
	function customviewmodeloffsetz_numslider:OnValueChanged(val)
		curr = PK_GetConfig("CustomViewmodelOffset")
		PK_SetConfig("CustomViewmodelOffset", Vector(curr.x, curr.y, val))
		PK_SetConfig("CustomViewmodelOffset", PK_GetConfig("CustomViewmodelOffset"))
	end

	local hideviewmodel_checkbox = vgui.Create("DCheckBoxLabel")
	hideviewmodel_checkbox:SetParent(settingsscrollpanel)
	hideviewmodel_checkbox:SetPos(25, 325)
	--hideviewmodel_checkbox:Toggle()
	hideviewmodel_checkbox:SetText("Hide viewmodel")
	hideviewmodel_checkbox:SetValue(PK_GetConfig("HideViewmodel"))
	hideviewmodel_checkbox:SizeToContents()
	function hideviewmodel_checkbox:OnChange(val)
		PK_SetConfig("HideViewmodel", val)
	end

	local enablebhop_checkbox = vgui.Create("DCheckBoxLabel")
	enablebhop_checkbox:SetParent(settingsscrollpanel)
	enablebhop_checkbox:SetPos(25, 350)
	--enablebhop_checkbox:Toggle()
	enablebhop_checkbox:SetText("Enable Bhop")
	enablebhop_checkbox:SetValue(PK_GetConfig("EnableBhop"))
	enablebhop_checkbox:SizeToContents()
	function enablebhop_checkbox:OnChange(val)
		PK_SetConfig("EnableBhop", val)
	end

	local enablebhop_checkbox = vgui.Create("DCheckBoxLabel")
	enablebhop_checkbox:SetParent(settingsscrollpanel)
	enablebhop_checkbox:SetPos(25, 375)
	--enablebhop_checkbox:Toggle()
	enablebhop_checkbox:SetText("Track Players")
	enablebhop_checkbox:SetValue(PK_GetConfig("TrackPlayers"))
	enablebhop_checkbox:SizeToContents()
	function enablebhop_checkbox:OnChange(val)
		PK_SetConfig("TrackPlayers", val)
	end

	sheet:AddSheet("Settings", settingssheet, "icon16/cog.png")



	----------------------------------------------------------------

	local serversettingsscrollpanel = vgui.Create("DScrollPanel", sheet)
	serversettingsscrollpanel:SetSize(ScrW() - 190, ScrH() - 135)
	serversettingsscrollpanel:SetPos(0, 25)
	serversettingsscrollpanel:SetEnabled(false)
	if LocalPlayer():IsSuperAdmin() then
		serversettingsscrollpanel:SetEnabled(true)
	end
	function serversettingsscrollpanel:Paint(w, h)
		return
	end
	settingssheet:AddSheet("Server", serversettingsscrollpanel, "icon16/cog.png")

	local physsettings_checkbox = vgui.Create("DCheckBoxLabel")
	physsettings_checkbox:SetParent(serversettingsscrollpanel)
	physsettings_checkbox:SetPos(25, 50)
	physsettings_checkbox:SetText("Australian physics speeds")

	australianphyssetings = {
		LookAheadTimeObjectsVsObject = 2,
		LookAheadTimeObjectsVsWorld = 21,
		MaxAngularVelocity = 3636,
		MaxCollisionChecksPerTimestep = 5000,
		MaxCollisionsPerObjectPerTimestep = 48,
		MaxFrictionMass = 1,
		MaxVelocity = 2200,
		MinFrictionMass = 99999,
	}

	if physenv.GetPerformanceSettings() == australianphyssetings then
		physsettings_checkbox:SetValue(true)
	else
		physsettings_checkbox:SetValue(false)
	end
	physsettings_checkbox:SizeToContents()
	function physsettings_checkbox:OnChange(val)
		if physsettings_checkbox:GetValue() then
			RunConsoleCommand("pk_physsetings", 0)
		else
			RunConsoleCommand("pk_physsetings", 1)
		end
	end

	--------------------------------------------

	-------------------------------------------- LEADERBOARD PANEL

	local leaderboardsheet = vgui.Create("DColumnSheet", sheet)
	leaderboardsheet:Dock(FILL)

	local leaderboardpanel = vgui.Create("DScrollPanel", leaderboardsheet)
	leaderboardpanel:Dock(FILL)
	leaderboardpanel.Paint = function(self, w, h) return end
	leaderboardsheet:AddSheet("  Leaderboard", leaderboardpanel, "icon16/award_star_gold_1.png")

	function updateLeaderboardRows()
		leaderboardpanel:Clear()

		local headerrow = vgui.Create("DPanel", leaderboardpanel)
		headerrow:SetSize(0,30)
		headerrow:Dock(TOP)
		headerrow:DockMargin(0,10,10,10)
		headerrow:SetHeight(25)
		function headerrow:Paint(w,h)
			draw.RoundedBox(0, 0, 0, w, h, Color(100,100,100))
		end

		local ranknum = vgui.Create("DLabel", headerrow)
		ranknum:SetText("")
		ranknum:Dock(LEFT)
		ranknum:SetWidth(100)
		function ranknum:Paint(w,h)
			draw.SimpleText("Rank", "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local plyname = vgui.Create("DLabel", headerrow)
		plyname:SetText("")
		plyname:Dock(LEFT)
		plyname:SetWidth(200)
		function plyname:Paint(w,h)
			draw.SimpleText("Player", "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local totalwins = vgui.Create("DLabel", headerrow)
		totalwins:SetText("")
		totalwins:Dock(LEFT)
		totalwins:SetWidth(100)
		function totalwins:Paint(w,h)
			draw.SimpleText("Total Wins", "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local totallosses = vgui.Create("DLabel", headerrow)
		totallosses:SetText("")
		totallosses:Dock(LEFT)
		totallosses:SetWidth(100)
		function totallosses:Paint(w,h)
			draw.SimpleText("Total Losses", "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		for k,v in pairs(pk_leaderboard) do
			local row = vgui.Create("DPanel", leaderboardpanel)
			row:SetSize(0,30)
			row:Dock(TOP)
			row:DockMargin(0,0,10,10)
			row:SetHeight(25)
			local colour = Color(255,255,102)
			if v["rank"] / #pk_leaderboard <= 0.34 then
				colour = Color(255,255,102)
			elseif v["rank"] / #pk_leaderboard <= 0.68 then
				colour = Color(217,217,217)
			else
				colour = Color(153,102,51)
			end
			function row:Paint(w,h)
				draw.RoundedBox(0, 0, 0, w, h, colour)
			end

			local ranknum = vgui.Create("DLabel", row)
			ranknum:SetText("")
			ranknum:Dock(LEFT)
			ranknum:SetWidth(100)
			function ranknum:Paint(w,h)
				draw.SimpleText(v["rank"], "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local avatar = vgui.Create("AvatarImage", row)
			avatar:Dock(LEFT)
			avatar:DockMargin(12.5,0,12.5,0)
			avatar:SetSize(25,25)
			avatar:SetSteamID(util.SteamIDTo64(v["steamid"]), 32)

			local plyname = vgui.Create("DLabel", row)
			plyname:SetText("")
			plyname:Dock(LEFT)
			plyname:SetWidth(150)
			pk_leaderboard_names[k] = steamworks.GetPlayerName(util.SteamIDTo64(v["steamid"]))

			local actualname = pk_leaderboard_names[k]

			if actualname == "" then
				actualname = "BOT"
			end

			function plyname:Paint(w,h)
				draw.SimpleText(actualname, "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local totalwins = vgui.Create("DLabel", row)
			totalwins:SetText("")
			totalwins:Dock(LEFT)
			totalwins:SetWidth(100)
			function totalwins:Paint(w,h)
				draw.SimpleText(v["wins"], "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local totallosses = vgui.Create("DLabel", row)
			totallosses:SetText("")
			totallosses:Dock(LEFT)
			totallosses:SetWidth(100)
			function totallosses:Paint(w,h)
				draw.SimpleText(v["losses"], "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end

	updateLeaderboardRows()

	timer.Create("PK_Update_Leaderboard_Rows", 1, 0, updateLeaderboardRows)

	local matchhistorypanel = vgui.Create("DScrollPanel", leaderboardsheet)
	matchhistorypanel:Dock(FILL)
	matchhistorypanel.Paint = function(self, w, h) return end
	leaderboardsheet:AddSheet("Match History", matchhistorypanel, "icon16/book_previous.png")

	function updateMatchHistoryRows()
			matchhistorypanel:Clear()

		for k,v in pairs(pk_matchhistory) do
			local row = vgui.Create("DPanel", matchhistorypanel)
			row:SetSize(0,30)
			row:Dock(TOP)
			row:DockMargin(0,10,10,5)
			row:SetHeight(32)
			function row:Paint(w,h)
				draw.RoundedBox(0, 0, 0, w, h, Color(150,150,150))
			end

			local winneravatar = vgui.Create("AvatarImage", row)
			winneravatar:Dock(LEFT)
			winneravatar:DockMargin(12.5,0,12.5,0)
			winneravatar:SetSize(32,32)
			winneravatar:SetSteamID(util.SteamIDTo64(v.winner), 32)

			local plyname = vgui.Create("DLabel", row)
			plyname:SetText("")
			plyname:Dock(LEFT)
			plyname:SetWidth(200)
			function plyname:Paint(w,h)
				draw.SimpleText(steamworks.GetPlayerName(util.SteamIDTo64(v.winner)), "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local loseravatar = vgui.Create("AvatarImage", row)
			loseravatar:Dock(LEFT)
			loseravatar:DockMargin(12.5,0,12.5,0)
			loseravatar:SetSize(32,32)
			loseravatar:SetSteamID(util.SteamIDTo64(v.loser), 32)

			local plyname2 = vgui.Create("DLabel", row)
			plyname2:SetText("")
			plyname2:Dock(LEFT)
			plyname2:SetWidth(200)
			function plyname2:Paint(w,h)
				draw.SimpleText(steamworks.GetPlayerName(util.SteamIDTo64(v.loser)), "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local score = vgui.Create("DLabel", row)
			score:SetText("")
			score:Dock(LEFT)
			score:SetWidth(200)
			function score:Paint(w,h)
				draw.SimpleText(v.winnerscore .. "-" .. v.loserscore, "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local date = vgui.Create("DLabel", row)
			date:SetText("")
			date:Dock(LEFT)
			date:SetWidth(200)
			function date:Paint(w,h)
				draw.SimpleText(string.sub(v.createdAt, 1, 10), "pk_teamfont", w/2, h/2, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	timer.Create("PK_Update_Match_History_Rows", 1, 0, updateMatchHistoryRows)

	updateMatchHistoryRows()

	--------------------------------------------

	-------------------------------------------- DUEL PANEL

	local duelpanel = vgui.Create("DScrollPanel", leaderboardsheet)
	duelpanel:Dock(FILL)
	duelpanel.Paint = function(self, w, h) return end
	leaderboardsheet:AddSheet(" Duel", duelpanel, "icon16/lightning.png")

	local opponentselect = vgui.Create("DComboBox", duelpanel)
	opponentselect:SetPos(5, 5)
	opponentselect:SetSize(100, 20)
	opponentselect:SetValue("Select opponent")
	for k,v in pairs(player.GetAll()) do
		if v != LocalPlayer() then
			opponentselect:AddChoice(v:Nick())
		end
	end

	local duelinvitebutton = vgui.Create("DButton", duelpanel)
	duelinvitebutton:SetText("Send Invite")
	duelinvitebutton:SetPos(25, 50)
	duelinvitebutton:SetSize(250, 30)
	duelinvitebutton.DoClick = function()
		local opponent = nil
		for k,v in pairs(player.GetAll()) do
			if v:Nick() == opponentselect:GetSelected() then
				opponent = v
			end
		end
		if opponent == nil then
			return
		end
		net.Start("pk_duelinvite")
			net.WriteEntity(opponent)
		net.SendToServer()
		duelinvitebutton:SetEnabled(false)
		timer.Create("PK_duelinvitebutton", 60, 1, function()
			if IsValid(duelinvitebutton) then
				duelinvitebutton:SetEnabled(true)
			end
		end)
	end
	if timer.Exists("PK_duelinvitebutton") then
		duelinvitebutton:SetEnabled(false)
	end

	sheet:AddSheet("Ranked", leaderboardsheet, "icon16/award_star_gold_1.png")

end

net.Receive("pk_helpmenu", PKMenu)

/*------------------------------------------
				F2 Team Select
------------------------------------------*/

local function RealTeams()
	local count = 0

	for k,v in pairs(team.GetAllTeams()) do
		if k < 1000 then
			count = count + 1
		end
	end
	return count
end

net.Receive("pk_teamselect", function()
	pk_cancloseteamselect = false
	hook.Add("Think", "pk_checkf2key", function()
		if !input.IsKeyDown(KEY_F2) then
			pk_cancloseteamselect = true
		end
   		if input.IsKeyDown(KEY_F2) and pk_cancloseteamselect then
   			if IsValid(pk_teamselectmenu) then
   				pk_teamselectmenu:Remove()
   			end
   			hook.Remove("Think", "pk_checkf2key")
   		end
	end)
	pk_teamselectmenu = vgui.Create("DFrame")
	pk_teamselectmenu:SetTitle("")
	pk_teamselectmenu:SetSize(ScrW()/2.5, ScrH())
	pk_teamselectmenu:AlignRight()
	pk_teamselectmenu:SetDraggable(false)
	pk_teamselectmenu:ShowCloseButton(false)
	function pk_teamselectmenu:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 150))
	end
	pk_teamselectmenu:MakePopup()

	local panel = vgui.Create("DPanel", pk_teamselectmenu)
	panel:SetSize(ScrW()/2.5, 150 * RealTeams())
	panel:Center()

	local tbl = {}

	for k,v in pairs(team.GetAllTeams()) do
		if k > 999 then return false end
		local btn = tbl[k]
		btn = vgui.Create("DButton", panel)
		btn:SetText(team.GetName(k))
		btn:Dock(TOP)
		btn:SetTextColor(Color(0,0,0))
		btn:SetFont("team_font")
		btn:SetSize(ScrW()/2.5, 150)

		if k == 0 then
			btn:SetText("Spectate")
			btn:Dock(BOTTOM)
		end

		function btn:DoClick()
			RunConsoleCommand("pk_team", tostring(k))
			pk_teamselectmenu:Remove()
		end
		function btn:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, team.GetColor(k))
		end
	end
	panel:Center()
end)

/*------------------------------------------
				Duel Invitation
------------------------------------------*/

function PK_DuelInviteMenu()
	sender = net.ReadEntity()
	surface.PlaySound("buttons/button17.wav")

	local mainframe = vgui.Create("DFrame")
	mainframe:SetSize(200, 200)
	mainframe:Center()
	mainframe:ShowCloseButton(true)
	mainframe:SetDraggable(false)
	mainframe:SetTitle("Duel Invitation")
	function mainframe:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 170))
	end
	function mainframe:OnClose()
		mainframe:Clear()
		timer.Destroy("PK_Update_Leaderboard_Rows")
		mainframe:Remove()
	end
	mainframe:MakePopup()

	local DLabel = vgui.Create("DLabel", mainframe)
	DLabel:Dock(TOP)
	DLabel:DockMargin(0,20,0,40)
	DLabel:SizeToContents()
	DLabel:SetText(sender:Nick() .. " has requested a duel!")

	local DermaButton = vgui.Create("DButton", mainframe)
	DermaButton:SetText("Accept")
	DermaButton:SetSize(100, 30)
	DermaButton:Dock(TOP)
	DermaButton.DoClick = function()
		net.Start("pk_acceptduel")
		net.SendToServer()
		mainframe:Remove()
	end

	local DermaButton = vgui.Create("DButton", mainframe)
	DermaButton:SetText("Decline")
	DermaButton:SetSize(100, 30)
	DermaButton:Dock(TOP)
	DermaButton.DoClick = function()
		net.Start("pk_declineduel")
		net.SendToServer()
		mainframe:Remove()
	end

end
net.Receive("pk_duelinvite", PK_DuelInviteMenu)