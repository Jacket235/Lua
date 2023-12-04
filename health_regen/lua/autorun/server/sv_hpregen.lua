util.AddNetworkString("regenPlayer")

net.Receive("regenPlayer", function(len, ply)
	local readInt = net.ReadInt(32)
	ply:SetHealth(readInt)
end)