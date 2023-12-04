AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
end