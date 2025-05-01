if SERVER then
	-- Initalize the HUD
	AddCSLuaFile("HUD/client/cl_tlouhud.lua")
	resource.AddFile("materials/TLoU2_HUD/AR.png")
	resource.AddFile("materials/TLoU2_HUD/Grenade.png")
	resource.AddFile("materials/TLoU2_HUD/Pistol.png")
	resource.AddFile("materials/TLoU2_HUD/Revolver.png")
	resource.AddFile("materials/TLoU2_HUD/RPG.png")
	resource.AddFile("materials/TLoU2_HUD/Shotgun.png")
	resource.AddFile("materials/TLoU2_HUD/SMG.png")
	resource.AddFile("materials/TLoU2_HUD/Unarmed.png")
	resource.AddFile("resource/fonts/DINNextLTArabicMedium.ttf")
else
	include("HUD/client/cl_tlouhud.lua")
end

