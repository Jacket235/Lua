include("autorun/sh_raaps.lua")

util.AddNetworkString("createReportMenu")
util.AddNetworkString("claimCase")
util.AddNetworkString("closeCase")
util.AddNetworkString("sendPopup")
util.AddNetworkString("updatePopup")
util.AddNetworkString("playerCanMakeReportAgain")

function sendPopupToAdmins(victim, offender, desc)
	for k, v in pairs(player.GetAll()) do
		if hasAccess(v) then
			net.Start("sendPopup")
				net.WriteEntity(victim)
				net.WriteEntity(offender)
				net.WriteString(desc)
			net.Send(v)
		end
	end
end

net.Receive("sendPopup", function()
	local victim = net.ReadEntity()
	local offender = net.ReadEntity()
	local desc = net.ReadString()

	sendPopupToAdmins(victim, offender, desc)
end)

net.Receive("claimCase", function()
	local adminClaiming = net.ReadEntity()
	local victimName = net.ReadEntity()

	for k, v in pairs(player.GetAll()) do
		if hasAccess(v) or v == victimName then
			net.Start("claimCase")
				net.WriteEntity(adminClaiming)
				net.WriteEntity(victimName)
			net.Send(v)
		end
	end
end)

net.Receive("closeCase", function()
	local vict = net.ReadEntity()

	for k, v in pairs(player.GetAll()) do
		if hasAccess(v) then
			net.Start("closeCase")
				net.WriteEntity(vict)
			net.Send(v)
		end
		if v == vict then
			net.Start("playerCanMakeReportAgain")
				net.WriteEntity(vict)
			net.Send(v)
		end
	end
end)

net.Receive("playerCanMakeReportAgain", function()
	local poorLad = net.ReadEntity()

	net.Start("playerCanMakeReportAgain")
	net.Send(poorLad)
end)

hook.Add("PlayerSay", "checkForUpdates", function(sender, txt, team)
	if string.sub(txt, 1, 1) == cfg.reportUpdatePrefix then
		local msg = string.sub(txt, 2, string.len(txt))
		for k, v in pairs(player.GetAll()) do
			if hasAccess(v) then
				net.Start("updatePopup")
					net.WriteEntity(sender)
					net.WriteString(msg)
				net.Send(v)
			end
		end
		return false
	end

	if txt == "!report" then
		net.Start("createReportMenu")
		net.Send(sender)
	end
end)

hook.Add("PlayerDisconnected", "checkForUpdates", function(ply)
	for k, v in pairs(player.GetAll()) do
		if hasAccess(v) then
			net.Start("closeCase")
				net.WriteEntity(ply)
			net.Send(v)
		end
	end
end)