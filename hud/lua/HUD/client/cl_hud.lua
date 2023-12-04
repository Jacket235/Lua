surface.CreateFont("main", {
    name = "Nachlieli CLM",
    size = 25
})
surface.CreateFont("main2", {
    name = "Nachlieli CLM",
    size = 10
})

local plyStartHP, plyOldHP, plyNewHP, plyStartArmor, plyOldArmor, plyNewArmor = 0, -1, -1, 0, -1, -1
local HUDAlpha, HUDAmmoAlpha = 1, 1
local lastActionDamage, lastActionAmmo = -1, -1

local muzzlePos
local weaponClass
local attachment

// This is specially made for MW Base
hook.Add("PostDrawEffects", "findViewModelMuzzleForMWBsae", function()
    if LocalPlayer():GetActiveWeapon():IsValid() and string.sub(LocalPlayer():GetActiveWeapon():GetClass(), 0, 2) == "mg" then
        muzzlePos = LocalPlayer():GetActiveWeapon():GetTracerOrigin() + Vector(0, 0, 5)
    end
end)

// This is for default weapons, ArcCW and CW weapons
hook.Add("PostDrawViewModel", "findViewModelMuzzle", function(vm, ply, weapon)
    weaponClass = weapon:GetClass()

    if not IsValid(vm) or not IsValid(ply) or not IsValid(weapon) then return end

    attachment = vm:GetAttachment(1 or vm:LookupAttachment("muzzle"))

    if not attachment then muzzlePos = nil return end

    if string.sub(weaponClass, 0, 2) == "cw" or string.sub(weaponClass, 0, 2) == "wf" or string.sub(weaponClass, 0, 4) == "arc9" then
       muzzlePos = weapon:GetTracerOrigin()
       return
    end

    muzzlePos = attachment.Pos
end)


hook.Add("HUDPaintBackground", "drawHUD", function()
    local ply = LocalPlayer()

    local plyHP = ply:Health()
    local plyMaxHP = ply:GetMaxHealth()

    local plyArmor = ply:Armor()
    local plyMaxArmor = ply:GetMaxArmor()

    local lerpingPlayerHP = Lerp(math.ease.OutCubic(CurTime() - plyStartHP), plyOldHP, plyNewHP)
    local lerpingPlayerArmor = Lerp(math.ease.OutCubic(CurTime() - plyStartArmor), plyOldArmor, plyNewArmor)

    if lastActionDamage == -1 and lastActionAmmo == -1 then
        lastActionDamage = CurTime()
        lastActionAmmo = CurTime()
    end

    if plyOldHP == -1 and plyNewHP == -1 then
        plyOldHP = plyHP
        plyNewHP = plyHP
    end

    if plyOldArmor == -1 and plyNewArmor == -1 then
        plyOldArmor = plyArmor
        plyNewArmor = plyArmor
    end

    if plyNewHP ~= plyHP then
        plyOldHP = plyNewHP
        plyStartHP = CurTime()
        lastActionDamage = CurTime()
        HUDAlpha = 255
        plyNewHP = plyHP
    end

    if plyNewArmor ~= plyArmor then
        plyOldArmor = plyNewArmor
        plyStartArmor = CurTime()
        lastActionDamage = CurTime()
        HUDAlpha = 255
        plyNewArmor = plyArmor
    end

    hook.Add("PlayerBindPress", "checkReload", function(ply, bind, pressed)
        if bind == "+reload" and pressed then
            if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():IsWeapon() then
                HUDAmmoAlpha = 255
                lastActionAmmo = CurTime()
            end
        end
    end)

    if ply:GetActiveWeapon():IsValid() then
        if muzzlePos == nil then
            draw.SimpleTextOutlined(ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()), "main", ScrW() * .9, ScrH() * .9, Color(196, 150, 110, 255), 0, 0, 1, Color(0, 0, 0, 255))
        elseif ply:GetActiveWeapon():Clip1() != -1 and ply:GetActiveWeapon():GetPrimaryAmmoType() != nil then
            local plyWep = ply:GetActiveWeapon()
            local plyAmmo = plyWep:Clip1()
            local plyAmmoReserve = ply:GetAmmoCount(plyWep:GetPrimaryAmmoType())

            local muzzlePosToScreen = muzzlePos:ToScreen()
            draw.SimpleTextOutlined(plyAmmo, "main", muzzlePosToScreen.x - 10, muzzlePosToScreen.y, Color(196, 150, 110, HUDAmmoAlpha), 0, 0, 1, Color(0, 0, 0, HUDAmmoAlpha))
            draw.SimpleTextOutlined("+ " .. plyAmmoReserve, "main", muzzlePosToScreen.x + 20, muzzlePosToScreen.y, Color(106, 92, 52, HUDAmmoAlpha), 0, 0, 1, Color(0, 0, 0, HUDAmmoAlpha))
        end
    end

    if CurTime() - lastActionDamage > 5 then
        HUDAlpha = Lerp((CurTime() - lastActionDamage - 5), HUDAlpha, 1)
    end

    if CurTime() - lastActionAmmo > 5 then
        HUDAmmoAlpha = Lerp((CurTime() - lastActionAmmo - 5), HUDAmmoAlpha, 1)
    end

    if plyHP - plyMaxHP > 0 then
        draw.SimpleText("+" .. plyHP - plyMaxHP, "main2", (ScrW() * .03125) + 402, ScrH() * .927, Color(255, 255, 255, HUDAlpha), 0, 0)
    end

    draw.RoundedBox(0, ScrW() * .03125, ScrH() * .933334, 400, 2, Color(0, 0, 0, HUDAlpha))
    draw.RoundedBox(0, ScrW() * .03125, ScrH() * .933334, math.Clamp(400 * (lerpingPlayerHP / plyMaxHP), 0, 400), 2, Color(83, 160, 61, HUDAlpha))

    if plyArmor - plyMaxArmor > 0 then
        draw.SimpleText("+" .. plyArmor - plyMaxArmor, "main2", (ScrW() * .03125) + 402, ScrH() * .939, Color(255, 255, 255, HUDAlpha), 0, 0)
    end

    draw.RoundedBox(0, ScrW() * .03125, ScrH() * .94445, 400, 2, Color(0, 0, 0, HUDAlpha))
    draw.RoundedBox(0, ScrW() * .03125, ScrH() * .94445, math.Clamp(400 * (lerpingPlayerArmor / plyMaxArmor), 0, 400), 2, Color(67, 166, 198, HUDAlpha))
end)

// Hides default HUD
hook.Add( "HUDShouldDraw", "HideHUD", function( name )
    local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudWeapon"] = true,
    }
    if ( hide[ name ] ) then
        return false
    end
end)