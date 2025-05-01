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

-- There is no need to non stop recreate the circle so it's defined here and if needed, changed
HUDBGCircle = draw.JCircle(1742 * ScrW() / 1920, 896 * ScrW() / 1920, 66 * ScrW() / 1920)

// Initializing variables outside of HUDPaint
local ammoPosX = 1669
local ammoPosY = 920
local plyStartHP, plyOldHP, plyNewHP = 0, -1, -1
local lerpingPlayerHP, lerpingPlayerDamage, lerpingPlayerHeal = 200, 200, 200 -- because 200 is the max and starting angle the ring goes to
local currWepAmmoType = 11 -- 11 means unarmed

local gunInfo = {
    {
        Icon = Material("TLoU2_HUD/AR.png"), 
        Size = 124
    },
    {
        Icon = "skip",
    },
    {
        Icon = Material("TLoU2_HUD/Pistol.png"),
        Size = 52
    },
    {
        Icon = Material("TLoU2_HUD/SMG.png"),
        Size = 109
    },
    {
        Icon = Material("TLoU2_HUD/Revolver.png"),
        Size = 64
    },
    {
        Icon = Material("TLoU2_HUD/Crossbow.png"),
        Size = 0
    },
    {
        Icon = Material("TLoU2_HUD/Shotgun.png"),
        Size = 206
    },
    {
        Icon = Material("TLoU2_HUD/RPG.png"),
        Size = 212
    },
    {
        Icon = Material("skip"),
    },
    {
        Icon = Material("TLoU2_HUD/Grenade.png"),
        Size = 22
    },
    {
        Icon = Material("TLoU2_HUD/Unarmed.png"),
        Size = 29
    }
}

hook.Add("HUDPaint", "TLoUHUD", function()
    -- Used for scaling the HUD (It was made on 1920x1080 so that's why it's divided by 1920)
    local scale = ScrW() / 1920

    ply = LocalPlayer()

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
        surface.DrawRect(1542 * scale, 864 * scale, 144 * scale, 54 * scale)
        render.SetStencilCompareFunction(STENCIL_GREATER)
        surface.DrawPoly(HUDBGCircle)
    render.SetStencilEnable(false)

    -- Empty ring
    surface.SetDrawColor(150, 150, 150, 200)
    draw.JRing(1742 * scale, 896 * scale, 66 * scale, 7 * scale, 2, 200)

    -- Grey lines
    surface.SetDrawColor(150, 150, 150, 100)
    surface.DrawRect(1542 * scale, 864 * scale, 222 * scale, 1)
    surface.DrawRect(1542 * scale, 918 * scale, 132 * scale, 1)

    -- Handles gun icon, bullet count, ammo count
    if currWep:IsValid() then
        if currWep:Clip1() != -1 and currWep:GetPrimaryAmmoType() != nil then
            local magAmmoCount = currWep:Clip1()
            local magMaxAmmoCount = currWep:GetMaxClip1()
            local magReserveCount = ply:GetAmmoCount(currWep:GetPrimaryAmmoType())

            -- Draws the magazine and reserve count
            draw.SimpleText(magAmmoCount, "primaryAmmo", 1730 * scale, 918 * scale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            draw.SimpleText("|", "text", 1734 * scale, 920 * scale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(magReserveCount, "reserveAmmo", 1738 * scale, 919 * scale, Color( 240, 240, 240, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            -- Draws the capacity of the magazine (limited to 32)
            surface.SetDrawColor(140, 140, 140, 255)
            for j = 0, math.min(31, magMaxAmmoCount - 1) do
                local step = (ammoPosX * scale) + j * -4
                surface.DrawRect(step, ammoPosY * scale, 2, 8)
            end

            -- Draws the magazine bullet count
            surface.SetDrawColor(255, 255, 255, 255)
            for i = 0, math.min(31, magAmmoCount - 1) do
                local step = (ammoPosX * scale) + i * -4
                surface.DrawRect(step, ammoPosY * scale, 2, 8)
            end
        else
            -- Draws the ammo for weapons that don't have a reserve (example: Grenade, RPG)
            local grenadeCount = ply:GetAmmoCount(currWep:GetPrimaryAmmoType())
            draw.SimpleText(grenadeCount, "primaryAmmo", 1734 * scale, 920 * scale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    -- Health Loss
    if lerpingPlayerDamage ~= plyHPAng then
        lerpingPlayerDamage = Lerp((CurTime() - plyStartHP - .5) / .2, lerpingPlayerDamage, plyHPAng) // (- .5) is the delay || / .2 is the animation time
        surface.SetDrawColor(138, 28, 26, 255)
        draw.JRing(1742 * scale, 896 * scale, 66 * scale, 7 * scale, math.max(2, lerpingPlayerHP), math.Clamp(lerpingPlayerDamage, 2, 200))
    end
    -- Health gain
    if plyHP > plyOldHP then
        surface.SetDrawColor(38, 65, 102, 255)
        draw.JRing(1742 * scale, 896 * scale, 66 * scale, 7 * scale, lerpingPlayerHP, plyHPAng)
        surface.SetDrawColor(86, 145, 227, 255)
        draw.JRing(1742 * scale, 896 * scale, 66 * scale, 7 * scale, lerpingPlayerHP, lerpingPlayerHeal)
    end
    -- Health bar
    for h = 0, 200, 40 do
        surface.SetDrawColor(255, 255, 255, 255)
        draw.JRing(1742 * scale, 896 * scale, 66 * scale, 7 * scale, h + 2, math.Clamp(HpAng(h, 40), 2, 200))
    end
    -- Armor bar
    if plyArmor > 0 then
        surface.SetDrawColor(150, 150, 150, 200)
        draw.JRing(1742 * scale, 896 * scale, 75 * scale, 2 * scale, 2, 200)
        surface.SetDrawColor(121, 180, 242, 255)
        draw.JRing(1742 * scale, 896 * scale, 75 * scale, 4 * scale, 0, math.Clamp(202 * (plyArmor / plyMaxArmor), 0, 202))
    end
    -- Gun display
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(gunInfo[currWepAmmoType].Icon)
    surface.DrawTexturedRect(1548 * scale, 870 * scale, gunInfo[currWepAmmoType].Size * scale, 40 * scale)
end, HOOK_HIGH)

hook.Add("OnScreenSizeChanged", "TLoUHUDScreenSizeChanged", function()
    HUDBGCircle = draw.JCircle(1742 * ScrW() / 1920, 896 * ScrW() / 1920, 66 * ScrW() / 1920)
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

-- Understanding stencils
//render.OverrideColorWriteEnable(true, false)
//render.OverrideColorWriteEnable(false)
-- Nice colour: 86, 145, 227
    /*
    surface.SetDrawColor(0, 0, 0, 100)
    render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        surface.DrawRect(1285 * scale, 720 * scale, 120 * scale, 45 * scale)
        render.SetStencilReferenceValue(0)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        surface.DrawPoly(HUDBGCircle)
    render.SetStencilEnable(false)
    */