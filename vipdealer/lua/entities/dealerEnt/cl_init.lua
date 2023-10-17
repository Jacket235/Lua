include("shared.lua")

surface.CreateFont("NPCOverHeadFont", {
	name = "Roboto",
	size = 40
})
surface.CreateFont("defaultFont", {
	name = "Roboto",
	size = 23
})
surface.CreateFont("buyButtFont", {
	name = "Roboto",
	size = 28,
	weight = 600
})

local priceVIP = 10000000
local priceVIPPlus = 20000000

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	pos = pos + Vector(0, 0, 77)

	local ang = LocalPlayer():EyeAngles()
	ang = Angle(0, ang.y - 90, 90)

	cam.Start3D2D(pos, ang, 0.1)
		draw.RoundedBox(0, -200 / 2, -50 / 2, 200, 50, Color(255, 220, 83, 255))
				draw.RoundedBox(0, -195 / 2, -45 / 2, 195, 45, Color(36, 41, 48, 255))
		draw.SimpleText( "VIP Dealer", "NPCOverHeadFont", -160 / 2, -40 / 2, color_white )
	cam.End3D2D()
end

function RankNPC.Open()

	local frameW, frameH = ScrW() * .3, ScrH() * .2

	local frame = vgui.Create("DFrame")
	frame:SetSize(frameW, frameH)
	frame:Center(true)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	frame:MakePopup(true)
	function frame:Paint(w,  h)
		draw.RoundedBox(3, 0, 0, w, h, Color(33, 33, 44, 255))
	end

	local frameTitle = vgui.Create("DLabel", frame)
	frameTitle:SetContentAlignment(5)
	frameTitle:SetSize(frameW, frameH * .12)
	frameTitle:SetFont("defaultFont")
	frameTitle:SetPos(0, 0)
	frameTitle:SetText("BUY VIP")
	function frameTitle:Paint(w, h)
		draw.RoundedBox(3, 0, 0, w, h, Color(31, 31, 41, 255))
	end

	local frameCloseButt = vgui.Create("DButton", frame)
	frameCloseButt:SetText("x")
	frameCloseButt:SetColor(Color(255,255,255,255))
	frameCloseButt:SetPos(frameW * .98, frameH * .005)
	frameCloseButt:SetSize(10, 10)
	function frameCloseButt:DoClick()
		frame:Close()
	end
	function frameCloseButt:Paint(w, h) end

	local rankVIPLabel = vgui.Create("DLabel", frame)
	rankVIPLabel:SetFont("defaultFont")
	rankVIPLabel:SetText("VIP")
	rankVIPLabel:SetPos(frameW * .1, frameH * .3)
	rankVIPLabel:SetSize(frameW * .2, frameH * .2)

	local rankVIPPlusLabel = vgui.Create("DLabel", frame)
	rankVIPPlusLabel:SetFont("defaultFont")
	rankVIPPlusLabel:SetText("VIP+")
	rankVIPPlusLabel:SetPos(frameW * .1, frameH * .6)
	rankVIPPlusLabel:SetSize(frameW * .2, frameH * .2)

	local buyVIPButt = vgui.Create("DButton", frame)
	buyVIPButt:SetFont("buyButtFont")
	buyVIPButt:SetColor(Color(255,255,255,255))
	buyVIPButt:SetText("$10 million")
	buyVIPButt:SetPos(frameW * .3, frameH * .3)
	buyVIPButt:SetSize(frameW * .6, frameH * .2)
	function buyVIPButt:Paint(w, h)
		if buyVIPButt:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, Color(74, 74, 97, 255))
		else
			draw.RoundedBox(5, 0, 0, w, h, Color(54, 54, 71, 255))
		end
	end
	function buyVIPButt:DoClick()
		local playerMoney = LocalPlayer():getDarkRPVar("money")

		for k, v in pairs(RankNPC.Staff) do
			if LocalPlayer():IsUserGroup(v) then return end
		end

		if LocalPlayer():GetUserGroup() == "vip+" or LocalPlayer():GetUserGroup() == "vip" or LocalPlayer():IsAdmin() then
			LocalPlayer():ChatPrint("You already bought this.")
			return
		end

		if playerMoney > priceVIP then
			net.Start("openBuyRankUI")
				net.WriteString("vip")
				net.WriteInt(priceVIP, 32)
			net.SendToServer()
		else
			LocalPlayer():ChatPrint("You don't have enough money to buy this.")
		end
	end

	local buyVIPPlusButt = vgui.Create("DButton", frame)
	buyVIPPlusButt:SetFont("buyButtFont")
	buyVIPPlusButt:SetColor(Color(255,255,255,255))
	buyVIPPlusButt:SetText("$20 million")
	buyVIPPlusButt:SetPos(frameW * .3, frameH * .6)
	buyVIPPlusButt:SetSize(frameW * .6, frameH * .2)
	function buyVIPPlusButt:Paint(w, h)
		if buyVIPPlusButt:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, Color(74, 74, 97, 255))
		else
			draw.RoundedBox(5, 0, 0, w, h, Color(54, 54, 71, 255))
		end
	end
	function buyVIPPlusButt:DoClick()
		local playerMoney = LocalPlayer():getDarkRPVar("money")

		for k, v in pairs(RankNPC.Staff) do
			if LocalPlayer():IsUserGroup(v) then return end
		end

		if LocalPlayer():GetUserGroup() == "vip+" then
			LocalPlayer():ChatPrint("You already bought this.")
			return
		end

		if playerMoney > priceVIPPlus then
			net.Start("openBuyRankUI")
				net.WriteString("vip+")
				net.WriteInt(priceVIPPlus, 32)
			net.SendToServer()
		else
			LocalPlayer():ChatPrint("You don't have enough money to buy this.")
		end
	end
end

net.Receive("openBuyRankUI", function()
	RankNPC.Open()
end)