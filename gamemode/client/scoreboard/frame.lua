include("settings.lua")

surface.CreateFont("pk_scoreboardfont", {
	font = "stb24",
	size = 32,
	weight = 650,
	antialias = true,
	shadow = true,
})

surface.CreateFont("pk_scoreboardfont2", {
	font = "stb24",
	size = 16,
	weight = 650,
	antialias = true,
	shadow = true,
})

surface.CreateFont("pk_teamfont", {
	font = "Arial",
	size = 20,
	weight = 650,
	antialias = true,
})

surface.CreateFont("pk_playerfont", {
	font = "Arial",
	size = 18,
	weight = 650,
	antialias = true,
})

local lastopen = CurTime()
local isopen = false

colors = {
	primary = Color(48, 48, 47),
	primaryAlt = Color(62, 62, 61),
	primaryDark = Color(42, 42, 41),
	secondary = Color(33, 91, 183),
	divider = Color(255, 255, 255, 255),
	accent = Color(0, 108, 232),
	accept = Color(0, 20, 240),
	deny = Color(240, 20, 0),
	text = Color(255, 255, 255),
	hover = Color(0, 0, 0, 80),
	test = Color(255,0,0),
}

function PK.CreateMenu()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:SetSize(ScrW()/1.7, ScrH()/1.6)
	frame:SetDraggable(true)
	frame:SetSizable(true)
	frame:ShowCloseButton(false)
	frame:Center()
	frame:Hide()
	function frame:Paint(w, h)
		//draw.RoundedBox(0, 0, 0, w, h, colors.primary)
	end
	function frame.btnClose.DoClick()
		isopen = false
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
		frame:ShowCloseButton(false)
		frame:Hide()
	end

	local top = vgui.Create("DPanel", frame)
	top:SetHeight(80)
	top:DockMargin(0,0,0,0)
	top:Dock(TOP)
	function top:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors.secondary)
		draw.RoundedBox(0, 0, h-2, w, 2, colors.divider)
	end

	local servername = vgui.Create("DPanel", top)
	servername:SetHeight(35)
	servername:DockMargin(5,5,5,0)
	servername:Dock(TOP)
	function servername:Paint(w, h)
		draw.DrawText(GetHostName(), "pk_scoreboardfont", w, 0, colors.text, TEXT_ALIGN_RIGHT)
	end

	local mapname = vgui.Create("DPanel", top)
	mapname:SetHeight(30)
	mapname:DockMargin(5,0,5,0)
	mapname:Dock(TOP)
	function mapname:Paint(w, h)
		draw.DrawText(game.GetMap(), "pk_scoreboardfont2", w, 0, colors.text, TEXT_ALIGN_RIGHT)
	end

	local tabs = vgui.Create("DPropertySheet", frame)
	tabs:DockMargin(0, -30, 0, 0)
	tabs:Dock(FILL)
	function tabs:Paint(w, h)
		draw.RoundedBox(0, 0, 30, w, h-30, colors.primaryAlt)
	end

	local panel1 = vgui.Create("DPanel", tabs)
	function panel1:Paint(w, h)
		//draw.RoundedBox(0, 0, 0, w, h, colors.primary)
	end
	local sheet = tabs:AddSheet("Scoreboard", panel1)
	sheet.Panel:DockMargin(8,8,8,8)
	sheet.Panel:Dock(FILL)
	local Scoreboard = include("scoreboard.lua")
	local RefreshScoreboard = Scoreboard(panel1)

	local panel2 = vgui.Create("DPanel", tabs)
	function panel2:Paint(w, h)
		//draw.RoundedBox(0, 0, 0, w, h, colors.primaryAlt)
	end
	sheet = tabs:AddSheet("Arenas", panel2)
	sheet.Panel:DockMargin(4,4,4,4)
	sheet.Panel:Dock(FILL)

	local panel3 = vgui.Create("DPanel", tabs)
	function panel3:Paint(w, h)
		//draw.RoundedBox(0, 0, 0, w, h, colors.primaryAlt)
	end
	sheet = tabs:AddSheet("Duel", panel3)
	sheet.Panel:DockMargin(4,4,4,4)
	sheet.Panel:Dock(FILL)

	local panel4 = vgui.Create("DPanel", tabs)
	function panel4:Paint(w, h)
		//draw.RoundedBox(0, 0, 0, w, h, colors.primaryAlt)
	end
	sheet = tabs:AddSheet("Leaderboards", panel4)
	sheet.Panel:DockMargin(4,4,4,4)
	sheet.Panel:Dock(FILL)

	local panel5 = vgui.Create("PK.Settings", tabs)
	function panel5:Paint(w, h)
		//draw.RoundedBox(0, 0, 0, w, h, colors.primaryAlt)
	end
	sheet = tabs:AddSheet("Settings", panel5)
	sheet.Panel:DockMargin(4,4,4,4)
	sheet.Panel:Dock(FILL)

	for k, v in pairs(tabs.Items) do
		function v.Tab:Paint(w, h)
			w = w-5
			if tabs:GetActiveTab() == v.Tab then
				draw.RoundedBox(0, 0, 0, w, 2, colors.divider)
				draw.RoundedBox(0, 0, 0, 2, h, colors.divider)
				draw.RoundedBox(0, w, 0, 2, h, colors.divider)
				draw.RoundedBox(0, 2, 2, w-2, h, colors.primaryAlt)
			else
				draw.RoundedBox(0, 0, h-2, w, 2, colors.divider)
			end
		end

		function v.Tab:ApplySchemeSettings()
			local ExtraInset = 10

			self:SetTextInset(ExtraInset, 8)
			local w, h = self:GetContentSize()
			h = 30

			self:SetSize(w + ExtraInset + 2 , h)

			DLabel.ApplySchemeSettings(self)
		end

		function v.Tab:UpdateColours()
			self:SetTextStyleColor(colors.text)
		end

	end

	function frame:Show()
		RefreshScoreboard()
		self:SetVisible(true)
	end

	return frame
end

PK.menu = PK.CreateMenu()

function GM:ScoreboardShow()
	PK.menu:Show()

	if CurTime() - lastopen < 0.25 then
		isopen = true
		PK.menu:ShowCloseButton(true)
	end

	lastopen = CurTime()
	gui.EnableScreenClicker(true)
	RestoreCursorPosition()
end

function GM:ScoreboardHide()
	if not isopen then
		PK.menu:Hide()
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
	end
end
