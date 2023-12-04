include("shared.lua")
include("autorun/sh_jobtimetracker.lua")

surface.CreateFont("Title", {
	name = "Roboto",
	size = 50
})
surface.CreateFont("jobTitle", {
	name = "Roboto",
	size = 45
})
surface.CreateFont("frameTitle",{
	name = Roboto,
	size = 30,
	weight = 600
})
surface.CreateFont("mainFont",{
	name = Roboto,
	size = 23
})

ENT.RenderGroup = RENDERGROUP_BOTH

local leaderboard = {}

net.Receive("infoMostPlayedJobs", function(len, ply)
	leaderboard = net.ReadTable()
end)

function ENT:Draw()

	self:DrawModel()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(255, 255, 255, 1))

--====================================================--
	local barW, barH = 805, 95

	local pos = self:GetPos()
	pos = pos + Vector(0, -15, 35)

	local ang = self:EyeAngles()
	ang = Angle(0, ang.y - 90, 90)

	cam.Start3D2D(pos, ang, 0.1)
		draw.RoundedBox(0, -200 / 2, -50 / 2, 805, 1000, Color(66, 66, 66, 255))
		draw.RoundedBox(0, -200 / 2, -50 / 2, 805, 50, Color(42, 42, 42, 255))
		draw.SimpleText("Most played jobs", "Title", 125, -28, Color( 255, 255, 255, 255 ), 0, 0)

		local i = 0
		local col
		for k, v in SortedPairsByValue(leaderboard, true) do
			if i > 9 then return end
			if k == "Unassigned" or k == "Joining/Connecting" then continue end

			for key, val in pairs(team.GetAllTeams()) do
				if k == val.Name then
					col = val.Color
				end
			end
			draw.RoundedBox(10, -200 / 2, (barH * i) + 25, barW, barH, col)

			draw.SimpleText(k, "jobTitle", -barW * .12, (barH * i) + 50, Color( 255, 255, 255, 255 ), 0, 0)

			draw.SimpleText(string.format("%dm %dd %dh %dm %ds",
		        v / (30 * 24 * 60 * 60), -- Months
		        (v / (24 * 60 * 60)) % 30, -- Days
		        (v / (60 * 60)) % 24, -- Hours
		        (v / 60) % 60, -- Minutes
		        v % 60 -- Seconds
	    	), "jobTitle", barW * .38, (barH * i) + 50, Color( 255, 255, 255, 255 ), 0, 0)
			i = i + 1
		end
	cam.End3D2D()
end

local frameW, frameH = 500, 600
local desc = true

function JTC.Open()

	if IsValid(frame) then
    	frame:Remove()
    end

	frame = vgui.Create("DFrame")
	frame:SetSize(frameW, frameH - 10)
	frame:Center()
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame:SetTitle("")
	frame:SetVisible(true)
	function frame:Paint(w , h)
		draw.RoundedBox(5, 0, 0, w, h, Color(32, 32, 36, 200))
	end

	local sortDescButt = vgui.Create("DButton", frame)
	sortDescButt:SetText("Most Played Jobs")
	sortDescButt:SetFont("frameTitle")
	sortDescButt:SetColor(Color(255,255,255,255))
	sortDescButt:SetContentAlignment(5)
	sortDescButt:SetSize((frameW / 2) - 10, 35)
	function sortDescButt:Paint(w ,h) 
		local colorButt
		if sortDescButt:IsHovered() then
			colorButt = Color(52, 52, 52, 255)
		else
			colorButt = Color(42, 42, 42, 255)
		end
		draw.RoundedBox(0, 0, 0, w, h, colorButt)
	end
	function sortDescButt:DoClick()
		desc = true
		frame:Remove()
		JTC.Open()
	end

	local sortAscButt = vgui.Create("DButton", frame)
	sortAscButt:SetText("Least Played Jobs")
	sortAscButt:SetFont("frameTitle")
	sortAscButt:SetColor(Color(255,255,255,255))
	sortAscButt:SetContentAlignment(5)
	sortAscButt:SetPos((frameW / 2) - 10, 0)
	sortAscButt:SetSize((frameW / 2) + 10, 35)
	function sortAscButt:Paint(w ,h) 
		local colorButt
		if sortAscButt:IsHovered() then
			colorButt = Color(52, 52, 52, 255)
		else
			colorButt = Color(42, 42, 42, 255)
		end
		draw.RoundedBox(0, 0, 0, w, h, colorButt)
	end
	function sortAscButt:DoClick()
		desc = false
		frame:Remove()
		JTC.Open()
	end

	local closeButt = vgui.Create("DButton", frame)
	closeButt:SetText("x")
	closeButt:SetColor(Color(255,255,255,255))
	closeButt:SetSize(20, 20)
	closeButt:SetPos(frameW * .96, 0)
	function closeButt:Paint() end
	function closeButt:DoClick()
		frame:Close()
	end

	local scrollPanel = vgui.Create("DScrollPanel", frame)
	scrollPanel:DockMargin(0, 5, 0, 0)
	scrollPanel:Dock(TOP)
	scrollPanel:SetSize(frameW, frameH * .92)

	local i = 1
	local noEnd
	local noCol
	for k, v in SortedPairsByValue(leaderboard, desc) do
		if k == "Unassigned" or k == "Joining/Connecting" then continue end

		if i == 1 then
			noEnd = "st"
			noCol = Color(255, 215, 0, 255)
		elseif i == 2 then
			noEnd = "nd"
			noCol = Color(192, 192, 192, 255)
		elseif i == 3 then
			noEnd ="rd"
			noCol = Color(205, 127, 50, 255)
		else
			noEnd = "th"
			noCol = Color(128, 128, 128, 255)
		end

		local jobCol
		for key, value in pairs(team.GetAllTeams()) do
			if k == value.Name then
				jobCol = value.Color
			end
		end

		local jobPanel = vgui.Create("DPanel", scrollPanel)
		jobPanel:SetSize(0, 50)
		jobPanel:DockMargin(5, 5, 5, 0)
		jobPanel:Dock(TOP)
		function jobPanel:Paint(w ,h) 
			draw.RoundedBox(5, 0, 0, w, h, jobCol)
		end

		local jobPlace = vgui.Create("DLabel", jobPanel)
		jobPlace:SetFont("mainFont")
		jobPlace:SetSize(40, 0)
		jobPlace:DockMargin(5, 0, 0, 0)
		jobPlace:SetColor(noCol)
		jobPlace:SetText(i .. noEnd)
		jobPlace:Dock(LEFT)

		local jobName = vgui.Create("DLabel", jobPanel)
		jobName:SetSize(185, 0)
		jobName:SetColor(Color(255,255,255,255))
		jobName:SetText(k)
		jobName:Dock(LEFT)
		jobName:SetFont("mainFont")
		jobName:SetPos(jobPanel:GetWide() * .2, jobPanel:GetTall() * .5)

		local jobTimeSpent = vgui.Create("DLabel", jobPanel)
		jobTimeSpent:SetColor(Color(255,255,255,255))
		jobTimeSpent:SetFont("mainFont")
		jobTimeSpent:SetSize(300, 0)
		jobTimeSpent:SetText(string.format("%dm %dd %dh %dm %ds",
		        v / (30 * 24 * 60 * 60), -- Months
		        (v / (24 * 60 * 60)) % 30, -- Days
		        (v / (60 * 60)) % 24, -- Hours
		        (v / 60) % 60, -- Minutes
		        v % 60 -- Seconds
	    	))
		jobTimeSpent:Dock(FILL)

		i = i + 1
	end
end


net.Receive("openJobTimesPanel", function(len, ply)
	JTC.Open()
end)