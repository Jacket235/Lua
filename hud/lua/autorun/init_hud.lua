if SERVER then
	AddCSLuaFile("HUD/client/cl_hud.lua")
else
	include("HUD/client/cl_hud.lua")
end