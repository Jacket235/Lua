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

local plyStartHp, plyOldHp, plyNewHp, plySmoothHpLoss, damageTakenWidth = 0, -1, -1, 0, 0
local plyHUDAlpha = 150

hook.Add("HUDPaint", "dev_hud", function()
	// Player info
	local ply = LocalPlayer()
	local hp = ply:Health()
	local maxHp = ply:GetMaxHealth()
	local armour = ply:Armor()
	local maxArmour = ply:GetMaxArmor()

	// Static variables, and smoothing
	local scrw, scrh = ScrW(), ScrH()
	local scale = scrw / 1600

	-- Health
	local healthBarW, healthBarH = 70 * scale, 15 * scale
	local segments = 5
	local segmentsGap = 2
	local startingPosHealthX = (scrw / 2) - (healthBarW / 2) - (math.floor(segments / 2) * healthBarW)
	local startingPosHealthY = (scrh / 2 - (healthBarH / 2)) + (350 * scale)
	local maxSegmentsWidth = healthBarW * segments
	local hpBarW = (hp / maxHp) * maxSegmentsWidth
	local delay = .5
	local animTime = .1

	-- Armour
	local ArmourBarW, ArmourBarH = 70 * scale, 4 * scale
	local startingPosArmourX = (scrw / 2) - (ArmourBarW / 2) - (math.floor(segments / 2) * ArmourBarW)
	local startingPosArmourY = (scrh / 2 - (ArmourBarH / 2)) + 330
	
	-- Weapons and Ammo
	-- local infoBarW, infoBarH = 250 * scale, 60 * scale
	-- local startingPosInfoX = (scrw / 2) - (infoBarW / 2) + (600 * scale)
	-- local startingPosInfoY = (scrh / 2 - (infoBarH / 2)) + (350 * scale)

	-- Initialize variables
	if plyOldHp == -1 and plyNewHp == -1 then
		plyOldHp = hp
		plyNewHp = hp
	end

	-- Smoothing
	plySmoothHpLoss = Lerp((CurTime() - plyStartHp - delay) / animTime, plySmoothHpLoss, 0)

	if plyNewHp ~= hp then
		local newDamageWidth = (plyNewHp - hp) * (maxSegmentsWidth / maxHp)
		plySmoothHpLoss = plySmoothHpLoss + newDamageWidth

		plyOldHp = plyNewHp
		plyStartHp = CurTime()
		plyNewHp = hp
	end

	if hp <= 0 and plySmoothHpLoss <= .1 then
	    plyHUDAlpha = Lerp(FrameTime() * 3, plyHUDAlpha, 0)
	else
		-- drawBlurAt(startingPosInfoX - 2, startingPosInfoY - 2, infoBarW, infoBarH, 1, 1, false)
		drawBlurAt(startingPosHealthX - 2, startingPosHealthY - 2, healthBarW * segments + (segments * segmentsGap) + segmentsGap, healthBarH + 4, 1, 1, false)
		plyHUDAlpha = 150
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
	surface.SetDrawColor(0, 0, 0, plyHUDAlpha)
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

	-- Armour
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(startingPosArmourX, startingPosArmourY, ((ArmourBarW * segments) + (segmentsGap * segments) - 2) * (armour / maxArmour), ArmourBarH)
	
	-- Health loss
	local fullSegments = math.floor(hpBarW / healthBarW)
	local remainingSegmentWidth = hpSeg(fullSegments)

	surface.SetDrawColor(117, 61, 64, 255)
	surface.DrawRect(startingPosHealthX + gapSegmentsX + (healthBarW * fullSegments) + remainingSegmentWidth, startingPosHealthY, plySmoothHpLoss, healthBarH)

	-- Weapons and ammo
	-- surface.SetDrawColor(0, 0, 0, plyHUDAlpha)
	-- surface.DrawRect(startingPosInfoX, startingPosInfoY, infoBarW, infoBarH)
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