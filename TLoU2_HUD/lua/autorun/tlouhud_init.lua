if SERVER then

	-- Download the font and gun icons
	resource.AddFile("resource/fonts/DIN Next LT Arabic Medium.ttf")
	resource.AddFile("materials/TloU2Icons/ar.png")
	resource.AddFile("materials/TloU2Icons/crossbow.png")
	resource.AddFile("materials/TloU2Icons/grenade.png")
	resource.AddFile("materials/TloU2Icons/pistol.png")
	resource.AddFile("materials/TloU2Icons/revolver.png")
	resource.AddFile("materials/TloU2Icons/rpg.png")
	resource.AddFile("materials/TloU2Icons/shotgun.png")
	resource.AddFile("materials/TloU2Icons/submg.png")
	-- Initalize the HUD
	AddCSLuaFile("HUD/client/cl_tlouhud.lua")

else
	include("HUD/client/cl_tlouhud.lua")
end

