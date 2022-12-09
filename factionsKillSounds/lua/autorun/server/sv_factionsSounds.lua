include("autorun/shared.lua")
util.AddNetworkString("selectedVoice")

net.Receive("selectedVoice", function()
	voiceSelected = net.ReadString()
end)

hook.Add("OnNPCKilled", "NPCKilled", function(_, attacker, __)
	attacker:EmitSound(Sound("factions/kill/" .. voiceSelected .."Kill".. math.random(1, 8) ..".mp3"), 100)
end)
hook.Add("PlayerDeath", "playerKilled", function(_, __, attacker)
	attacker:EmitSound(Sound("factions/kill/" .. voiceSelected .."Kill".. math.random(1, 8) ..".mp3"), 100)
end)

