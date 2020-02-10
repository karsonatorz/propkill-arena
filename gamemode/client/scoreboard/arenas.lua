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
		self.iconlayout:InvalidateChildren(true)
	end
	self:Refresh()
end

function PANEL:ArenaCreator()
	self.iconlayout:SetVisible(false)
	local createmenu = vgui.Create("DPanel", self)

	local back = vgui.Create("DButton", createmenu)
	back.DoClick = function()
		createmenu:SetVisible(false)
		self.iconlayout:SetVisible(true)
	end
end

function PANEL:Refresh()
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
		local item = self.iconlayout:Add("DImageButton")
		item:SetImage(v.icon or "propkill/arena/downtown.png")
		item.DoClick = function()
			net.Start("PK_ArenaNetJoinArena")
				net.WriteString(k)
			net.SendToServer()

			PK.selectedarena = nil
		end

		local overlay = vgui.Create("DPanel", item.m_Image)
		overlay:Dock(FILL)
		function overlay:Paint(w, h)
			local playercount = tostring(table.Count(v.players)) .. "/" .. (tostring(v.maxplayers) == "0" and game.MaxPlayers() or "0")
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
