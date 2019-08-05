local function Scoreboard(parent)
	local columns = vgui.Create("DPanel", parent)
	columns:SetHeight(30)
	columns:DockMargin(0,0,0,3)
	columns:Dock(TOP)
	function columns:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, colors.primary)
	end
	
	local col1 = vgui.Create("DPanel", columns)
	col1:Dock(LEFT)
	function col1:Paint(w, h)
		draw.SimpleText("Name", "pk_bindfont1", 15, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local col2 = vgui.Create("DPanel", columns)
	col2:Dock(LEFT)
	function col2:Paint(w, h)
		draw.SimpleText("Kills", "pk_bindfont1", 0, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	local col3 = vgui.Create("DPanel", columns)
	col3:Dock(LEFT)
	function col3:Paint(w, h)
		draw.SimpleText("Deaths", "pk_bindfont1", 0, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	local col4 = vgui.Create("DPanel", columns)
	col4:Dock(LEFT)
	function col4:Paint(w, h)
		draw.SimpleText("Ping", "pk_bindfont1", 0, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	local scroll = vgui.Create("DScrollPanel", parent)
	scroll:Dock(FILL)
	scroll.VBar:SetWidth(8)
	scroll.VBar:SetHideButtons(true)
	function scroll.VBar.btnGrip:Paint(w,h)
		draw.RoundedBox(4, 0, 0, w, h, colors.accent)
	end
	function scroll.VBar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors.primary)
	end
	
	function columns:PerformLayout()
		local colwidth = self:GetWide()+4
		
		if scroll.VBar.Enabled then
			colwidth = colwidth - 8
		end
		
		col1:SetWidth(colwidth * 0.55)
		col2:SetWidth(colwidth * 0.15)
		col3:SetWidth(colwidth * 0.15)
		col4:SetWidth(colwidth * 0.15+4)
	end
	
	local teams = vgui.Create("DIconLayout", scroll)
	teams:Dock(FILL)
	teams:SetSpaceX(3)
	teams:SetSpaceY(3)

	local function reloadPanel()
		if not IsValid(teams) then return end
		
		for k,v in pairs(teams:GetChildren()) do
			v:Remove()
		end

		for k,v in pairs(team.GetAllTeams()) do
			if #team.GetPlayers(k) == 0 then continue end

			local item = teams:Add("DPanel")
			function item:Paint(w, h)
				draw.RoundedBox(4, 0, 0, w, h, colors.primary)
			end

			local teamname = vgui.Create("DPanel", item)
			teamname:Dock(TOP)
			function teamname:Paint(w, h)
				draw.SimpleText(v.Name or "", "pk_teamfont", 5, h/2, team.GetColor(k), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			local players = vgui.Create("DIconLayout", item)
			players:DockMargin(5,0,5,0)
			players:DockPadding(0,0,0,5)
			players:Dock(TOP)
			players:SetSpaceY(3)
			function players:Paint(w, h) end

			for k,v in pairs(team.GetPlayers(k)) do
				local prow = players:Add("DPanel")
				prow:SetHeight(36)
				function prow:Paint(w, h)
					draw.RoundedBox(4, 0, 0, w, h, colors.primaryDark)
				end

				local name = vgui.Create("DPanel", prow)
				name:Dock(LEFT)
				function name:Paint(w, h)
					draw.SimpleText(v:Name() or "", "pk_playerfont", 10, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				local kills = vgui.Create("DPanel", prow)
				kills:Dock(LEFT)
				function kills:Paint(w, h)
					draw.SimpleText(v:Frags() or "", "pk_playerfont", 10, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				local deaths = vgui.Create("DPanel", prow)
				deaths:Dock(LEFT)
				function deaths:Paint(w, h)
					draw.SimpleText(v:Deaths() or "", "pk_playerfont", 10, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				local ping = vgui.Create("DPanel", prow)
				ping:Dock(LEFT)
				function ping:Paint(w, h)
					draw.SimpleText(v:Ping() or "", "pk_playerfont", 10, h/2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				function prow:PerformLayout()
					local colwidth = self:GetParent():GetWide()

					self:SetWidth(colwidth)
					name:SetWidth(colwidth * 0.55)
					kills:SetWidth(colwidth * 0.15)
					deaths:SetWidth(colwidth * 0.15)
					ping:SetWidth(colwidth * 0.15)
				end
			end

			function item:PerformLayout()
				local colwidth = self:GetParent():GetWide()
				
				teamname:SetSize(colwidth, 32)
				players:Layout()

				self:SizeToChildren(true, true)
			end

		end
		teams:InvalidateChildren(true)


		function teams:OnSizeChanged(w, h)
			self:InvalidateChildren(true)
		end
	end
	reloadPanel()
	return reloadPanel
end

return Scoreboard
