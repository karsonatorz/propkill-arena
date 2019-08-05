local PANEL = {}

function PANEL:Init()
	self.Height = 80
	self:SetHeight(self:GetSkin().FrameTopBarHeight)
	self:SetSkin("Propkill")
end

function SKIN:Paint(panel, w, h)
	draw.RoundedBox(0, 0, 0, w, self:GetSkin().FrameTopBarHeight, self:GetSkin().colors.frameTop)
end


derma.DefineControl("PK.Topbar", "Top bar of PK Menu", PANEL, "DPanel")