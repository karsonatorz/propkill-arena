local PANEL = {}
PANEL.Base = "DScrollPanel"

function PANEL:Init()
	self:Dock(FILL)

	self.iconlayout = vgui.Create("DIconLayout", self)
	self.iconlayout:DockMargin(5,5,5,5)
	self.iconlayout:DockPadding(5,5,5,5)
	self.iconlayout:Dock(FILL)
	self.iconlayout:SetSpaceX(10)
	self.iconlayout:SetSpaceY(10)
	
	self.OnSizeChanged = function()
		if IsValid(self.iconlayout) then
			self.iconlayout:InvalidateChildren(true)
		end
		if IsValid(self.createmenu) then
			self.createmenu:InvalidateChildren(true)
		end
	end
	self:Refresh()
end

function PANEL:ArenaCreator()
	self.createmenu = vgui.Create("DPanel", self)
	self.createmenu:SetSize(self:GetSize())
	function self.createmenu:Paint(w, h)
	end

	local row1 = vgui.Create("DPanel", self.createmenu)
	row1:DockMargin(0,0,0,3)
	row1:Dock(TOP)
	function row1:Paint()
	end

	local arena = vgui.Create("DComboBox", row1)
	arena:SetWidth(200)
	arena:Dock(LEFT)
	arena:SetValue("Map")
	for k,v in pairs(PK.arenas) do
		if v.initialized then continue end
		arena:AddChoice(v.name or "unnamed arena", k)
	end

	local row2 = vgui.Create("DPanel", self.createmenu)
	row2:Dock(TOP)
	function row2:Paint()
	end

	local gmselect = vgui.Create("DComboBox", row2)
	gmselect:SetWidth(200)
	gmselect:Dock(LEFT)
	gmselect:SetValue("Gamemode")
	for k,v in pairs(PK.gamemodes) do
		if v.initialized then continue end
		if v.adminonly and not LocalPlayer():IsAdmin() then continue end
		gmselect:AddChoice(v.name or "unnamed gamemode", v.abbr)
	end

	local bottom = vgui.Create("DPanel", self.createmenu)
	bottom:SetHeight(35)
	bottom:Dock(BOTTOM)
	function bottom:Paint()
	end

	local back = vgui.Create("DButton", bottom)
	back:DockMargin(0,0,4,0)
	back:SetFont("pk_playerfont")
	back:SetText("Back")
	back:SetWidth(back:GetTextSize() + 20)
	back:Dock(LEFT)
	back:SetTextColor(colors.text)
	function back:Paint(w, h)
		local col = colors.secondary
		draw.RoundedBox(4, 0, 0, w, h, col)
	end
	back.DoClick = function()
		self.createmenu:Remove()
		self.iconlayout:SetVisible(true)
	end

	local create = vgui.Create("DButton", bottom)
	create:SetFont("pk_playerfont")
	create:SetText("Create")
	create:SetWidth(create:GetTextSize() + 20)
	create:Dock(LEFT)
	create:SetTextColor(colors.text)
	function create:Paint(w, h)
		local col = colors.secondary
		draw.RoundedBox(4, 0, 0, w, h, col)
	end
	create.DoClick = function()
		local _, map = arena:GetSelected()
		local _, gm = gmselect:GetSelected()
		PK.arenas[map]:RequestArena(gm)
	end

	self.createmenu.PerformLayout = function()
		self.createmenu:SetSize(self:GetSize())
	end
end

function PANEL:Refresh()
	if not IsValid(self.iconlayout) then return end

	for k,v in pairs(self.iconlayout:GetChildren()) do
		v:Remove()
	end

	local function layout(this)
		local size = this:GetParent():GetWide()-30
		local wide = size / 4 -- 4 items per row
		local tall = wide / (16/9)
		this:SetSize(wide, tall)
		if IsValid(this.m_Image) then
			this.m_Image:SetSize(wide, tall)
		end
	end

	for k,v in pairs(PK.arenas) do
		if not v.initialized then continue end
		
		local item = self.iconlayout:Add("DImageButton")
		item:SetImage(v.icon or "propkill/arena/downtown.png")
		item.DoClick = function()
			net.Start("PK_ArenaNetJoinArena")
				net.WriteString(k)
			net.SendToServer()

			PK.selectedarena = nil
		end

		item.DoRightClick = function()
			local right = DermaMenu(item)
			right:AddOption("Spectate", function()
				net.Start("PK_ArenaNetSpectateArena")
					net.WriteString(k)
				net.SendToServer()
			end)
			right:Open()
		end

		local overlay = vgui.Create("DPanel", item.m_Image)
		overlay:Dock(FILL)
		function overlay:Paint(w, h)
			local playercount = tostring(table.Count(v.players)) .. "/" .. (tostring(v.maxplayers) == "0" and game.MaxPlayers() or v.maxplayers)
			surface.SetFont("pk_arenafont")
			local width = surface.GetTextSize(playercount)
			
			surface.SetDrawColor(0, 108, 232, 200)
			draw.NoTexture()
			surface.DrawTexturedRectRotated(w/2, h, 800, 85, -5)
			draw.SimpleText(v.name or "name", "pk_arenafont", 5, h-28, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(v.gamemode.name or "gamemode", "pk_arenasubfont", 10, h-10, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(playercount, "pk_arenafont", w-5, h-5 - 10, colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		item.PerformLayout = layout
	end

	local create = self.iconlayout:Add("DButton")
	create:SetColor(Color(255,255,255,255))
	create:SetFont("pk_arenafont")
	create:SetText("Create...")
	create.DoClick = function()
		self.iconlayout:SetVisible(false)
		self:ArenaCreator()
	end

	function create:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors.secondary)
	end

	create.PerformLayout = layout

	self.iconlayout:InvalidateChildren(true)
	
end

function PANEL:Paint(w, h)

end

return PANEL
