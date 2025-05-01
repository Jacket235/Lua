include("autorun/shared.lua")
util.AddNetworkString("vlKill")
util.AddNetworkString("vlHurt")

hook.Add("OnNPCKilled", "factionsNPCKilled", function(_, attacker, __)
	if not attacker:IsPlayer() then return end

	net.Start("vlKill")
	net.Send(attacker)
end)

hook.Add("PlayerDeath", "factionsPlayerKilled", function(victim, __, attacker)
	if victim == attacker then return end
	if not attacker:IsPlayer() then return end

	net.Start("vlKill")
	net.Send(attacker)
end)

hook.Add("PlayerHurt", "factionsCheckHurt", function(victim, attacker, hpRem, dmgTaken)
	net.Start("vlHurt")
	net.Send(victim)
end)