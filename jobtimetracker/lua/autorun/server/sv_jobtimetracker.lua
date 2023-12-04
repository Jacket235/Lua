util.AddNetworkString("infoMostPlayedJobs")
util.AddNetworkString("openJobTimesPanel")

include("autorun/sh_jobtimetracker.lua")

JTC.Load()

hook.Add("PlayerInitialSpawn", "getPlayers", function(ply, trans)
	table.insert(JTC.Players, ply)
	JTC.Players[ply] = {
		jobStartTime = 0,
		jobName = "Citizen"
	}
end)

hook.Add("PlayerDisconnected", "removePlayer", function(ply)
	local job = team.GetName(ply:Team())

	if not JTC.Jobs[job] then
		JTC.Jobs[job] = CurTime() - JTC.Players[ply].jobStartTime
	else
		JTC.Jobs[job] = JTC.Jobs[job] + CurTime() - JTC.Players[ply].jobStartTime
	end
	JTC.Save()

	for k, v in pairs(player.GetAll()) do
		net.Start("infoMostPlayedJobs")
			net.WriteTable(JTC.Jobs)
		net.Send(v)
	end
	
	table.RemoveByValue(JTC.Players, ply)
end)

hook.Add("PlayerChangedTeam", "lala", function(ply, oldT, newT)
	local job = team.GetName(ply:Team())

	if not JTC.Jobs[job] then
		JTC.Jobs[job] = CurTime() - JTC.Players[ply].jobStartTime
	else
		JTC.Jobs[job] = JTC.Jobs[job] + CurTime() - JTC.Players[ply].jobStartTime
	end
	JTC.Save()

	for k, v in pairs(player.GetAll()) do
		net.Start("infoMostPlayedJobs")
			net.WriteTable(JTC.Jobs)
		net.Send(v)
	end

	JTC.Players[ply] = {
		jobStartTime = CurTime(),
		jobName = team.GetName(newT)
	}
end)

hook.Add("PlayerSay", "checkForJobTimesCommand", function(sender, text, teamChat)
	if text == jobTimesCommand then
		net.Start("openJobTimesPanel")
		net.Send(sender)
	end
end)