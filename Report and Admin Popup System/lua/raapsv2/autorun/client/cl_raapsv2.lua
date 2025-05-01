include("autorun/sh_raapsv2.lua")

function recreateFonts()
	surface.CreateFont("frameTitleFont", {
		font = "Roboto",
		size = 25 * (ScrW() / 1600),
		weight = 400,
	})
	surface.CreateFont("textReportFont", {
		font = "Roboto",
		size = 30 * (ScrW() / 1600),
	})
	surface.CreateFont("generalFont", {
		font = "Roboto",
		size = 20 * (ScrW() / 1600),
		weight = 400,
	})
	surface.CreateFont("buttonFont", {
		font = "Roboto",
		size = 25 * (ScrW() / 1600),
		weight = 500,
	})
	surface.CreateFont("plyInfoFont", {
		font = "Roboto",
		size = 15 * (ScrW() / 1600),
	})
	surface.CreateFont("popupTitleFont",{
		font = "Roboto",
		size = 13 * (ScrW() / 1600),
	})
	surface.CreateFont("specialFontForOneThing",{
		font = "Roboto",
		size = 12 * (ScrW() / 1600),
	})
	surface.CreateFont("popupGeneralFont", {
		font = "Roboto",
		size = 14 * (ScrW() / 1600),
	})
end
recreateFonts()

local canPlayerMakeReport = true

function RAAPS.createReport()
	recreateFonts()
	local frameW, frameH = 600 * (ScrW() / 1600), 100 * (ScrH() / 900)
	local scaleX, scaleY = (ScrW() / 1600), (ScrH() / 900)

	if not RAAPS.cfg.shouldAdminsCreateReports and isStaff(LocalPlayer()) then return end
	if not canPlayerMakeReport then LocalPlayer():ChatPrint("You already have an existing report.") return end

	local frame = vgui.Create("DFrame")
	frame:SetSize(0, 0)
	frame:Center()
	frame:MakePopup(true)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetVisible(true)
	local isAnimating = true
	frame:SizeTo(frameW, frameH * 5, 1, 0, 0.1, function() isAnimating = false end)

	function frame:Paint(w, h)
		draw.RoundedBox(15, 0, 0, w, h, Color(24, 42, 65, 255))
	end

	function frame:OnSizeChanged(w, h)
		if isAnimating then
			frame:Center()
		end
	end

	local closeButt = vgui.Create("DButton", frame)
	closeButt:SetPos(frameW * .967, 0)
	closeButt:SetSize(frameW * .04, frameH * .2)
	closeButt:SetText("x")
	closeButt:SetColor(Color(255, 255, 255, 255))
	closeButt:SetVisible(true)
	function closeButt:DoClick()
		frame:Remove()
	end
	function closeButt:Paint(w,h)
		surface.SetDrawColor(122, 20, 47, 255)
		surface.DrawRect(0, 0, w, h)
	end

	local frameTitle = vgui.Create("DLabel", frame)
	frameTitle:SetSize(frameW, 25)
	frameTitle:SetText("Report")
	frameTitle:SetFont("frameTitleFont")
	frameTitle:SetContentAlignment(5)

	local playersLabel = vgui.Create("DLabel", frame)
	playersLabel:SetText("Players included:")
	playersLabel:SetFont("frameTitleFont")
	playersLabel:SetPos(frameW * .05, frameH * .5)
	playersLabel:SetSize(frameW * .3, 30)

	local playersIncluded = {}

	local playersIncludedPanel = vgui.Create("DScrollPanel", frame)
	playersIncludedPanel:SetPos(frameW * .05, frameH * .8)
	playersIncludedPanel:SetSize(frameW * .9, frameH * .8)
	function playersIncludedPanel:Paint(w, h)
		surface.SetDrawColor(37, 50, 71, 255)
		surface.DrawRect(0, 0, w, h)
	end

	local addPlayerInReportButt = vgui.Create("DButton", frame)
	addPlayerInReportButt:SetColor(Color(255, 255, 255, 255))
	addPlayerInReportButt:SetFont("specialFontForOneThing") // DIFFERENCE HERE
	addPlayerInReportButt:SetText("Include player in report")
	addPlayerInReportButt:SetSize(160, 25)
	addPlayerInReportButt:SetPos(frameW * .5 - 75, frameH * .5)
	addPlayerInReportButt:SetContentAlignment(5)
	function addPlayerInReportButt:Paint(w, h)
		draw.RoundedBox(5, 0, 0, w, h, Color(65, 97, 138, 255))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/add.png"))
		surface.DrawTexturedRect(5, 5, 16, 16)
	end
	function addPlayerInReportButt:DoClick()
		local selectPlayerFrame = vgui.Create("DFrame", frame)
		selectPlayerFrame:SetTitle("")
		selectPlayerFrame:SetSize(300, 150)
		selectPlayerFrame:MakePopup(true)
		selectPlayerFrame:SetPos(frame:GetX() + ((frameW * .5) - 150), frame:GetY() + (frameH * 1.6))
		selectPlayerFrame:ShowCloseButton(false)
		function selectPlayerFrame:Paint(w, h)
			surface.SetDrawColor(18, 36, 59, 250)
			surface.DrawRect(0,0, w, h)
		end

		local selectPlayerCloseButt = vgui.Create("DButton", selectPlayerFrame)
		selectPlayerCloseButt:SetColor(Color(255, 255, 255, 255))
		selectPlayerCloseButt:SetPos(selectPlayerFrame:GetWide() - 20, 0)
		selectPlayerCloseButt:SetText("x")
		selectPlayerCloseButt:SetSize(20, 20)
		function selectPlayerCloseButt:DoClick()
			selectPlayerFrame:Remove()
		end
		function selectPlayerCloseButt:Paint(w, h)
			surface.SetDrawColor(122, 20, 47, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local selectPlayerFrameTitle = vgui.Create("DLabel", selectPlayerFrame)
		selectPlayerFrameTitle:SetSize(selectPlayerFrame:GetWide(), 20)
		selectPlayerFrameTitle:SetText("Select player")
		selectPlayerFrameTitle:SetFont("generalFont")
		selectPlayerFrameTitle:SetContentAlignment(5)

		local selectPlayerCombo = vgui.Create("DComboBox", selectPlayerFrame)
		selectPlayerCombo:SetPos(selectPlayerFrame:GetWide() * .05, selectPlayerFrame:GetTall() * .3)
		selectPlayerCombo:SetSize(selectPlayerFrame:GetWide() * .4, selectPlayerFrame:GetTall() * .15)

		local selectPlayerButt = vgui.Create("DButton", selectPlayerFrame)
		selectPlayerButt:SetColor(Color(255, 255, 255, 255))
		selectPlayerButt:SetText("Choose")
		selectPlayerButt:SetPos(selectPlayerFrame:GetWide() * .55, selectPlayerFrame:GetTall() * .3)
		selectPlayerButt:SetSize(selectPlayerFrame:GetWide() * .4, selectPlayerFrame:GetTall() * .15)
		function selectPlayerButt:DoClick()
			local selectedPlayer = selectPlayerCombo:GetOptionData(selectPlayerCombo:GetSelectedID())

			if selectedPlayer == nil then return end
			for k, v in pairs(playersIncluded) do
				if v == selectedPlayer then return end
			end

			table.insert(playersIncluded, selectedPlayer)

			local addedPly = vgui.Create("DPanel", playersIncludedPanel)
			addedPly:SetSize(playersIncludedPanel:GetWide(), 25)
			addedPly:Dock(TOP)
			function addedPly:Paint(w, h)
				surface.SetDrawColor(40, 60, 80, 255)
				surface.DrawRect(0,0,w,h)
			end

			local addedPlyAvatar = vgui.Create( "AvatarImage", addedPly)
			addedPlyAvatar:SetSize(25 * scaleX, 25 * scaleX)
			addedPlyAvatar:Dock(LEFT)
			addedPlyAvatar:SetPlayer(selectedPlayer, 64)

			local addedPlyName = vgui.Create("DLabel", addedPly)
			addedPlyName:SetColor(Color(255, 255, 255, 255))
			addedPlyName:SetSize(180 * scaleX, 0)
			addedPlyName:Dock(LEFT)
			addedPlyName:DockMargin(5, 0, 0, 0)
			addedPlyName:SetFont("plyInfoFont")
			addedPlyName:SetText(selectedPlayer:Nick())

			local addedPlySteamID = vgui.Create("DLabel", addedPly)
			addedPlySteamID:SetColor(Color(255, 255, 255, 255))
			addedPlySteamID:SetSize(200 * scaleX, 0)
			addedPlySteamID:Dock(LEFT)
			addedPlySteamID:DockMargin(0, 0, 0, 0)
			addedPlySteamID:SetFont("plyInfoFont")
			addedPlySteamID:SetText(selectedPlayer:SteamID())

			local addedPlyRank = vgui.Create("DLabel", addedPly)
			addedPlyRank:SetColor(Color(255, 255, 255, 255))
			addedPlyRank:SetSize(95 * scaleX, 0)
			addedPlyRank:Dock(LEFT)
			addedPlyRank:SetFont("plyInfoFont") // DIFFERENCE HERE
			addedPlyRank:SetText(selectedPlayer:GetUserGroup())

			local addedPlyRemove = vgui.Create("DButton", addedPly)
			addedPlyRemove:SetText("")
			addedPlyRemove:SetSize(25 * scaleX, 25 * scaleX)
			addedPlyRemove:Dock(LEFT)
			function addedPlyRemove:DoClick()
				addedPly:Remove()
				table.RemoveByValue(playersIncluded, selectedPlayer)
			end
			function addedPlyRemove:Paint(w, h)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(Material("icon16/cross.png"))
				surface.DrawTexturedRect(2, 5, 16, 16)
			end
		end
		function selectPlayerButt:Paint(w, h)
			if selectPlayerButt:IsHovered() then
				surface.SetDrawColor(48, 60, 75, 255)
			else
				surface.SetDrawColor(44, 56, 71, 255)
			end
			surface.DrawRect(0, 0, w, h)
		end

		for k, v in pairs(player.GetAll()) do
			if v != LocalPlayer() then
				selectPlayerCombo:AddChoice(v:Nick(), v)
			end
		end
	end

	table.insert(playersIncluded, LocalPlayer())

	local addedPly = vgui.Create("DPanel", playersIncludedPanel)
	addedPly:SetSize(playersIncludedPanel:GetWide(), 25)
	addedPly:Dock(TOP)
	function addedPly:Paint(w, h)
		surface.SetDrawColor(40, 60, 80, 255)
		surface.DrawRect(0,0,w,h)
	end

	local addedPlyAvatar = vgui.Create( "AvatarImage", addedPly)
	addedPlyAvatar:SetSize(25, 25)
	addedPlyAvatar:Dock(LEFT)
	addedPlyAvatar:SetPlayer(LocalPlayer(), 64)

	local addedPlyName = vgui.Create("DLabel", addedPly)
	addedPlyName:SetColor(Color(255, 255, 255, 255))
	addedPlyName:SetSize(180, 0)
	addedPlyName:Dock(LEFT)
	addedPlyName:DockMargin(5, 0, 0, 0)
	addedPlyName:SetFont("plyInfoFont")
	addedPlyName:SetText(LocalPlayer():Nick())

	local addedPlySteamID = vgui.Create("DLabel", addedPly)
	addedPlySteamID:SetColor(Color(255, 255, 255, 255))
	addedPlySteamID:SetSize(200, 0)
	addedPlySteamID:Dock(LEFT)
	addedPlySteamID:DockMargin(0, 0, 0, 0)
	addedPlySteamID:SetFont("plyInfoFont")
	addedPlySteamID:SetText(LocalPlayer():SteamID())

	local addedPlyRank = vgui.Create("DLabel", addedPly)
	addedPlyRank:SetColor(Color(255, 255, 255, 255))
	addedPlyRank:SetSize(100, 0)
	addedPlyRank:Dock(LEFT)
	addedPlyRank:SetText(LocalPlayer():GetUserGroup())

	local descriptionLabel = vgui.Create("DLabel", frame)
	descriptionLabel:SetFont("frameTitleFont")
	descriptionLabel:SetText("Report description:")
	descriptionLabel:SetPos(frameW * .05, frameH * 1.67)
	descriptionLabel:SetSize(frameW * .3, 30)

	local reportDescriptionBG = vgui.Create("DPanel", frame)
	reportDescriptionBG:SetPos(frameW * .05, frameH * 2)
	reportDescriptionBG:SetSize(frameW * .9, frameH * 2.6)
	reportDescriptionBG:SetVisible(true)
	function reportDescriptionBG:Paint(w, h)
		draw.RoundedBox(5, 0, 0, w, h, Color(65, 97, 138, 255))
	end

	local reportDescriptionTA = vgui.Create("DTextEntry", reportDescriptionBG)
	reportDescriptionTA:SetPos(0, 0)
	reportDescriptionTA:SetMultiline(true)
	reportDescriptionTA:SetFont("textReportFont")
	reportDescriptionTA:SetTextColor(Color(255, 255, 255, 255))
	reportDescriptionTA:SetPaintBackground(false)
	reportDescriptionTA:SetSize(frameW * .9, frameH * 2.6)
	reportDescriptionTA:SetDrawLanguageID(false)
	reportDescriptionTA:SetMaximumCharCount(170)

	local reportDescriptionLabel = vgui.Create("DLabel", frame)
	reportDescriptionLabel:SetPos(frameW * .81, frameH * 4.35)
	reportDescriptionLabel:SetSize(100, 25)
	reportDescriptionLabel:SetText("0/170")
	reportDescriptionLabel:SetContentAlignment(5)
	reportDescriptionLabel:SetFont("generalFont")
	function reportDescriptionTA:OnTextChanged(arg)
		local text = reportDescriptionTA:GetText()
		local textLen = string.len(text)
		
		reportDescriptionLabel:SetText(textLen .. "/" .. reportDescriptionTA:GetMaximumCharCount())
	end


	local reportSendButt = vgui.Create("DButton", frame)
	reportSendButt:SetPos(frameW * .05, frameH * 4.65)
	reportSendButt:SetColor(Color(255, 255, 255, 255))
	reportSendButt:SetFont("buttonFont")
	reportSendButt:SetSize(frameW * .9, 25)
	reportSendButt:SetText("SEND REPORT")
	function reportSendButt:DoClick()
		frame:Remove()
		canPlayerMakeReport = false
		LocalPlayer():ChatPrint("Use #(message) to provide any more info that you may have about your report.")

		net.Start("sendPopup")
			net.WriteTable(playersIncluded)
			net.WriteString(reportDescriptionTA:GetText())
		net.SendToServer()
	end
	function reportSendButt:Paint(w, h)
		surface.SetDrawColor(37, 50, 71, 255)
		surface.DrawRect(0, 0, w, h)
	end
end

activeClaims = {}

function RAAPS.createPopup(players, msg)
	recreateFonts()
	local popupFrameW, popupFrameH = 265 * (ScrW() / 1600), 100 * (ScrH() / 900)
	local scaleX, scaleY = (ScrW() / 1600), (ScrH() / 900)

	local frame = vgui.Create("DFrame")
	frame:SetSize(popupFrameW, popupFrameH)
	frame:SetPos(20, 20 + ((popupFrameH + 5) * #activeClaims))
	frame:ShowCloseButton(false)
	frame:SetTitle("")
	function frame:Paint(w, h)
		draw.RoundedBox(5, 0, 0, w, h, Color(24, 42, 65, 250))
	end

	function frame:OnRemove()
		table.RemoveByValue(activeClaims, frame)
		for k,v in pairs(activeClaims) do
			v:SetPos(20, 20 + ((popupFrameH + 5) * (k - 1)))
		end
	end

	local frameTitleBar = vgui.Create("DPanel", frame)
	frameTitleBar:SetSize(popupFrameW, popupFrameH * 1.5)
	frameTitleBar:SetPos(0, 0)
	function frameTitleBar:Paint(w, h)
		surface.SetDrawColor(14, 32, 55, 250)
		surface.DrawRect(0, 0, w, h * .1)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/user_red.png"))
		surface.DrawTexturedRect(4, 1, 12, 12)
	end

	local closeButt = vgui.Create("DButton", frameTitleBar)
	closeButt:SetColor(Color(255, 255, 255, 255))
	closeButt:SetText("x")
	closeButt:SetPos(popupFrameW * .96, 0)
	closeButt:SetSize(5, 10)
	function closeButt:DoClick()
		frame:Remove()
	end
	function closeButt:Paint(w, h) end

	local frameTitle = vgui.Create("DLabel", frameTitleBar)
	frameTitle:SetColor(Color(255, 255, 255, 255))
	if #players - 1 == 0 then
		frameTitle:SetText(players[1]:Nick())
	else
		frameTitle:SetText(players[1]:Nick() .. " + " .. #players - 1 .. " more")
	end
	
	frameTitle:SetFont("popupTitleFont")
	frameTitle:SetPos(18, 2)
	frameTitle:SetSize(popupFrameW * .89, 10)

	local popupDescription = vgui.Create("RichText", frame)
	popupDescription:InsertColorChange(255, 255, 255, 255)
	popupDescription:SetPos(popupFrameW * .01, popupFrameH * .175)
	popupDescription:SetSize(popupFrameW * .98, 60)
	function popupDescription:PerformLayout()
		self:SetFontInternal("popupGeneralFont")
	end
	popupDescription:SetVisible(true)
	popupDescription:SetVerticalScrollbarEnabled(false)
	popupDescription:AppendText(msg)

	local playersLabel = vgui.Create("DLabel", frame)
	playersLabel:SetColor(Color(255, 255, 255, 255))
	playersLabel:SetSize(popupFrameW, 16)
	playersLabel:SetFont("plyInfoFont")
	playersLabel:SetPos(0, popupFrameH * .82)
	playersLabel:SetText("  Players:")
	playersLabel:SetVisible(false)
	function playersLabel:Paint(w, h)
		surface.SetDrawColor(54, 72, 95, 250)
		surface.DrawRect(0, 0, w, h)
	end

	local popupAllPlayers = vgui.Create("DScrollPanel", frame)
	popupAllPlayers:SetSize(0, 0)
	popupAllPlayers:SetPos(popupFrameW * .01, popupFrameH * 1)
	function popupAllPlayers:Paint(w, h)
		surface.SetDrawColor(65, 97, 138, 255)
		surface.DrawRect(0, 0, w, h)
	end

	local sbar = popupAllPlayers:GetVBar()
	sbar:SetSize(5, 0)
	function sbar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(34, 52, 75, 250))
	end
	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(30, (w * .5) - ((w * .5) / 2), 0, w * .5, h, Color(14, 32, 55, 250))
	end
	function sbar.btnUp:Paint(w, h) end
	function sbar.btnDown:Paint(w, h) end

	local popupCloseButt = vgui.Create("DButton", frame)
	popupCloseButt:SetFont("popupGeneralFont")
	popupCloseButt:SetColor(Color(255, 255, 255, 255))
	popupCloseButt:SetText("Close")
	popupCloseButt:SetSize(popupFrameW * .2, popupFrameH *  .15)
	popupCloseButt:SetVisible(false)
	function popupCloseButt:Paint(w, h)
		draw.RoundedBox(3, 0, 0, w, h, Color(65, 97, 138, 255))
	end
	function popupCloseButt:DoClick()
		frame:Remove()

		net.Start("closeCase")
			net.WriteEntity(players[1])
		net.SendToServer()

		for m, s in pairs(activeClaims) do
			s:Show()
		end
	end

	local popupAddPlayers = vgui.Create("DButton", frame)
	popupAddPlayers:SetSize(popupFrameW * .35, popupFrameH * .15)
	popupAddPlayers:SetFont("popupGeneralFont")
	popupAddPlayers:SetColor(Color(255, 255, 255, 255))
	popupAddPlayers:SetText("  Add players")
	popupAddPlayers:SetVisible(false)
	function popupAddPlayers:Paint(w, h)
		draw.RoundedBox(3, 0, 0, w, h, Color(65, 97, 138, 255))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/add.png"))
		surface.DrawTexturedRect(0, 0, 16, 16)
	end
	function popupAddPlayers:DoClick()
		local addDudesFrame = vgui.Create("DFrame", frame)
		addDudesFrame:SetTitle("")
		addDudesFrame:SetSize(300, 150)
		addDudesFrame:MakePopup(true)
		addDudesFrame:Center()
		addDudesFrame:ShowCloseButton(false)
		function addDudesFrame:Paint(w, h)
			surface.SetDrawColor(18, 36, 59, 250)
			surface.DrawRect(0,0, w, h)
		end

		local addDudesCloseButt = vgui.Create("DButton", addDudesFrame)
		addDudesCloseButt:SetColor(Color(255, 255, 255, 255))
		addDudesCloseButt:SetPos(addDudesFrame:GetWide() - 20, 0)
		addDudesCloseButt:SetText("x")
		addDudesCloseButt:SetSize(20, 20)
		function addDudesCloseButt:DoClick()
			addDudesFrame:Remove()
		end
		function addDudesCloseButt:Paint(w, h)
			surface.SetDrawColor(122, 20, 47, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local addDudesFrameTitle = vgui.Create("DLabel", addDudesFrame)
		addDudesFrameTitle:SetSize(addDudesFrame:GetWide(), 20)
		addDudesFrameTitle:SetText("Select player")
		addDudesFrameTitle:SetFont("generalFont")
		addDudesFrameTitle:SetContentAlignment(5)

		local addDudesCombo = vgui.Create("DComboBox", addDudesFrame)
		addDudesCombo:SetPos(addDudesFrame:GetWide() * .05, addDudesFrame:GetTall() * .3)
		addDudesCombo:SetSize(addDudesFrame:GetWide() * .4, addDudesFrame:GetTall() * .15)

		for k, v in pairs(player.GetAll()) do
			if v ~= LocalPlayer() and not table.HasValue(players, v) then
				addDudesCombo:AddChoice(v:Nick(), v)
			end
		end

		local addDudesButt = vgui.Create("DButton", addDudesFrame)
		addDudesButt:SetColor(Color(255, 255, 255, 255))
		addDudesButt:SetText("Choose")
		addDudesButt:SetPos(addDudesFrame:GetWide() * .55, addDudesFrame:GetTall() * .3)
		addDudesButt:SetSize(addDudesFrame:GetWide() * .4, addDudesFrame:GetTall() * .15)
		function addDudesButt:DoClick()
			local selectedPlayer = addDudesCombo:GetOptionData(addDudesCombo:GetSelectedID())

			net.Start("updatePlayersInClaim")
				net.WriteEntity(players[1])
				net.WriteEntity(selectedPlayer)
				net.WriteBool(true)
			net.SendToServer()
		end
		function addDudesButt:Paint(w, h)
			if addDudesButt:IsHovered() then
				surface.SetDrawColor(48, 60, 75, 255)
			else
				surface.SetDrawColor(44, 56, 71, 255)
			end
			surface.DrawRect(0, 0, w, h)
		end
	end

	local popupClaimButt = vgui.Create("DButton", frame)
	popupClaimButt:SetFont("popupGeneralFont")
	popupClaimButt:SetColor(Color(255, 255, 255, 255))
	popupClaimButt:SetText("Claim")
	popupClaimButt:SetPos(popupFrameW * .76, popupFrameH * .82)
	popupClaimButt:SetSize(60 * scaleX, 15 * scaleY) // DIFFERENCE HERE
	function popupClaimButt:Paint(w, h)
		draw.RoundedBox(3, 0, 0, w, h, Color(65, 97, 138, 255))
	end

	frame.caller = players[1]
	frame.title = frameTitle
	frame.close = closeButt
	frame.claimButt = popupClaimButt
	frame.players = popupAllPlayers
	frame.closeButt = popupCloseButt
	frame.playersLbl = playersLabel
	frame.playersIn = players
	frame.desc = popupDescription
	frame.addPlayers = popupAddPlayers

	function popupClaimButt:DoClick()
		table.insert(players, LocalPlayer())

		net.Start("claimCase")
			net.WriteEntity(players[1])
		net.SendToServer()

		// Hide every other popup, than the one that was claimed
		for p, q in pairs(activeClaims) do
			if q.caller ~= players[1] then
				q:Hide()
			end
		end

		popupClaimButt:SetVisible(false)
		closeButt:SetVisible(false)
		popupCloseButt:SetVisible(true)
		playersLabel:SetVisible(true)
		popupAddPlayers:SetVisible(true)
		frame:SizeTo(popupFrameW, (popupFrameH + (#players * 20)) + 20, 1, 0, .1, function() end)
		popupAllPlayers:SetSize(popupFrameW * .985, (#players * 20))
		popupCloseButt:SetPos(popupFrameW - (popupFrameW * .21), (popupFrameH + (((#players) * 20))) + 1)
		popupAddPlayers:SetPos(popupFrameW - (popupFrameW * .99), (popupFrameH + (((#players) * 20))) + 1)

		frameTitle:SetText(players[1]:Nick() .. " + " .. #players - 1 .. " more")

		for k, v in pairs(players) do
			local dude = vgui.Create("DPanel", popupAllPlayers)
			dude:SetSize(popupAllPlayers:GetWide(), 20)
			dude:Dock(TOP)
			function dude:Paint(w, h)
				surface.SetDrawColor(40, 60, 80, 255)
				surface.DrawRect(0, 0, w, h)
			end

			local dudeAvatar = vgui.Create( "AvatarImage", dude)
			dudeAvatar:SetSize(20, 20)
			dudeAvatar:Dock(LEFT)
			dudeAvatar:SetPlayer(v, 64)

			local extendedDude = false

			local dudeName = vgui.Create("DLabel", dude)
			if v == LocalPlayer() then
				dudeName:SetColor(Color(138, 15, 36, 255))
			elseif v == players[1] then
				dudeName:SetColor(Color(86, 129, 184, 255))
			else
				dudeName:SetColor(Color(255, 255, 255, 255))
			end
			dudeName:SetSize(105, 0)
			dudeName:Dock(LEFT)
			dudeName:DockMargin(5, 0, 0, 0)
			dudeName:SetFont("plyInfoFont")
			dudeName:SetMouseInputEnabled( true )
			dudeName:SetCursor("hand")
			dudeName:SetText(v:Nick())

			local dudeSteamID = vgui.Create("DLabel", dude)
			dudeSteamID:SetColor(Color(200, 200, 200, 255))
			dudeSteamID:SetSize(130, 0)
			dudeSteamID:Dock(LEFT)
			dudeSteamID:SetFont("plyInfoFont")
			dudeSteamID:SetText(v:SteamID())

			local dudeButtonGoto = vgui.Create("DButton", dude)
			dudeButtonGoto:SetFont("popupGeneralFont")
			dudeButtonGoto:SetColor(Color(255, 255, 255, 255))
			dudeButtonGoto:SetText("Goto")
			dudeButtonGoto:SetSize(43, 20)
			dudeButtonGoto:SetPos(0, dude:GetTall())
			function dudeButtonGoto:Paint(w, h)
				surface.SetDrawColor(65, 97, 138, 255)
				surface.DrawRect(w * .05, 0, w * .9, h)
			end
			function dudeButtonGoto:DoClick()
				if not IsValid(v) then LocalPlayer():ChatPrint("Something went wrong.") return end
				LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Goto .. v:Nick())
			end

			local dudeButtonBring = vgui.Create("DButton", dude)
			dudeButtonBring:SetFont("popupGeneralFont")
			dudeButtonBring:SetColor(Color(255, 255, 255, 255))
			dudeButtonBring:SetText("Bring")
			dudeButtonBring:SetSize(43, 20)
			dudeButtonBring:SetPos(43, dude:GetTall())
			function dudeButtonBring:Paint(w, h)
				surface.SetDrawColor(65, 97, 138, 255)
				surface.DrawRect(w * .05, 0, w * .9, h)
			end
			function dudeButtonBring:DoClick()
				if not IsValid(v) then LocalPlayer():ChatPrint("Something went wrong.") return end
				LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Bring .. v:Nick())
			end

			local dudeButtonReturn = vgui.Create("DButton", dude)
			dudeButtonReturn:SetFont("popupGeneralFont")
			dudeButtonReturn:SetColor(Color(255, 255, 255, 255))
			dudeButtonReturn:SetText("Return")
			dudeButtonReturn:SetSize(43, 20)
			dudeButtonReturn:SetPos(86, dude:GetTall())
			function dudeButtonReturn:Paint(w, h)
				surface.SetDrawColor(65, 97, 138, 255)
				surface.DrawRect(w * .05, 0, w * .9, h)
			end
			function dudeButtonReturn:DoClick()
				if not IsValid(v) then LocalPlayer():ChatPrint("Something went wrong.") return end
				LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Return .. v:Nick())
			end

			local dudeFrozen = false

			local dudeButtonFreeze = vgui.Create("DButton", dude)
			dudeButtonFreeze:SetFont("popupGeneralFont")
			dudeButtonFreeze:SetColor(Color(255, 255, 255, 255))
			dudeButtonFreeze:SetText("Freeze")
			dudeButtonFreeze:SetSize(43, 20)
			dudeButtonFreeze:SetPos(129, dude:GetTall())
			function dudeButtonFreeze:Paint(w, h)
				surface.SetDrawColor(65, 97, 138, 255)
				surface.DrawRect(w * .05, 0, w * .9, h)
			end
			function dudeButtonFreeze:DoClick()
				if not IsValid(v) then LocalPlayer():ChatPrint("Something went wrong.") return end

				if not dudeFrozen then
					LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Freeze .. v:Nick())
					dudeFrozen = true
				else
					LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Unfreeze .. v:Nick())
					dudeFrozen = false
				end
			end

			local dudeMuted = false

			local dudeButtonMute = vgui.Create("DButton", dude)
			dudeButtonMute:SetFont("popupGeneralFont")
			dudeButtonMute:SetColor(Color(255, 255, 255, 255))
			dudeButtonMute:SetText("Mute")
			dudeButtonMute:SetSize(43, 20)
			dudeButtonMute:SetPos(172, dude:GetTall())
			function dudeButtonMute:Paint(w, h)
				surface.SetDrawColor(65, 97, 138, 255)
				surface.DrawRect(w * .05, 0, w * .9, h)
			end
			function dudeButtonMute:DoClick()
				if not IsValid(v) then LocalPlayer():ChatPrint("Something went wrong.") return end

				if not dudeMuted then
					LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Mute .. v:Nick())
					dudeMuted = true
				else
					LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Unmute .. v:Nick())
					dudeMuted = false
				end				
			end

			if v ~= players[1] and not isStaff(v) then  
				local dudeButtonRemove = vgui.Create('DButton', dude)
				dudeButtonRemove:SetFont("popupGeneralFont")
				dudeButtonRemove:SetColor(Color(255, 255, 255, 255))
				dudeButtonRemove:SetText("")
				dudeButtonRemove:SetSize(43, 20)
				dudeButtonRemove:SetPos(215, dude:GetTall())
				function dudeButtonRemove:Paint(w, h)
					surface.SetDrawColor(65, 97, 138, 255)
					surface.DrawRect(w * .05, 0, w * .9, h)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(Material("icon16/cross.png"))
					surface.DrawTexturedRect(w / 2 - 8, h / 2 - 8, 16, 16)
				end
				function dudeButtonRemove:DoClick()
					net.Start("updatePlayersInClaim")
						net.WriteEntity(players[1])
						net.WriteEntity(v)
						net.WriteBool(false)
					net.SendToServer()

					table.RemoveByValue(players, v)
					self:GetParent():Remove()

					frame:SizeTo(popupFrameW, (popupFrameH + (#players * 20)) + 19, 1, 0, .1, function() end)
					popupAllPlayers:SetSize(popupFrameW * .985, (#players * 20))
					popupCloseButt:SetPos(popupFrameW - (popupFrameW * .21), (popupFrameH + (((#players) * 20))) + 2)
					popupAddPlayers:SetPos(popupFrameW - (popupFrameW * .99), (popupFrameH + (((#players) * 20))) + 2)
				end
			end

			function dudeName:DoClick()
				if not IsValid(v) then 
					dude:SetSize(0, 20)
					dudeAvatar:DockMargin(0, 0, 0, 0)
					dudeName:DockMargin(5, 0, 0, 0)
					dudeSteamID:DockMargin(0, 0, 0, 0)
					extendedDude = false
					function dude:Paint(w, h)
						surface.SetDrawColor(102, 102, 102, 255)
						surface.DrawRect(0, 0, w, h)
					end 
					return 
				end
				if not extendedDude then
					dude:SizeTo(popupAllPlayers:GetWide(), 40, 1, 0, .1, function() end)
					dudeAvatar:DockMargin(0, 0, 0, 20)
					dudeName:DockMargin(5, 0, 0, 20)
					dudeSteamID:DockMargin(0, 0, 0, 20)
					extendedDude = true
				else
					dude:SizeTo(popupAllPlayers:GetWide(), 20, 1, 0, .1, function() end)
					dudeAvatar:DockMargin(0, 0, 0, 0)
					dudeName:DockMargin(5, 0, 0, 0)
					dudeSteamID:DockMargin(0, 0, 0, 0)
					extendedDude = false
				end
			end
		end
	end

	table.insert(activeClaims, frame)
end

net.Receive("claimCase", function(len, ply)
	local vict = net.ReadEntity()
	local admn = net.ReadEntity()

	local popupFrameW, popupFrameH = 265 * (ScrW() / 1600), 100 * (ScrH() / 900)

	if LocalPlayer() == vict then
		LocalPlayer():ChatPrint("Someone claimed your case.")
		return
	end

	for k, v in pairs(activeClaims) do
		if v.caller == vict then
			table.insert(v.playersIn, admn)
			v.claimButt:SetText("Join claim")
			function v.claimButt:DoClick()
				net.Start("updatePlayersInClaim")
					net.WriteEntity(vict)
					net.WriteEntity(LocalPlayer()) // I know this shouldn't be done, but it's needed because of the data the message reads
					net.WriteBool(true)
				net.SendToServer()

				v.claimButt:SetVisible(false)
				v.close:SetVisible(false)
				v.closeButt:SetVisible(true)
				v.playersLbl:SetVisible(true)
				v.addPlayers:SetVisible(true)

				v:SizeTo(popupFrameW, (popupFrameH + (#v.playersIn * 20)) + 20, 1, 0, .1, function() end)
				v.players:SetSize(popupFrameW * .985, (#v.playersIn * 20))
				v.closeButt:SetPos(popupFrameW - (popupFrameW * .21), (popupFrameH + (((#v.playersIn) * 20))) + 2)
				v.addPlayers:SetPos(popupFrameW - (popupFrameW * .99), (popupFrameH + (((#v.playersIn) * 20))) + 2)

				for key, val in pairs(v.playersIn) do
					local dude = vgui.Create("DPanel", v.players)
					dude:SetSize(v.players:GetWide(), 20)
					dude:Dock(TOP)
					function dude:Paint(w, h)
						surface.SetDrawColor(40, 60, 80, 255)
						surface.DrawRect(0, 0, w, h)
					end

					local dudeAvatar = vgui.Create( "AvatarImage", dude)
					dudeAvatar:SetSize(20, 20)
					dudeAvatar:Dock(LEFT)
					dudeAvatar:SetPlayer(val, 64)

					local extendedDude = false

					local dudeName = vgui.Create("DLabel", dude)
					if isStaff(val) then
						dudeName:SetColor(Color(138, 15, 36, 255))
					elseif val == v.playersIn[1] then
						dudeName:SetColor(Color(86, 129, 184, 255))
					else
						dudeName:SetColor(Color(255, 255, 255, 255))
					end
					dudeName:SetSize(105, 0)
					dudeName:Dock(LEFT)
					dudeName:DockMargin(5, 0, 0, 0)
					dudeName:SetFont("plyInfoFont")
					dudeName:SetMouseInputEnabled( true )
					dudeName:SetCursor("hand")
					dudeName:SetText(val:Nick())

					local dudeSteamID = vgui.Create("DLabel", dude)
					dudeSteamID:SetColor(Color(200, 200, 200, 255))
					dudeSteamID:SetSize(130, 0)
					dudeSteamID:Dock(LEFT)
					dudeSteamID:SetFont("plyInfoFont")
					dudeSteamID:SetText(val:SteamID())

					local dudeButtonGoto = vgui.Create("DButton", dude)
					dudeButtonGoto:SetFont("popupGeneralFont")
					dudeButtonGoto:SetColor(Color(255, 255, 255, 255))
					dudeButtonGoto:SetText("Goto")
					dudeButtonGoto:SetSize(43, 20)
					dudeButtonGoto:SetPos(0, dude:GetTall())
					function dudeButtonGoto:Paint(w, h)
						surface.SetDrawColor(65, 97, 138, 255)
						surface.DrawRect(w * .05, 0, w * .9, h)
					end
					function dudeButtonGoto:DoClick()
						if not IsValid(val) then LocalPlayer():ChatPrint("Something went wrong.") return end
						LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Goto .. val:Nick())
					end

					local dudeButtonBring = vgui.Create("DButton", dude)
					dudeButtonBring:SetFont("popupGeneralFont")
					dudeButtonBring:SetColor(Color(255, 255, 255, 255))
					dudeButtonBring:SetText("Bring")
					dudeButtonBring:SetSize(43, 20)
					dudeButtonBring:SetPos(43, dude:GetTall())
					function dudeButtonBring:Paint(w, h)
						surface.SetDrawColor(65, 97, 138, 255)
						surface.DrawRect(w * .05, 0, w * .9, h)
					end
					function dudeButtonBring:DoClick()
						if not IsValid(val) then LocalPlayer():ChatPrint("Something went wrong.") return end
						LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Bring .. val:Nick())
					end

					local dudeButtonReturn = vgui.Create("DButton", dude)
					dudeButtonReturn:SetFont("popupGeneralFont")
					dudeButtonReturn:SetColor(Color(255, 255, 255, 255))
					dudeButtonReturn:SetText("Return")
					dudeButtonReturn:SetSize(43, 20)
					dudeButtonReturn:SetPos(86, dude:GetTall())
					function dudeButtonReturn:Paint(w, h)
						surface.SetDrawColor(65, 97, 138, 255)
						surface.DrawRect(w * .05, 0, w * .9, h)
					end
					function dudeButtonReturn:DoClick()
						if not IsValid(val) then LocalPlayer():ChatPrint("Something went wrong.") return end
						LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Return .. val:Nick())
					end

					local dudeFrozen = false

					local dudeButtonFreeze = vgui.Create("DButton", dude)
					dudeButtonFreeze:SetFont("popupGeneralFont")
					dudeButtonFreeze:SetColor(Color(255, 255, 255, 255))
					dudeButtonFreeze:SetText("Freeze")
					dudeButtonFreeze:SetSize(43, 20)
					dudeButtonFreeze:SetPos(129, dude:GetTall())
					function dudeButtonFreeze:Paint(w, h)
						surface.SetDrawColor(65, 97, 138, 255)
						surface.DrawRect(w * .05, 0, w * .9, h)
					end
					function dudeButtonFreeze:DoClick()
						if not IsValid(val) then LocalPlayer():ChatPrint("Something went wrong.") return end

						if not dudeFrozen then
							LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Freeze .. val:Nick())
							dudeFrozen = true
						else
							LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Unfreeze .. val:Nick())
							dudeFrozen = false
						end
					end

					local dudeMuted = false

					local dudeButtonMute = vgui.Create("DButton", dude)
					dudeButtonMute:SetFont("popupGeneralFont")
					dudeButtonMute:SetColor(Color(255, 255, 255, 255))
					dudeButtonMute:SetText("Mute")
					dudeButtonMute:SetSize(43, 20)
					dudeButtonMute:SetPos(172, dude:GetTall())
					function dudeButtonMute:Paint(w, h)
						surface.SetDrawColor(65, 97, 138, 255)
						surface.DrawRect(w * .05, 0, w * .9, h)
					end
					function dudeButtonMute:DoClick()
						if not IsValid(val) then LocalPlayer():ChatPrint("Something went wrong.") return end

						if not dudeMuted then
							LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Mute .. val:Nick())
							dudeMuted = true
						else
							LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Unmute .. val:Nick())
							dudeMuted = false
						end				
					end

					if val ~= v.playersIn[1] and not isStaff(val) then  
						local dudeButtonRemove = vgui.Create('DButton', dude)
						dudeButtonRemove:SetFont("popupGeneralFont")
						dudeButtonRemove:SetColor(Color(255, 255, 255, 255))
						dudeButtonRemove:SetText("")
						dudeButtonRemove:SetSize(43, 20)
						dudeButtonRemove:SetPos(215, dude:GetTall())
						function dudeButtonRemove:Paint(w, h)
							surface.SetDrawColor(65, 97, 138, 255)
							surface.DrawRect(w * .05, 0, w * .9, h)
							surface.SetDrawColor(255, 255, 255, 255)
							surface.SetMaterial(Material("icon16/cross.png"))
							surface.DrawTexturedRect(w / 2 - 8, h / 2 - 8, 16, 16)
						end
						function dudeButtonRemove:DoClick()
							net.Start("updatePlayersInClaim")
								net.WriteEntity(v.playersIn[1])
								net.WriteEntity(val)
								net.WriteBool(false)
							net.SendToServer()

							table.RemoveByValue(v.playersIn, val)
							self:GetParent():Remove()
						end
					end

					function dudeName:DoClick()
						if not IsValid(val) then 
							dude:SetSize(0, 20)
							dudeAvatar:DockMargin(0, 0, 0, 0)
							dudeName:DockMargin(5, 0, 0, 0)
							dudeSteamID:DockMargin(0, 0, 0, 0)
							extendedDude = false
							function dude:Paint(w, h)
								surface.SetDrawColor(102, 102, 102, 255)
								surface.DrawRect(0, 0, w, h)
							end 
							return 
						end
						if not extendedDude then
							dude:SizeTo(v.players:GetWide(), 40, 1, 0, .1, function() end)
							dudeAvatar:DockMargin(0, 0, 0, 20)
							dudeName:DockMargin(5, 0, 0, 20)
							dudeSteamID:DockMargin(0, 0, 0, 20)
							extendedDude = true
						else
							dude:SizeTo(v.players:GetWide(), 20, 1, 0, .1, function() end)
							dudeAvatar:DockMargin(0, 0, 0, 0)
							dudeName:DockMargin(5, 0, 0, 0)
							dudeSteamID:DockMargin(0, 0, 0, 0)
							extendedDude = false
						end
					end
				end
			end
			function v.claimButt:Paint(w, h)
				draw.RoundedBox(3, 0, 0, w, h, Color(166, 184, 37, 255))
			end
			v.title:SetText(v.playersIn[1]:Nick() .. " + " .. #v.playersIn - 1 .. " more")
		end
	end
end)

net.Receive("updatePlayersInClaim", function(len, ply)
	local victim = net.ReadEntity()
	local playerInfo = net.ReadEntity()
	local isAdding = net.ReadBool()

	local popupFrameW, popupFrameH = 265 * (ScrW() / 1600), 100 * (ScrH() / 900)

	-- print(activeClaims[1]:GetChild(7):GetChild(0):GetChild(1):GetChild(2):GetText())

	for k, v in pairs(activeClaims) do
		if v.caller == victim then
			if isAdding then
				table.insert(v.playersIn, playerInfo)
				for key, val in pairs(v.playersIn) do -- This is an additional check, so that an added player doesnt get two panels
					if val == LocalPlayer() and isStaff(val) then
						local dude = vgui.Create("DPanel", v.players)
						dude:SetSize(v.players:GetWide(), 20)
						dude:Dock(TOP)
						function dude:Paint(w, h)
							surface.SetDrawColor(40, 60, 80, 255)
							surface.DrawRect(0, 0, w, h)
						end

						local dudeAvatar = vgui.Create( "AvatarImage", dude)
						dudeAvatar:SetSize(20, 20)
						dudeAvatar:Dock(LEFT)
						dudeAvatar:SetPlayer(playerInfo, 64)

						local extendedDude = false

						local dudeName = vgui.Create("DLabel", dude)
						if isStaff(playerInfo) then
							dudeName:SetColor(Color(138, 15, 36, 255))
						elseif playerInfo == v.playersIn[1] then
							dudeName:SetColor(Color(86, 129, 184, 255))
						else
							dudeName:SetColor(Color(255, 255, 255, 255))
						end
						dudeName:SetSize(105, 0)
						dudeName:Dock(LEFT)
						dudeName:DockMargin(5, 0, 0, 0)
						dudeName:SetFont("plyInfoFont")
						dudeName:SetMouseInputEnabled( true )
						dudeName:SetCursor("hand")
						dudeName:SetText(playerInfo:Nick())

						local dudeSteamID = vgui.Create("DLabel", dude)
						dudeSteamID:SetColor(Color(200, 200, 200, 255))
						dudeSteamID:SetSize(130, 0)
						dudeSteamID:Dock(LEFT)
						dudeSteamID:SetFont("plyInfoFont")
						dudeSteamID:SetText(playerInfo:SteamID())

						local dudeButtonGoto = vgui.Create("DButton", dude)
						dudeButtonGoto:SetFont("popupGeneralFont")
						dudeButtonGoto:SetColor(Color(255, 255, 255, 255))
						dudeButtonGoto:SetText("Goto")
						dudeButtonGoto:SetSize(43, 20)
						dudeButtonGoto:SetPos(0, dude:GetTall())
						function dudeButtonGoto:Paint(w, h)
							surface.SetDrawColor(65, 97, 138, 255)
							surface.DrawRect(w * .05, 0, w * .9, h)
						end
						function dudeButtonGoto:DoClick()
							if not IsValid(playerInfo) then LocalPlayer():ChatPrint("Something went wrong.") return end
							LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Goto .. playerInfo:Nick())
						end

						local dudeButtonBring = vgui.Create("DButton", dude)
						dudeButtonBring:SetFont("popupGeneralFont")
						dudeButtonBring:SetColor(Color(255, 255, 255, 255))
						dudeButtonBring:SetText("Bring")
						dudeButtonBring:SetSize(43, 20)
						dudeButtonBring:SetPos(43, dude:GetTall())
						function dudeButtonBring:Paint(w, h)
							surface.SetDrawColor(65, 97, 138, 255)
							surface.DrawRect(w * .05, 0, w * .9, h)
						end
						function dudeButtonBring:DoClick()
							if not IsValid(playerInfo) then LocalPlayer():ChatPrint("Something went wrong.") return end
							LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Bring .. playerInfo:Nick())
						end

						local dudeButtonReturn = vgui.Create("DButton", dude)
						dudeButtonReturn:SetFont("popupGeneralFont")
						dudeButtonReturn:SetColor(Color(255, 255, 255, 255))
						dudeButtonReturn:SetText("Return")
						dudeButtonReturn:SetSize(43, 20)
						dudeButtonReturn:SetPos(86, dude:GetTall())
						function dudeButtonReturn:Paint(w, h)
							surface.SetDrawColor(65, 97, 138, 255)
							surface.DrawRect(w * .05, 0, w * .9, h)
						end
						function dudeButtonReturn:DoClick()
							if not IsValid(playerInfo) then LocalPlayer():ChatPrint("Something went wrong.") return end
							LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Return .. playerInfo:Nick())
						end

						local dudeFrozen = false

						local dudeButtonFreeze = vgui.Create("DButton", dude)
						dudeButtonFreeze:SetFont("popupGeneralFont")
						dudeButtonFreeze:SetColor(Color(255, 255, 255, 255))
						dudeButtonFreeze:SetText("Freeze")
						dudeButtonFreeze:SetSize(43, 20)
						dudeButtonFreeze:SetPos(129, dude:GetTall())
						function dudeButtonFreeze:Paint(w, h)
							surface.SetDrawColor(65, 97, 138, 255)
							surface.DrawRect(w * .05, 0, w * .9, h)
						end
						function dudeButtonFreeze:DoClick()
							if not IsValid(playerInfo) then LocalPlayer():ChatPrint("Something went wrong.") return end

							if not dudeFrozen then
								LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Freeze .. playerInfo:Nick())
								dudeFrozen = true
							else
								LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Unfreeze .. playerInfo:Nick())
								dudeFrozen = false
							end
						end

						local dudeMuted = false

						local dudeButtonMute = vgui.Create("DButton", dude)
						dudeButtonMute:SetFont("popupGeneralFont")
						dudeButtonMute:SetColor(Color(255, 255, 255, 255))
						dudeButtonMute:SetText("Mute")
						dudeButtonMute:SetSize(43, 20)
						dudeButtonMute:SetPos(172, dude:GetTall())
						function dudeButtonMute:Paint(w, h)
							surface.SetDrawColor(65, 97, 138, 255)
							surface.DrawRect(w * .05, 0, w * .9, h)
						end
						function dudeButtonMute:DoClick()
							if not IsValid(playerInfo) then LocalPlayer():ChatPrint("Something went wrong.") return end

							if not dudeMuted then
								LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Mute .. playerInfo:Nick())
								dudeMuted = true
							else
								LocalPlayer():ConCommand(RAAPS.Commands[RAAPS.cfg.addon].Unmute .. playerInfo:Nick())
								dudeMuted = false
							end				
						end

						if playerInfo ~= v.playersIn[1] and not isStaff(playerInfo) then  
							local dudeButtonRemove = vgui.Create('DButton', dude)
							dudeButtonRemove:SetFont("popupGeneralFont")
							dudeButtonRemove:SetColor(Color(255, 255, 255, 255))
							dudeButtonRemove:SetText("")
							dudeButtonRemove:SetSize(43, 20)
							dudeButtonRemove:SetPos(215, dude:GetTall())
							function dudeButtonRemove:Paint(w, h)
								surface.SetDrawColor(65, 97, 138, 255)
								surface.DrawRect(w * .05, 0, w * .9, h)
								surface.SetDrawColor(255, 255, 255, 255)
								surface.SetMaterial(Material("icon16/cross.png"))
								surface.DrawTexturedRect(w / 2 - 8, h / 2 - 8, 16, 16)
							end
							function dudeButtonRemove:DoClick()
								net.Start("updatePlayersInClaim")
									net.WriteEntity(v.playersIn[1])
									net.WriteEntity(playerInfo)
									net.WriteBool(false)
								net.SendToServer()

								table.RemoveByValue(v.playersIn, playerInfo)
								self:GetParent():Remove()
							end
						end

						function dudeName:DoClick()
							if not IsValid(playerInfo) then 
								dude:SetSize(0, 20)
								dudeAvatar:DockMargin(0, 0, 0, 0)
								dudeName:DockMargin(5, 0, 0, 0)
								dudeSteamID:DockMargin(0, 0, 0, 0)
								extendedDude = false
								function dude:Paint(w, h)
									surface.SetDrawColor(102, 102, 102, 255)
									surface.DrawRect(0, 0, w, h)
								end 
								return 
							end
							if not extendedDude then
								dude:SizeTo(v.players:GetWide(), 40, 1, 0, .1, function() end)
								dudeAvatar:DockMargin(0, 0, 0, 20)
								dudeName:DockMargin(5, 0, 0, 20)
								dudeSteamID:DockMargin(0, 0, 0, 20)
								extendedDude = true
							else
								dude:SizeTo(v.players:GetWide(), 20, 1, 0, .1, function() end)
								dudeAvatar:DockMargin(0, 0, 0, 0)
								dudeName:DockMargin(5, 0, 0, 0)
								dudeSteamID:DockMargin(0, 0, 0, 0)
								extendedDude = false
							end
						end
					end
				end
			else
				local dudes = v:GetChild(7):GetChild(0):GetChildren() -- gets the DPanels of all players in the case

				for a, b in pairs(dudes) do 
					if b:GetChild(1):GetText() == playerInfo:Nick() then -- GetChild(1) is a DLabel with the text being the player's name, GetChild(2) would be a label having SteamID
						b:Remove()
					end
				end

				table.RemoveByValue(v.playersIn, playerInfo)
			end

			v.title:SetText(v.playersIn[1]:Nick() .. " + " .. #v.playersIn - 1 .. " more")

			// ONLY UPDATES THE SIZE OF THE FRAME FOR ADMINS WHO ARE IN THE CASE
			for key, val in pairs(v.playersIn) do
				if val == LocalPlayer() and isStaff(val) then
					v:SizeTo(popupFrameW, (popupFrameH + (#v.playersIn * 20)) + 20, 1, 0, .1, function() end)
					v.players:SetSize(popupFrameW * .985, (#v.playersIn * 20))
					v.closeButt:SetPos(popupFrameW - (popupFrameW * .21), (popupFrameH + (((#v.playersIn) * 20))) + 2)
					v.addPlayers:SetPos(popupFrameW - (popupFrameW * .99), (popupFrameH + (((#v.playersIn) * 20))) + 2)
				end
			end
		end
	end
end)

net.Receive("closeCase", function(len, ply)
	local vict = net.ReadEntity()

	net.Start("playerCanMakeReportAgain")
		net.WriteEntity(vict)
	net.SendToServer()

	for k, v in pairs(activeClaims) do
		if v.caller == vict then
			v:Remove()
			table.RemoveByValue(activeClaims, v)
		end
	end
end)

net.Receive("sendPopup", function(len, ply)
	local plyTable = net.ReadTable()
	local plyMesssage = net.ReadString()

	RAAPS.createPopup(plyTable, plyMesssage)
end)

net.Receive("updatePopup", function(len, ply)
	local vict = net.ReadEntity()
	local message = net.ReadString()

	for k, v in pairs(activeClaims) do
		if v.caller == vict then
			v.desc:AppendText("\n" .. message)
		end
	end
end)

net.Receive("openReportMenu", function(len, ply)
	RAAPS.createReport()
end)

net.Receive("playerCanMakeReportAgain", function(len, ply)
	canPlayerMakeReport = true
end)

// REMOVE THIS WHEN FINISHED
concommand.Add("sendPopup1", function()
	local dudes = player.GetAll()
	net.Start("sendPopup")
		net.WriteTable({dudes[3], dudes[4], dudes[5]})
		net.WriteString("Bitch ass long ass string")
	net.SendToServer()
end)

concommand.Add("sendPopup2", function()
	local dudes = player.GetAll()
	net.Start("sendPopup")
		net.WriteTable({dudes[6], dudes[7], dudes[8]})
		net.WriteString("And another one for ya mama")
	net.SendToServer()
end)
concommand.Add("sendPopup3", function()
	local dudes = player.GetAll()
	net.Start("sendPopup")
		net.WriteTable({dudes[11], dudes[10], dudes[9]})
		net.WriteString("And another one for ya mama")
	net.SendToServer()
end)

-- 1. confirmation for removing person from case
-- 2. in case all admins are cunts, and they all close the case for a certain player, give him the ability back to create another rep (timer)

-- what if you try to report an admin (dont create pop up, if any of the players that are included are LocalPlayer()) [or dont create another fucking dpanel]
-- when case is claimed, make the victim unable to add on anymore messages
-- when one case is claimed, hide all the other ones for the admin. and when that case is closed reshow all the other ones, IF they havent been closed already