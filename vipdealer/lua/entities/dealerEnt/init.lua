util.AddNetworkString("openBuyRankUI")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Barney.mdl")
	self:SetUseType(SIMPLE_USE) 
	self:SetSolid(SOLID_BBOX) 
end

function ENT:Use(ply)
	net.Start("openBuyRankUI")
	net.Send(ply)
end

net.Receive("openBuyRankUI", function(len, ply)
	local rank = net.ReadString()
	local price = net.ReadInt(32)

	if rank == "vip" then
		ulx.adduser( Entity(0), ply, "vip" )
		ply:addMoney(-price)
	else
		ulx.adduser( Entity(0), ply, "vip+" )
		ply:addMoney(-price)
	end
end)