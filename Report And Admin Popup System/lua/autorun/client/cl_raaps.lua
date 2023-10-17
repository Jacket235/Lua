include("autorun/sh_raaps.lua")

local popup = {}

surface.CreateFont("popupFont", {
	size = 15,
	weight = 500,
})
surface.CreateFont("textFont", {
	size = 20,
	weight = 600,
})
surface.CreateFont("popupTextFont", {
	font = "Roboto",
	size = 14,
	weight = 600
})
surface.CreateFont("reportFont", {
	font = "Roboto",
	size = 30,
	wieght = 500,
})
surface.CreateFont("textReportFont", {
	font = "Century Gothic",
	size = 30,
	weight = 600,
})
surface.CreateFont("reportDescEmpty", {
	font = "Roboto",
	size = 20,
	weight = 500,
})

local playerActiveReport = false

local popupChatTextCol = Color(29, 115, 41, 255)
local popupChatPreTextCol = Color(38, 181, 88, 255)
local popupChatPlayerTextCol = Color(39, 89, 196, 255)
local popupChatWrongTextCol = Color(232, 51, 69, 255)

function popup.ReportCreate()
	if hasAccess(LocalPlayer()) and not cfg.shouldAdminsReport then
		chat.AddText(popupChatWrongTextCol, "Admins don't have access to this command.")
	return end

	if playerActiveReport then 
		chat.AddText(popupChatPreTextCol, "[Popup]", popupChatWrongTextCol, " An admin will get to your active report as soon as possible.") 
	return end

	local w, h = 400, 500

	if IsValid(frame) then
		frame:Remove()
	end
	local frame = vgui.Create("DFrame")
	frame:SetSize(0, 0)
	frame:Center()
	frame:MakePopup(true)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetVisible(true)
	local isAnimating = true
	frame:SizeTo(w, h, 1, 0, .1, function()
		isAnimating = false
	end)
	function frame:Paint(w,h)
		surface.SetDrawColor(18, 36, 59, 255)
		surface.DrawRect(0,0,w,h)
	end

	local closeButt = vgui.Create("DButton", frame)
	closeButt:SetPos(w - 30, 0)
	closeButt:SetText("X")
	closeButt:SetColor(Color(255,255,255,255))
	closeButt:SetVisible(true)
	function closeButt:DoClick()
		frame:Close()
	end
	function closeButt:Paint(w,h)
		surface.SetDrawColor(122, 20, 47, 255)
		surface.DrawRect(0,0,w,h)
	end

	local whatstheissueLabel = vgui.Create("DLabel", frame)
	whatstheissueLabel:SetPos(20, 170)
	whatstheissueLabel:SetSize(200, 20)
	whatstheissueLabel:SetFont("reportFont")
	whatstheissueLabel:SetColor(Color(160, 160, 160, 255))
	whatstheissueLabel:SetText("What's the issue?")
	whatstheissueLabel:SetVisible(false)

	local reportDescriptionBG = vgui.Create("DPanel", frame)
	reportDescriptionBG:SetPos(20, 200)
	reportDescriptionBG:SetSize(360, 0) -- 360, 230
	reportDescriptionBG:SetVisible(true)
	function reportDescriptionBG:Paint(w, h)
		draw.RoundedBox(5, 0, 0, w, h, Color(65, 97, 138, 255))
	end

	local playerInfoBG = vgui.Create("DPanel", frame)
	playerInfoBG:SetPos(20, 85)
	playerInfoBG:SetSize(360, 0) -- 360, 75
	playerInfoBG:SetVisible(true)
	function playerInfoBG:Paint(w, h)
		surface.SetDrawColor(120,120,120,255)
		surface.DrawRect(0,0,w,h)
	end

	local reportDescEmpty = vgui.Create("DLabel", frame)
	reportDescEmpty:SetText("Please tell us the issue.")
	reportDescEmpty:SetColor(Color(110, 32, 40, 255))
	reportDescEmpty:SetFont("reportDescEmpty")
	reportDescEmpty:SetPos(220,180)
	reportDescEmpty:SetSize(250, 20)
	reportDescEmpty:SetVisible(false)

	local reportDescription = vgui.Create("DTextEntry", reportDescriptionBG)
	reportDescription:SetPos(0, 0)
	reportDescription:SetMultiline(true)
	reportDescription:SetFont("textReportFont")
	reportDescription:SetTextColor(Color(255, 255, 255, 255))
	reportDescription:SetPaintBackground(false)
	reportDescription:SetSize(360, 230) -- 360, 230
	reportDescription:SetDrawLanguageID(false)
	reportDescription:SetVisible(false)

	local createReportLabel = vgui.Create("DLabel", frame)
	createReportLabel:SetPos(125,2)
	createReportLabel:SetSize(280, 35)
	createReportLabel:SetFont("reportFont")
	createReportLabel:SetText("Create report")
	createReportLabel:SetVisible(true)

	local selectPlayerLabel = vgui.Create("DLabel", frame)
	selectPlayerLabel:SetPos(20, 40)
	selectPlayerLabel:SetSize(130, 30)
	selectPlayerLabel:SetFont("textFont")
	selectPlayerLabel:SetText("Choose player")
	selectPlayerLabel:SetVisible(true)

	local selectPlayer = vgui.Create("DComboBox", frame)
	selectPlayer:SetPos(160, 44)
	selectPlayer:SetSortItems(false)
	selectPlayer:SetVisible(true)

	frame.selPly = selectPlayer

	local selectedPlayerName = vgui.Create("DLabel", frame)
	selectedPlayerName:SetPos(105,50)
	selectedPlayerName:SetText("")
	selectedPlayerName:SetFont("textFont")
	selectedPlayerName:SetSize(200, 100)
	function selectedPlayerName:Paint(w,h) end

	local selectedPlayerSteamID = vgui.Create("DLabel", frame)
	selectedPlayerSteamID:SetPos(105,80)
	selectedPlayerSteamID:SetText("")
	selectedPlayerSteamID:SetFont("textFont")
	selectedPlayerSteamID:SetSize(200, 100)
	function selectedPlayerName:Paint(w,h) end

	local sendReportButton = vgui.Create("DButton", frame)
	sendReportButton:SetPos(202,435)
	sendReportButton:SetColor(Color(255,255,255,255))
	sendReportButton:SetFont("reportFont")
	sendReportButton:SetText("Send Report")
	sendReportButton:SetSize(175, 0) -- 175, 50
	sendReportButton:SetVisible(true) -- false
	function sendReportButton:Paint(w, h)
		surface.SetDrawColor(44, 56, 71, 255)
		surface.DrawRect(0, 0, w, h)
	end
	function sendReportButton:DoClick()
		if string.find(reportDescription:GetText(),"^%s*$") then
			reportDescEmpty:SetVisible(true)
		else
			timer.Create("resetThings", 60, 1, function() playerActiveReport = false end)
			net.Start("sendPopup")
				net.WriteEntity(LocalPlayer()) -- this is the player creating the report
				net.WriteEntity(selectPlayer:GetOptionData(selectPlayer:GetSelectedID())) -- the player that's being reported
				net.WriteString(reportDescription:GetText()) -- this is the description of the report
			net.SendToServer()
			chat.AddText(popupChatWrongTextCol, "[Report System]", popupChatTextCol, " Type #(message) to give staff additional information about your report!")
			playerActiveReport = true
			frame:Close()
		end
	end

	local clearReportButton = vgui.Create("DButton", frame)
	clearReportButton:SetPos(23, 435)
	clearReportButton:SetColor(Color(255,255,255,255))
	clearReportButton:SetFont("reportFont")
	clearReportButton:SetText("Clear")
	clearReportButton:SetSize(175, 0) -- 175, 50
	clearReportButton:SetVisible(true) -- false
	function clearReportButton:Paint(w, h)
		surface.SetDrawColor(44, 56, 71, 255)
		surface.DrawRect(0, 0, w, h)
	end
	function clearReportButton:DoClick(w, h)
		reportDescription:SetText("")
	end

	function selectPlayer:Paint(w,h) 
		surface.SetDrawColor(26, 52, 84, 255)
		surface.DrawRect(0,0,w,h)
	end

	local Avatar = vgui.Create( "AvatarImage", frame)
	Avatar:SetSize( 64, 64 )
	Avatar:SetPos( 25, 90 )
	Avatar:SetVisible(false)

	function selectPlayer:OnSelect(index, value, data)

		if data == "None" then
			Avatar:SetPlayer( Entity(0), 64 )
			selectedPlayerName:SetText("N/A")
			selectedPlayerSteamID:SetText("N/A")
		else
			Avatar:SetPlayer( data, 64 )
			selectedPlayerName:SetText(value)
			selectedPlayerSteamID:SetText(data:SteamID())
		end

		playerInfoBG:SizeTo(360, 75, 1, 0, 0.1, function() end)
		reportDescriptionBG:SizeTo(360, 230, 1, 0,0.1, function() end)
		clearReportButton:SizeTo(175, 50, 1, 0, 0.1, function() end)
		sendReportButton:SizeTo(175, 50, 1, 0, 0.1, function() end)
		reportDescription:SetVisible(true)
		whatstheissueLabel:SetVisible(true)
		Avatar:SetVisible(true)
	end

	selectPlayer:AddChoice("Not a player offense", "None")
	for k, v in pairs(player.GetAll()) do
		if v != LocalPlayer() then
			selectPlayer:AddChoice(v:Nick(), v)
		end
	end

	function frame:OnSizeChanged(w, h)
		if isAnimating then
			frame:Center()
		end
		closeButt:SetSize(w * .08, h * .05)
		selectPlayer:SetSize(w * .45, h * .05)
	end
end

function popup.Create(vctm, ofndr, msg)

	surface.PlaySound( "ambient/water/drip" .. math.random( 1, 4 ) .. ".wav" )

	for k, v in pairs(activeClaims) do
		if v.victim == vctm then return end
	end
	local w, h = 345, 150 -- 345, 150

	// Main Frame

	local frame = vgui.Create("DFrame")
	frame:SetPos(cfg.xpos, ((h + cfg.gapBetweenClaims) * #activeClaims) + cfg.ypos)
	frame:ShowCloseButton(false)
	frame:SetTitle("")
	frame.victim = vctm
	frame.offender = ofndr
	frame:SetSize(w, h)
	function frame:Paint(w,h) 
		surface.SetDrawColor(44, 44, 54, 250)
		surface.DrawRect(0, 0, w, h * .1)
		surface.SetDrawColor(32, 32, 36, 200)
		surface.DrawRect(0, h * .1, w, h  * .9)
	end

	function frame:OnRemove()
		table.RemoveByValue(activeClaims, frame)
		for k,v in pairs(activeClaims) do
			v:MoveTo(cfg.xpos, cfg.ypos + ((h + cfg.gapBetweenClaims) *(k-1)), 0.1, 0,1, function() end)
		end
	end

	local closeButt = vgui.Create("DButton", frame)
	closeButt:SetColor(Color(255,255,255,255))
	closeButt:SetSize(10, 10)
	closeButt:SetPos(335, 0)
	closeButt:SetText("x")
	function closeButt:Paint() end
	function closeButt:DoClick()
		frame:Close()
	end

	frame.closeButton = closeButt

	local popupDescription = vgui.Create("RichText", frame)
	popupDescription:SetPos(10, 20)
	popupDescription:SetSize(220, 120)
	function popupDescription:PerformLayout()
		self:SetFontInternal("popupTextFont")
	end
	popupDescription:SetVisible(true)
	popupDescription:SetVerticalScrollbarEnabled(false)
	popupDescription:AppendText(msg)

	frame.popupDescription = popupDescription

	local ticketVictim = vgui.Create("DLabel", frame)
	ticketVictim:SetFont("popupFont")
	ticketVictim:SetSize(330, 25)
	ticketVictim:SetColor(Color(255,255,255,255))
	ticketVictim:SetText(vctm:Nick()) 
	ticketVictim:SetPos(4, -5)
	ticketVictim:SetVisible(true)

	frame.ticketVictClaimer = ticketVictim

	-- Victim and offender label

	local ticketVictimText = vgui.Create("DLabel", frame)
	ticketVictimText:SetFont("popupFont")
	ticketVictimText:SetPos(230, 15)
	ticketVictimText:SetText(vctm:Nick()) 
	ticketVictimText:SetSize(50, 15)

	local ticketOffenderText = vgui.Create("DLabel", frame)
	ticketOffenderText:SetFont("popupFont")
	ticketOffenderText:SetPos(290, 15)
	ticketOffenderText:SetSize(50, 15)

	local ticketClaimedAdminText = vgui.Create("DLabel", frame)
	ticketClaimedAdminText:SetPos(188, 152)
	ticketClaimedAdminText:SetFont("popupFont")
	ticketClaimedAdminText:SetText("Admin")
	ticketClaimedAdminText:SetSize(50, 15)
	ticketClaimedAdminText:SetVisible(false) -- false

	-- Buttons

	// Admin
	local adminGod = vgui.Create("DButton", frame)
	adminGod:SetPos(225, 150)
	adminGod:SetColor(Color(255,255,255,255))
	adminGod:SetText("  God")
	adminGod:SetSize(58, 18)
	adminGod:SetVisible(false)
	function adminGod:Paint(w, h)
		if adminGod:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/heart.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end

	local adminCloak = vgui.Create("DButton", frame)
	adminCloak:SetPos(285, 150)
	adminCloak:SetColor(Color(255,255,255,255))
	adminCloak:SetText("   Cloak")
	adminCloak:SetSize(58, 18)
	adminCloak:SetVisible(false)
	function adminCloak:Paint(w, h)
		if adminCloak:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/contrast_low.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end

	// Victim
	local victimGoto = vgui.Create("DButton", frame)
	victimGoto:SetPos(225, 32)
	victimGoto:SetText("   Goto")
	victimGoto:SetColor(Color(255, 255, 255, 255))
	victimGoto:SetSize(58, 18)
	victimGoto:SetVisible(true)
	function victimGoto:Paint(w, h)
		if victimGoto:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/lightning_go.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	function victimGoto:DoClick()
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Goto .. vctm:Nick())
	end


	local victimBring = vgui.Create("DButton", frame)
	victimBring:SetPos(225, 52)
	victimBring:SetText("   Bring")
	victimBring:SetColor(Color(255, 255, 255, 255))
	victimBring:SetSize(58, 18)
	victimBring:SetVisible(true)
	function victimBring:Paint(w, h)
		if victimBring:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/arrow_down.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	function victimBring:DoClick()
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Bring .. vctm:Nick())
	end


	local victimReturn = vgui.Create("DButton", frame)
	victimReturn:SetPos(225, 72)
	victimReturn:SetText("      Return")
	victimReturn:SetColor(Color(255, 255, 255, 255))
	victimReturn:SetSize(58, 18)
	victimReturn:SetVisible(true)
	function victimReturn:Paint(w, h)
		if victimReturn:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/arrow_undo.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	function victimReturn:DoClick()
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Return .. vctm:Nick())
	end

	local victimFreeze = vgui.Create("DButton", frame)
	victimFreeze:SetPos(225, 92)
	victimFreeze:SetText("      Freeze")
	victimFreeze:SetColor(Color(255, 255, 255, 255))
	victimFreeze:SetSize(58, 18)
	victimFreeze:SetVisible(true)
	function victimFreeze:Paint(w, h)
		if victimFreeze:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/stop.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	local vctmFrozen = false
	function victimFreeze:DoClick()
		if vctmFrozen then
			vctmFrozen = false
			LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Unfreeze .. vctm:Nick())
			return 
		end

		vctmFrozen = true
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Freeze .. vctm:Nick())
	end

	local victimMute = vgui.Create("DButton", frame)
	victimMute:SetPos(225, 112)
	victimMute:SetText("   Mute")
	victimMute:SetColor(Color(255, 255, 255, 255))
	victimMute:SetSize(58, 18)
	victimMute:SetVisible(true)
	function victimMute:Paint(w, h)
		if victimMute:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/sound_mute.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	local vctmMuted = false
	function victimMute:DoClick()
		if vctmMuted then
			vctmMuted = false
			LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Ungag .. vctm:Nick())
			return 
		end

		vctmMuted = true
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Gag .. vctm:Nick())
	end

	// Offender

	local offenderGoto = vgui.Create("DButton", frame)
	offenderGoto:SetPos(285, 32)
	offenderGoto:SetText("   Goto")
	offenderGoto:SetColor(Color(255, 255, 255, 255))
	offenderGoto:SetSize(58, 18)
	offenderGoto:SetVisible(true)
	function offenderGoto:Paint(w, h)
		if offenderGoto:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/lightning_go.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	function offenderGoto:DoClick()	
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Goto .. ofndr:Nick())
	end

	local offenderBring = vgui.Create("DButton", frame)
	offenderBring:SetPos(285, 52)
	offenderBring:SetText("   Bring")
	offenderBring:SetColor(Color(255, 255, 255, 255))
	offenderBring:SetSize(58, 18)
	offenderBring:SetVisible(true)
	function offenderBring:Paint(w, h)
		if offenderBring:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/arrow_down.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	function offenderBring:DoClick()
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Bring .. ofndr:Nick())
	end

	local offenderReturn = vgui.Create("DButton", frame)
	offenderReturn:SetPos(285, 72)
	offenderReturn:SetText("      Return")
	offenderReturn:SetColor(Color(255, 255, 255, 255))
	offenderReturn:SetSize(58, 18)
	offenderReturn:SetVisible(true)
	function offenderReturn:Paint(w, h)
		if offenderReturn:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/arrow_undo.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	function offenderReturn:DoClick()
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Return .. ofndr:Nick())
	end

	local offenderFreeze = vgui.Create("DButton", frame)
	offenderFreeze:SetPos(285, 92)
	offenderFreeze:SetText("      Freeze")
	offenderFreeze:SetColor(Color(255, 255, 255, 255))
	offenderFreeze:SetSize(58, 18)
	offenderFreeze:SetVisible(true)
	function offenderFreeze:Paint(w, h)
		if offenderFreeze:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/stop.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	local ofndrFrozen = false
	function offenderFreeze:DoClick()
		if ofndrFrozen then
			ofndrFrozen = false
			LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Unfreeze .. ofndr:Nick())
			return 
		end

		ofndrFrozen = true
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Freeze .. ofndr:Nick())
	end

	local offenderMute = vgui.Create("DButton", frame)
	offenderMute:SetPos(285, 112)
	offenderMute:SetText("   Mute")
	offenderMute:SetColor(Color(255, 255, 255, 255))
	offenderMute:SetSize(58, 18)
	offenderMute:SetVisible(true)
	function offenderMute:Paint(w, h)
		if offenderMute:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(		255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/sound_mute.png"))
		surface.DrawTexturedRect(2, 1, 16, 16)
	end
	local ofndrMuted = false
	function offenderMute:DoClick()
		if ofndrMuted then
			ofndrMuted = false
			LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Ungag .. ofndr:Nick())
			return 
		end

		ofndrMuted = true
		LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Gag .. ofndr:Nick())
	end

	// Claim button

	local claimCase = vgui.Create("DButton", frame)
	claimCase:SetPos(225, 132)
	claimCase:SetText("Claim")
	claimCase:SetFont("popupFont")
	claimCase:SetColor(Color(255, 255, 255, 255))
	claimCase:SetSize(118, 16)
	claimCase:SetVisible(true)
	function claimCase:Paint(w, h)
		if claimCase:IsHovered() then
			surface.SetDrawColor(26, 106, 161, 255)
		else
			surface.SetDrawColor(73,72,75,255)
		end
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(Material("icon16/key.png"))
		surface.DrawTexturedRect(0, 1, 16, 16)
	end
	function claimCase:DoClick()
		if ofndr != Entity(0) then
			frame:SizeTo(345, 150 + 20, 2, 0, 0.1, function() end)
		end
		local adminGodEnabled = false
		local adminCloakEnabled = false
		function adminGod:DoClick()
			if adminGodEnabled then
				adminGodEnabled = false
				LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Ungod .. LocalPlayer():Nick())
				return
			end
			LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].God .. LocalPlayer():Nick())
			adminGodEnabled = true
		end
		function adminCloak:DoClick()
			if adminCloakEnabled then
				adminCloakEnabled = false
				LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Uncloak .. LocalPlayer():Nick())
				return
			end
			LocalPlayer():ConCommand(cfg.modCommands[cfg.adminMod].Cloak .. LocalPlayer():Nick())
			adminCloakEnabled = true
		end

		net.Start("claimCase")
			net.WriteEntity(LocalPlayer())
			net.WriteEntity(vctm)
		net.SendToServer()
		chat.AddText(popupChatPreTextCol, "[Popup] ", popupChatTextCol, "You claimed ", popupChatPlayerTextCol, vctm:Nick(), popupChatTextCol, "'s case.")
	end

	if ofndr == Entity(0) then
		popupDescription:SetSize(270, 120)
		ticketVictimText:SetPos(290, 15)
		victimGoto:SetPos(285, 32)
		victimBring:SetPos(285, 52)
		victimReturn:SetPos(285, 72)
		victimFreeze:SetPos(285, 92)
		victimMute:SetPos(285, 112)
		claimCase:SetSize(58, 16)
		claimCase:SetPos(285, 132)
		claimCase:SetText("    Claim")
		adminGod:SetVisible(false)
		adminCloak:SetVisible(false)
		ticketClaimedAdminText:SetVisible(false)
		function claimCase:Paint(w, h)
			if claimCase:IsHovered() then
				surface.SetDrawColor(26, 106, 161, 255)
			else
				surface.SetDrawColor(73,72,75,255)
			end
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Material("icon16/key.png"))
			surface.DrawTexturedRect(0, 1, 16, 16)
		end

		ticketOffenderText:SetText("")
		offenderGoto:SetVisible(false)
		offenderBring:SetVisible(false)
		offenderReturn:SetVisible(false)
		offenderFreeze:SetVisible(false)
		offenderMute:SetVisible(false)
	else
		adminGod:SetVisible(true)
		adminCloak:SetVisible(true)
		ticketClaimedAdminText:SetVisible(true)
		ticketOffenderText:SetText(ofndr:Nick())
	end

	frame.claimButt = claimCase
	table.insert(activeClaims, frame)
end

net.Receive("claimCase", function()
	local adminClaiming = net.ReadEntity()
	local vict = net.ReadEntity()

	for k, v in pairs(activeClaims) do
		if v.victim == vict then
			function v:Paint(w, h)
				if adminClaiming == LocalPlayer() then
					surface.SetDrawColor(67, 204, 97, 250)
				else
					surface.SetDrawColor(224, 85, 99, 250)
				end
				
				surface.DrawRect(0, 0, w, h * .1)
				surface.SetDrawColor(32, 32, 36, 200)
				surface.DrawRect(0, h * .1, w, h  * .9)
			end
			function v.claimButt:Paint(w, h)
				if adminClaiming == LocalPlayer() then
					surface.SetDrawColor(67, 204, 97, 250)
				else
					surface.SetDrawColor(224, 85, 99, 255)
				end
				
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(Material("icon16/key.png"))
				surface.DrawTexturedRect(0, 1, 16, 16)
			end
			function v.claimButt:DoClick()
				if LocalPlayer() == adminClaiming then
					chat.AddText(popupChatPreTextCol, "[Popup]", popupChatTextCol, " You already claimed this case.")
				else
					chat.AddText(popupChatPreTextCol, "[Popup]", popupChatWrongTextCol, " This case has already been claimed by ", popupChatPlayerTextCol, adminClaiming:Nick())
				end
			end
			v.ticketVictClaimer:SetText(vict:Nick() .. " Claimed by: " .. adminClaiming:Nick()) -- Tell other staff who claimed the case
			function v.closeButton:DoClick()
				if adminClaiming == LocalPlayer() then
					net.Start("closeCase")
						net.WriteEntity(vict)
					net.SendToServer()
					chat.AddText(popupChatPreTextCol, "[Popup]", popupChatTextCol, " You closed ", popupChatPlayerTextCol, vict:Nick(), popupChatTextCol, "'s case.")
				end	
				v:Close()
			end
		end
	end

	if vict == LocalPlayer() then
		chat.AddText(popupChatWrongTextCol, "[Report System]", popupChatTextCol, " An admin is taking care of your report.")
	end
end)

net.Receive("closeCase", function()
	local vict = net.ReadEntity()

	for k, v in pairs(activeClaims) do
		if not IsValid(v.victim) then
			v:Remove()
			
			net.Start("playerCanMakeReportAgain")
				net.WriteEntity(v.victim)
			net.SendToServer()
			return
		end
		if not IsValid(v.offender) and not v.selPly == "None" then
			v:Remove()
			
			net.Start("playerCanMakeReportAgain")
				net.WriteEntity(v.victim)
			net.SendToServer()
			return
		end
		if v.victim == vict then
			v:Remove()

			net.Start("playerCanMakeReportAgain")
				net.WriteEntity(v.victim)
			net.SendToServer()
			return
		end
		if v.offender == vict then
			v:Remove()

			net.Start("playerCanMakeReportAgain")
				net.WriteEntity(v.victim)
			net.SendToServer()
			return
		end
	end
end)

net.Receive("sendPopup", function()
	local victim = net.ReadEntity()
	local offender = net.ReadEntity()
	local desc = net.ReadString()

	popup.Create(victim, offender, desc)
end)

net.Receive("playerCanMakeReportAgain", function()
	chat.AddText(popupChatWrongTextCol, "[Report System]", popupChatTextCol, " Your report is finished.")
	timer.Remove("resetThings")
	playerActiveReport = false
end)

net.Receive("updatePopup", function()
	local victimUpdateName = net.ReadEntity()
	local note = net.ReadString()

	surface.PlaySound("ui/hint.wav")

	for k,v in pairs(activeClaims) do
		if v.victim == victimUpdateName then
			v.popupDescription:AppendText("\n" .. note)
		end
	end
end)

net.Receive("createReportMenu", function()
	popup.ReportCreate()
end)