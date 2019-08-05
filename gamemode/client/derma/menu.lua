include("topbar.lua")
include("settings.lua")
include("duel.lua")

local PANEL = {}

function PANEL:Init()
	self.Width = 800
	self.Height = 500

	//self.frame = vgui.Create("DFrame")
	self:SetDeleteOnClose(false)
	self:Close()
	self:SetTitle("")
	self:SetSize(self.Width, self.Height)
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:Center()
	self:SetSkin("Propkill")

	self.Tabs = {}

	//self.topBar = vgui.Create("PK.Topbar", self)
	//self.topBar:Dock(TOP)

	self.sheet = vgui.Create("DPropertySheet", self)
	self.sheet:Dock(FILL)

	self:RegisterTab("PK.Settings", "Settings", "icon16/cog.png")
	self:RegisterTab("PK.Duel", "Duel", "icon16/lightning.png")
end

function PANEL:Update()
	for k,v in pairs(self.Tabs) do
		v:Clear()
		v:Refresh()
	end
end

function PANEL:RegisterTab(dermaControl, name, icon)
	local newTab = vgui.Create(dermaControl, self.sheet)
	self.sheet:AddSheet(name, newTab, icon)
	table.insert(self.Tabs, newTab)
end

derma.DefineControl("PK.Menu", "PK Menu", PANEL, "DFrame")