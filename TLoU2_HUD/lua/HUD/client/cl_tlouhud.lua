local function createFonts()
    surface.CreateFont("primaryAmmo", {
        font = "DIN Next LT Arabic Medium",
        size = 65 * ScrW() / 1920
    })
    surface.CreateFont("text", {
        font = "DIN Next LT Arabic Medium",
        size = 35 * ScrW() / 1920
    })
    surface.CreateFont("reserveAmmo", {
        font = "DIN Next LT Arabic Medium",
        size = 53 * ScrW() / 1920
    })
end
createFonts()

// Maths and shapes (I fucking despise this part)
function draw.JCircle(PositionX, PositionY, Radius)
    local circle = {}
    local i = 0
    for ang = 0, 360 do
        i = i + 1
        circle[i] = {
            x = PositionX + math.cos(math.rad(ang)) * Radius,
            y = PositionY + math.sin(math.rad(ang)) * Radius
        }
    end
    return circle
end

function draw.JPie(PositionX, PositionY, Radius, StartAng, EndAng)

    StartAng = StartAng - 115
    EndAng = EndAng - 115
    local pie = {
        {x = PositionX, y = PositionY}
    }
    local i = 1
    for ang = StartAng, EndAng do
        i = i + 1
        pie[i] = {
            x = PositionX + math.cos(-math.rad(ang)) * Radius,
            y = PositionY + math.sin(-math.rad(ang)) * Radius
        }
    end
    return pie
end

function draw.JRing(PositionX, PositionY, Radius, Thickness, StartAng, EndAng)

    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )
    render.SetStencilReferenceValue( 0 )
    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilPassOperation( STENCIL_KEEP )
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.ClearStencil()

    render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilFailOperation(STENCIL_EQUAL)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        surface.DrawPoly(draw.JCircle(PositionX, PositionY, Radius - Thickness))
        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        surface.DrawPoly(draw.JPie(PositionX, PositionY, Radius, StartAng, EndAng))
    render.SetStencilEnable(false)
end

// Initializing variables outside of HUDPaint
local plyStartHP, plyOldHP, plyNewHP = 0, -1, -1
local lerpingPlayerHP, lerpingPlayerDamage, lerpingPlayerHeal = 200, 200, 200 -- because 200 is the max and starting angle the ring goes to
local currWepAmmoType = 11 -- 11 means unarmed

local gunInfo = {
    [1] = Material("TLoU2_HUD/AR.png"),
    [3] = Material("TLoU2_HUD/Pistol.png"),
    [4] = Material("TLoU2_HUD/SMG.png"),
    [5] = Material("TLoU2_HUD/Revolver.png"),
    [6] = Material("TLoU2_HUD/Crossbow.png"),
    [7] = Material("TLoU2_HUD/Shotgun.png"),
    [8] = Material("TLoU2_HUD/RPG.png"),
    [10] = Material("TLoU2_HUD/Grenade.png"),
    [11] = Material("TLoU2_HUD/Unarmed.png")
}

hook.Add("HUDPaint", "TLoUHUD", function()
    -- Used for scaling the HUD (It was made on 1920x1080 so that's why it's divided by 1920)
    local scale = ScrW() / 1920

    local ply = LocalPlayer()

    -- Variables
    local plyHP = ply:Health()
    local plyHPAng = plyHP * 2
    local plyMaxHP = ply:GetMaxHealth()
    local plyArmor = ply:Armor()
    local plyMaxArmor = ply:GetMaxArmor()
    local currWep = ply:GetActiveWeapon()
    if not IsValid(currWep) or currWep:GetPrimaryAmmoType() == -1 or currWep:GetPrimaryAmmoType() >= 11 then
        currWepAmmoType = 11
    else
        currWepAmmoType = currWep:GetPrimaryAmmoType()
    end

    -- Player initial spawn
    if plyOldHP == -1 and plyNewHP == -1 then
        plyOldHP = plyHP
        plyNewHP = plyHP
    end

    -- When the players health changes (this is used for smoothing)
    if plyNewHP ~= plyHP then
        plyOldHP = plyNewHP
        plyStartHP = CurTime()
        plyNewHP = plyHP
    end

    -- This is for smooth health gain and loss
    lerpingPlayerHeal = Lerp(math.ease.OutCubic(CurTime() - plyStartHP) / .8, lerpingPlayerHeal, plyHPAng)
    
    if CurTime() > (plyStartHP + .8) and plyHP > plyOldHP and lerpingPlayerHeal == plyHPAng then
        lerpingPlayerHP = Lerp(math.ease.OutCubic(CurTime() - plyStartHP) / .2, lerpingPlayerHP, plyHPAng)
    elseif plyHP < plyOldHP then
        lerpingPlayerHP = Lerp(math.ease.OutCubic(CurTime() - plyStartHP) / .2, lerpingPlayerHP, plyHPAng)
    end
    
    -- Function for calculating the health ring segments
    function HpAng(h, maxAng)
        local curSeg = (h / maxAng) + 1
        local segAng =  (plyMaxHP / 5)
        local segMax = segAng * curSeg
        if segMax <= plyHP then
            return h + maxAng
        end
        return lerpingPlayerHP
    end

    // Size, and positions
    -- Background box
    local bgBoxW, bgBoxH = 146 * scale, 70 * scale
    local bgBoxX, bgBoxY = ScrW() / 2 + (582 * scale), ScrH() / 2 + (324 * scale)

    -- Health ring
    local ringX, ringY = ScrW() / 2 + (782 * scale), ScrH() / 2 + (356 * scale)
    local ringRad = 66 * scale
    local ringThick = 7 * scale

    -- Armour ring
    local armourRingRad = 66 * scale
    local armourRingThick = 7 * scale

    -- Ammo
    local ammoX, ammoY = ScrW() / 2 + (770 * scale), ScrH() / 2 + (380 * scale)
    local bulletX, bulletY = bgBoxX + bgBoxW - (17 * scale), bgBoxY + bgBoxH + 2

    -- Grey lines
    local topLineX, topLineY = bgBoxX, bgBoxY
    local bottomLineX, bottomLineY = bgBoxX, bgBoxY + bgBoxH

    -- Weapon icon
    local gunIcon = gunInfo[currWepAmmoType]
    local iconW, iconH = gunIcon:GetInt("$realwidth") * scale, gunIcon:GetInt("$realheight") * scale
    local iconX, iconY = bgBoxX + 5, bgBoxY + (bgBoxH / 2) - (iconH / 2)

    -- HUD Background
    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )
    render.SetStencilReferenceValue( 0 )
    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilPassOperation( STENCIL_KEEP )
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.ClearStencil()

    surface.SetDrawColor(0, 0, 0, 100)
    render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        surface.DrawRect(bgBoxX, bgBoxY, bgBoxW, bgBoxH)
        render.SetStencilCompareFunction(STENCIL_GREATER)
        surface.DrawPoly(draw.JCircle(ringX, ringY, ringRad))
    render.SetStencilEnable(false)

    -- Empty ring
    surface.SetDrawColor(150, 150, 150, 200)
    draw.JRing(ringX, ringY, ringRad, ringThick, 2, 200)

    -- Grey lines
    surface.SetDrawColor(150, 150, 150, 100)
    surface.DrawRect(topLineX, topLineY, 222 * scale, 1)
    surface.DrawRect(bottomLineX, bottomLineY, bgBoxW, 1)

    -- Handles gun icon, bullet count, ammo count
    if currWep:IsValid() then
        if currWep:Clip1() != -1 and currWep:GetPrimaryAmmoType() != nil then
            local magAmmoCount = currWep:Clip1()
            local magMaxAmmoCount = currWep:GetMaxClip1()
            local magReserveCount = ply:GetAmmoCount(currWep:GetPrimaryAmmoType())

            -- Draws the magazine and reserve count
            draw.SimpleText(magAmmoCount, "primaryAmmo", ammoX, ammoY - 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            draw.SimpleText("|", "text", ammoX + 4, ammoY, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(magReserveCount, "reserveAmmo", ammoX + 8, ammoY - 1, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            -- Draws the capacity of the magazine (limited to 32)
            local drawBulletLimit = 31 * scale
            surface.SetDrawColor(140, 140, 140, 255)
            for j = 0, math.min(drawBulletLimit, magMaxAmmoCount - 1) do
                local step = (bulletX) + j * -4
                surface.DrawRect(step, bulletY, 2, 8)
            end

            -- Draws the magazine bullet count
            surface.SetDrawColor(255, 255, 255, 255)
            for i = 0, math.min(drawBulletLimit, magAmmoCount - 1) do
                local step = (bulletX) + i * -4
                surface.DrawRect(step, bulletY, 2, 8)
            end
        else
            -- Draws the ammo for weapons that don't have a reserve (example: Grenade, RPG)
            local grenadeCount = ply:GetAmmoCount(currWep:GetPrimaryAmmoType())
            draw.SimpleText(grenadeCount, "primaryAmmo", ammoX + 4, ammoY, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- Health Loss
    if lerpingPlayerDamage ~= plyHPAng then
        lerpingPlayerDamage = Lerp((CurTime() - plyStartHP - .5) / .2, lerpingPlayerDamage, plyHPAng) // (- .5) is the delay || / .2 is the animation time
        surface.SetDrawColor(138, 28, 26, 255)
        draw.JRing(ringX, ringY, ringRad, ringThick, math.max(2, lerpingPlayerHP), math.Clamp(lerpingPlayerDamage, 2, 200))
    end

    -- Health gain
    if plyHP > plyOldHP then
        surface.SetDrawColor(38, 65, 102, 255)
        draw.JRing(ringX, ringY, ringRad, ringThick, lerpingPlayerHP, plyHPAng)
        surface.SetDrawColor(86, 145, 227, 255)
        draw.JRing(ringX, ringY, ringRad, ringThick, lerpingPlayerHP, lerpingPlayerHeal)
    end

    -- Health bar
    for h = 0, 200, 40 do
        surface.SetDrawColor(255, 255, 255, 255)
        draw.JRing(ringX, ringY, ringRad, ringThick, h + 2, math.Clamp(HpAng(h, 40), 2, 200))
    end

    -- Armor bar
    if plyArmor > 0 then
        surface.SetDrawColor(150, 150, 150, 200)
        draw.JRing(ringX, ringY, 75 * scale, 3 * scale, 2, 200)
        surface.SetDrawColor(121, 180, 242, 255)
        draw.JRing(ringX, ringY, 75 * scale, 4 * scale, 0, math.Clamp(202 * (plyArmor / plyMaxArmor), 0, 202))
    end

    -- Gun display
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(gunIcon)
    surface.DrawTexturedRect(iconX, iconY, iconW, iconH)
end)

hook.Add("OnScreenSizeChanged", "TLoUHUDScreenSizeChanged", function()
    createFonts()
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