if SERVER then
	AddCSLuaFile("dev_hud/cl_hud.lua")
	resource.AddFile("materials/tlou_online_hud/missing.png")

	-- Weapons
	resource.AddFile("materials/tlou_online_hud/beretta.png")
	resource.AddFile("materials/tlou_online_hud/crossbow.png")
	resource.AddFile("materials/tlou_online_hud/crowbar.png")
	resource.AddFile("materials/tlou_online_hud/mpx5.png")
	resource.AddFile("materials/tlou_online_hud/trap.png")
	resource.AddFile("materials/tlou_online_hud/revolver.png")
	resource.AddFile("materials/tlou_online_hud/shotgun.png")
	resource.AddFile("materials/tlou_online_hud/small-health.png")
	resource.AddFile("materials/tlou_online_hud/variable-rifle.png")
	resource.AddFile("materials/tlou_online_hud/rpg.png")

	-- Ammo types
	resource.AddFile("materials/tlou_online_hud/ammo-arrow.png")
	resource.AddFile("materials/tlou_online_hud/ammo-pistol.png")
	resource.AddFile("materials/tlou_online_hud/ammo-revolver.png")
	resource.AddFile("materials/tlou_online_hud/ammo-rifle.png")
	resource.AddFile("materials/tlou_online_hud/ammo-shotgun.png")
	resource.AddFile("materials/tlou_online_hud/ammo-smg.png")
	resource.AddFile("materials/tlou_online_hud/ammo-explosive.png")

	-- Fonts
	resource.AddSingleFile("resource/fonts/D-DIN.ttf")
	resource.AddSingleFile("resource/fonts/D-DIN-Bold.ttf")
	resource.AddSingleFile("resource/fonts/D-DINCondensed.ttf")
	resource.AddSingleFile("resource/fonts/D-DINCondensed-Bold.ttf")
	resource.AddSingleFile("resource/fonts/D-DINExp.ttf")
	resource.AddSingleFile("resource/fonts/D-DINExp-Bold.ttf")
	resource.AddSingleFile("resource/fonts/D-DINExp-Italic.ttf")
	resource.AddSingleFile("resource/fonts/D-DIN-Italic.ttf")
else
	include("dev_hud/cl_hud.lua")
end