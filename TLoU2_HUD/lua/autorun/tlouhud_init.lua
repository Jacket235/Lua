if SERVER then

	-- Download the font and gun icons
	resource.AddWorkshop(2878461615)
	resource.AddFile("resource/fonts/DIN Next LT Arabic Medium.ttf")
	-- Initalize the HUD
	AddCSLuaFile("HUD/client/cl_tlouhud.lua")

else
	include("HUD/client/cl_tlouhud.lua")
end

