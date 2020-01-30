local PANEL = {}
PANEL.Base = "DPanel"

function PANEL:Init()
	local scroll = vgui.Create("DScrollPanel", self)
	scroll:Dock(FILL)

	self.iconlayout = vgui.Create("DIconLayout", scroll)
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

function PANEL:Refresh()
	for k,v in pairs(self.iconlayout:GetChildren()) do
		v:Remove()
	end

	for k,v in pairs(PK.arenas) do
		local item = self.iconlayout:Add("DImageButton")

		item:SetImage(v.icon or "propkill/arena/downtown.png")
		item.DoClick = function()
			net.Start("PK_ArenaNetJoinArena")
				net.WriteString(k)
			net.SendToServer()
		end

		local overlay = vgui.Create("DPanel", item.m_Image)
		overlay:Dock(FILL)
		function overlay:Paint(w, h)
			local playercount = tostring(table.Count(v.players)) .. "/" .. (tostring(v.maxplayers) == "0" and game.MaxPlayers() or "0")
			surface.SetFont("pk_arenafont")
			local width = surface.GetTextSize(playercount)

			draw.RoundedBox(0, 0, h-30, w, 30, Color(0,0,0,200))
			draw.RoundedBox(3, w-width-9.5, 2, width+6.5, 20, Color(0,0,0,200))
			draw.SimpleText(v.gamemode.name or "none", "pk_arenafont", 10, h-15, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(playercount, "pk_arenafont", w-5, 12.5, colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		item.PerformLayout = function(this)
			local width = self.iconlayout:GetWide() / 5 - 8
			this:SetSize(width, 120)
			this.m_Image:SetSize(width, 120)
		end
	end
end

function PANEL:Paint(w, h)

end

return PANEL
