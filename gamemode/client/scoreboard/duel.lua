local PANEL = {}
PANEL.Base = "DPanel"

function PANEL:Init()
	self:Dock(FILL)

	local opponentselect = vgui.Create("DComboBox", self)
	opponentselect:Dock(TOP)
	opponentselect:SetSize(100, 20)
	opponentselect:SetValue("Select opponent")
	for k,v in pairs(player.GetAll()) do
		if v != LocalPlayer() then
			opponentselect:AddChoice(v:Nick())
		end
	end

	local duelinvitebutton = vgui.Create("DButton", self)
	duelinvitebutton:SetText("Send Invite")
	duelinvitebutton:Dock(TOP)
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
end

function PANEL:Refresh()

end

function PANEL:Paint(w, h)
	
end

return PANEL