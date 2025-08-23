local blur = Material("pp/blurscreen")

function drawBlurAt(x, y, w, h, amount, passes, reverse)
    -- Intensity of the blur.
    amount = amount or 5

    surface.SetMaterial(blur)
    surface.SetDrawColor(color_white)

    local scrW, scrH = ScrW(), ScrH()
    local x2, y2 = x / scrW, y / scrH
    local w2, h2 = (x + w) / scrW, (y + h) / scrH

    for i = -(passes or 0.2), 1, 0.2 do
        if reverse then
            blur:SetFloat("$blur", i*-1 * amount)
        else
            blur:SetFloat("$blur", i * amount)
        end
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
    end
end

function createFont()
	surface.CreateFont("ammo", {
		font = "D-DIN",
		size = 30 * (ScrW() / 1920)
	})
end

createFont()

hook.Add( "OnScreenSizeChanged", "PrintOld", function( oldWidth, oldHeight )
	createFont()
end)

local icons = {
	[1] = {
		Material("tlou_online_hud/variable-rifle.png"),
		Material("tlou_online_hud/ammo-rifle.png")
	},
	[3] = {
		Material("tlou_online_hud/beretta.png"),
		Material("tlou_online_hud/ammo-pistol.png")
	},
	[4] = {
		Material("tlou_online_hud/mpx5.png"),
		Material("tlou_online_hud/ammo-smg.png")
	},
	[5] = {
		Material("tlou_online_hud/revolver.png"),
		Material("tlou_online_hud/ammo-revolver.png")
	},
	[6] = {
		Material("tlou_online_hud/crossbow.png"),
		Material("tlou_online_hud/ammo-arrow.png")
	},
	[7] = {
		Material("tlou_online_hud/shotgun.png"),
		Material("tlou_online_hud/ammo-shotgun.png")
	},
	[8] = {
		Material("tlou_online_hud/ammo-explosive.png"),
		Material("tlou_online_hud/ammo-explosive.png")
	},
	[10] = {
		Material("tlou_online_hud/trap.png"),
		Material("tlou_online_hud/ammo-explosive.png")
	},
	["health"] = Material("tlou_online_hud/small-health.png")
}


local plyStartHp, plyOldHp, plyNewHp, plySmoothHpLoss = 0, -1, -1, 0
local plyHUDAlpha = 1

hook.Add("HUDPaint", "dev_hud", function()
	// Player info
	local ply = LocalPlayer()
	local hp = ply:Health()
	local maxHp = ply:GetMaxHealth()
	local armour = ply:Armor()
	local maxArmour = ply:GetMaxArmor()
	local weapon = ply:GetActiveWeapon()
	local weaponAmmoType, magAmmoCount, magMaxAmmoCount, magReserveCount = -1, -1, -1, 0

	// Static variables, and smoothing
	local scrw, scrh = ScrW(), ScrH()
	local scale = scrw / 1920

	-- Health
	local healthBarW, healthBarH = 84 * scale, 18 * scale
	local segments = 5
	local segmentsGap = 2
	local startingPosHealthX = (scrw / 2) - (healthBarW / 2) - (math.floor(segments / 2) * healthBarW)
	local startingPosHealthY = (scrh / 2 - (healthBarH / 2)) + (420 * scale)
	local maxSegmentsWidth = healthBarW * segments
	local hpBarW = math.Clamp((hp / maxHp) * maxSegmentsWidth, 0, maxSegmentsWidth)
	local delay = .5
	local animTime = .1

	-- Armour
	local ArmourBarW, ArmourBarH = 84 * scale, 5 * scale
	local startingPosArmourX = (scrw / 2) - (ArmourBarW / 2) - (math.floor(segments / 2) * ArmourBarW)
	local startingPosArmourY = (scrh / 2 - (ArmourBarH / 2)) + (396 * scale)

	-- Weapons and Ammo
	local infoBarW, infoBarH = 190 * scale, 72 * scale
	local startingPosInfoX = (scrw / 2) - (infoBarW / 2) + (720 * scale)
	local startingPosInfoY = (scrh / 2 - (infoBarH / 2)) + (410 * scale)

	-- Initialize variables
	if plyOldHp == -1 and plyNewHp == -1 then
		plyOldHp = hp
		plyNewHp = hp
	end

	-- Smoothing
	plySmoothHpLoss = Lerp((CurTime() - plyStartHp - delay) / animTime, plySmoothHpLoss, 0)

	if plyNewHp ~= hp then
		local newDamageWidth = (plyNewHp - hp) * (maxSegmentsWidth / maxHp)
		plySmoothHpLoss = math.Clamp(plySmoothHpLoss + newDamageWidth, 0, maxSegmentsWidth + segmentsGap + 6)

		plyOldHp = plyNewHp
		plyStartHp = CurTime()
		plyNewHp = hp
	end

	if hp <= 0 and plySmoothHpLoss <= .1 then
	    plyHUDAlpha = Lerp(FrameTime() * 3, plyHUDAlpha, 0)
	else
		drawBlurAt(startingPosInfoX - 2, startingPosInfoY - 2, infoBarW, infoBarH, 1, 1, false)
		drawBlurAt(startingPosHealthX - 2, startingPosHealthY - 2, healthBarW * segments + (segments * segmentsGap) + segmentsGap, healthBarH + 4, 1, 1, false)
		plyHUDAlpha = 1
	end

	// Health segments
	function hpSeg(i)
		local segMax = (i + 1) * healthBarW

		if hpBarW < segMax then
			local segMin = i * healthBarW
			return healthBarW * ((hpBarW - segMin) / healthBarW)
		end
		return healthBarW
	end

	// Drawing the HUD
	local gapSegmentsX = 0

	-- Health background box
	surface.SetDrawColor(0, 0, 0, 150 * plyHUDAlpha)
	surface.DrawRect(
		startingPosHealthX - 2,
		startingPosHealthY - 2,
		healthBarW * segments + (segments * segmentsGap) + segmentsGap,
		healthBarH + 4
	)

	-- Armour background box
	if armour > 0 then
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(
			startingPosArmourX - 2,
			startingPosArmourY - 2,
			ArmourBarW * segments + (segments * segmentsGap) + segmentsGap,
			ArmourBarH + 4
		)
	end

	-- Health
	surface.SetDrawColor(255, 255, 255, 255)
	for i = 0, segments - 1 do
		surface.DrawRect(startingPosHealthX + (healthBarW * i) + gapSegmentsX, startingPosHealthY, hpSeg(i), healthBarH)
		if hpSeg(i + 1) <= 0 then break end
		gapSegmentsX = gapSegmentsX + segmentsGap
	end

	local healthIconMat = icons["health"]

	local healthIconMatW = healthIconMat:GetInt("$realwidth") * scale
	local healthIconMatH = healthIconMat:GetInt("$realheight") * scale

	local startingPosHealthIconX = (scrw / 2) - (healthIconMatW / 2) - (math.floor(segments / 2) * healthBarW) - healthIconMatW - (30 * scale)
	local startingPosHealthIconY = (scrh / 2 - (healthIconMatH / 2)) + (420 * scale)

	surface.SetDrawColor(255, 255, 255, 255 * plyHUDAlpha)
	surface.SetMaterial(healthIconMat)
	surface.DrawTexturedRect(startingPosHealthIconX, startingPosHealthIconY, healthIconMatW, healthIconMatH)

	-- Armour
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(startingPosArmourX, startingPosArmourY, math.Clamp(((ArmourBarW * segments) + (segmentsGap * segments) - 2) * (armour / maxArmour), 0, maxSegmentsWidth + (segmentsGap * segments) - 2), ArmourBarH)
	
	-- Health loss
	local fullSegments = math.floor(hpBarW / healthBarW)
	local remainingSegmentWidth = hpSeg(fullSegments)

	surface.SetDrawColor(130, 68, 71, 255)
	surface.DrawRect(startingPosHealthX + gapSegmentsX + (healthBarW * fullSegments) + remainingSegmentWidth, startingPosHealthY, plySmoothHpLoss, healthBarH)

	-- Weapons and ammo
	surface.SetDrawColor(0, 0, 0, 150 * plyHUDAlpha)
	surface.DrawRect(startingPosInfoX, startingPosInfoY, infoBarW, infoBarH)

	surface.SetDrawColor(128, 128, 128, 150 * plyHUDAlpha)
	surface.DrawRect(startingPosInfoX, startingPosInfoY, infoBarW * .6, 2)
	surface.SetDrawColor(128, 128, 128, 150 * plyHUDAlpha)
	surface.DrawRect(startingPosInfoX, startingPosInfoY + infoBarH, infoBarW, 2)

	surface.SetFont("ammo")

	if weapon:IsValid() then
		if weapon:Clip1() != -1 and weapon:GetPrimaryAmmoType() != nil then
			weaponAmmoType = weapon:GetPrimaryAmmoType()
			magAmmoCount = weapon:Clip1()
		    magMaxAmmoCount = weapon:GetMaxClip1()
		    magReserveCount = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())

		    local magAmmoCountCol = Color(255, 255, 255, 255)
		    local magReserveCountCol = Color(180, 180, 180, 255)

		    if magAmmoCount <= 0 then magAmmoCountCol = Color(128, 0, 0, 255) end
		    if magReserveCount <= 0 then magReserveCountCol = Color(128, 0, 0, 255) end

		    draw.SimpleText(magReserveCount, "ammo", startingPosInfoX + infoBarW, startingPosInfoY + infoBarH + 2, magReserveCountCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			draw.SimpleText("|", "ammo", startingPosInfoX + infoBarW - surface.GetTextSize(magReserveCount), startingPosInfoY + infoBarH + 2, Color(180, 180, 180, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			draw.SimpleText(magAmmoCount, "ammo", startingPosInfoX + infoBarW - surface.GetTextSize(magReserveCount) - 8, startingPosInfoY + infoBarH + 2, magAmmoCountCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

			if weaponAmmoType > 10 then return end
		    local weaponIconMat = icons[weaponAmmoType][1]
		    local ammoIconMat = icons[weaponAmmoType][2]

			local weaponIconMatW = weaponIconMat:GetInt("$realwidth") * scale
			local weaponIconMatH = weaponIconMat:GetInt("$realheight") * scale
			local ammoIconMatW = ammoIconMat:GetInt("$realwidth") * scale
			local ammoIconMatH = ammoIconMat:GetInt("$realheight") * scale

			local startingPosWeaponIconX = startingPosInfoX + (10 * scale)
			local startingPosWeaponIconY = startingPosInfoY + (infoBarH / 2) - (weaponIconMatH / 2)
			local startingPosAmmoIconX = startingPosInfoX + infoBarW + 2
			local startingPosAmmoIconY = startingPosInfoY + infoBarH + 2

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(weaponIconMat)
			surface.DrawTexturedRect(startingPosWeaponIconX, startingPosWeaponIconY, weaponIconMatW, weaponIconMatH)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(ammoIconMat)
			surface.DrawTexturedRect(startingPosAmmoIconX, startingPosAmmoIconY, ammoIconMatW, ammoIconMatH)
		else -- For such things like grenades
			weaponAmmoType = weapon:GetPrimaryAmmoType()
			if weaponAmmoType == -1 then return end
			magReserveCount = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())

			draw.SimpleText(magReserveCount, "ammo", startingPosInfoX + infoBarW, startingPosInfoY + infoBarH + 4, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

			if weaponAmmoType > 10 then return end
			local weaponIconMat = icons[weaponAmmoType][1]
			local ammoIconMat = icons[weaponAmmoType][2]

			local weaponIconMatW = weaponIconMat:GetInt("$realwidth") * scale
			local weaponIconMatH = weaponIconMat:GetInt("$realheight") * scale
			local ammoIconMatW = ammoIconMat:GetInt("$realwidth") * scale
			local ammoIconMatH = ammoIconMat:GetInt("$realheight") * scale

			local startingPosWeaponIconX = startingPosInfoX + (10 * scale)
			local startingPosWeaponIconY = startingPosInfoY + (infoBarH / 2) - (weaponIconMatH / 2)
			local startingPosAmmoIconX = startingPosInfoX + infoBarW + 2
			local startingPosAmmoIconY = startingPosInfoY + infoBarH + 2

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(weaponIconMat)
			surface.DrawTexturedRect(startingPosWeaponIconX, startingPosWeaponIconY, weaponIconMatW, weaponIconMatH)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(ammoIconMat)
			surface.DrawTexturedRect(startingPosAmmoIconX, startingPosAmmoIconY, ammoIconMatW, ammoIconMatH)
		end
	end
end)

// Hides default HUD
local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudWeapon"] = true,
}

hook.Add("HUDShouldDraw", "HideTheDefaultHUD", function(name)
    if (hide[name]) then
        return false
    end
end)