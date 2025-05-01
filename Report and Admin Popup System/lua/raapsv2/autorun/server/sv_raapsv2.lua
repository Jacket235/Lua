include("autorun/sh_raapsv2.lua")

util.AddNetworkString("openReportMenu")
util.AddNetworkString("updatePlayersInClaim") -- not done
util.AddNetworkString("claimCase")
util.AddNetworkString("closeCase")
util.AddNetworkString("sendPopup")
util.AddNetworkString("updatePopup")
util.AddNetworkString("currentlyReportedPlayers")
util.AddNetworkString("playerCanMakeReportAgain")

hook.Add("PlayerSay", "openReportMenu", function(sndr, txt, team)
	if txt == RAAPS.cfg.repMenuCmd then
		net.Start("openReportMenu")
		net.Send(sndr)
	end
	if string.sub(txt, 1, 1) == RAAPS.cfg.reportUpdatePrefix then
		for k, v in pairs(player.GetAll()) do
			if isStaff(v) then
				net.Start("updatePopup")
					net.WriteEntity(sndr)
					net.WriteString(string.sub(txt, 2))
				net.Send(v)
			end
		end
		
	end
end)

net.Receive("updatePlayersInClaim", function(len, ply)
	local victim = net.ReadEntity()
	local playerInfo = net.ReadEntity()
	local isAdding = net.ReadBool()

	for k, v in pairs(player.GetAll()) do
		if isStaff(v) then
			net.Start("updatePlayersInClaim")
				net.WriteEntity(victim) -- this is to find the right frame
				net.WriteEntity(playerInfo) -- player removed/added
				net.WriteBool(isAdding) -- is someone being removed or added
			net.Send(v)
		end
	end
end)

net.Receive("claimCase", function(len, ply)
	local vict = net.ReadEntity()

	for k, v in pairs(player.GetAll()) do
		if (isStaff(v) and v ~= ply) or v == vict then
			net.Start("claimCase")
				net.WriteEntity(vict)
				net.WriteEntity(ply)
			net.Send(v)
		end
	end
end)

net.Receive("closeCase", function(len, ply)
	local vict = net.ReadEntity()

	for k, v in pairs(player.GetAll()) do
		if isStaff(v) then
			net.Start("closeCase")
				net.WriteEntity(vict)
			net.Send(v)
		end
	end
end)

net.Receive("sendPopup", function() 
	local plys = net.ReadTable()
	local msg = net.ReadString()

	for k, v in pairs(player.GetAll()) do
		if isStaff(v) then
			net.Start("sendPopup")
				net.WriteTable(plys)
				net.WriteString(msg)
			net.Send(v)
		end
	end
end)

net.Receive("playerCanMakeReportAgain", function(len, ply)
	local victim = net.ReadEntity()

	net.Start("playerCanMakeReportAgain")
	net.Send(victim)
end)