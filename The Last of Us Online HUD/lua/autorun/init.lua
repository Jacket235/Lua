if SERVER then
	AddCSLuaFile("dev_hud/cl_hud.lua")
else
	include("dev_hud/cl_hud.lua")
end