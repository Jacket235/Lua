surface.CreateFont("main", {
    name = "Nachlieli CLM",
    size = 25
})
surface.CreateFont("main2", {
    name = "Nachlieli CLM",
    size = 10
})
surface.CreateFont("pickUp", {
    name = "Nachlieli CLM",
    size = 15,
})

CreateClientConVar("easy_hud_always_visible", 1, true, false)
CreateClientConVar("easy_hud_fade_time", 5, true, false)
CreateClientConVar("easy_hud_hide_pickup", 0, true, false)

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

// This is for default weapons, ArcCW and CW weapons (and anything else that just works)
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
    local scaleX = ScrW() / 1600 -- 
    local scaleY = ScrH() / 900 -- It's divided by 1600 and 900 because I was creating it on that resolution.
    local ply = LocalPlayer()

    local plyHP = ply:Health()
    local plyMaxHP = ply:GetMaxHealth()

    local plyArmor = ply:Armor()
    local plyMaxArmor = ply:GetMaxArmor()

    local lerpingPlayerHP = Lerp(math.ease.OutCubic(CurTime() - plyStartHP), plyOldHP, plyNewHP)
    local lerpingPlayerArmor = Lerp(math.ease.OutCubic(CurTime() - plyStartArmor), plyOldArmor, plyNewArmor)
    local fadeTime = GetConVar("easy_hud_fade_time"):GetFloat()
    local isAlwaysVisible = GetConVar("easy_hud_always_visible"):GetFloat()

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

    if ply:GetActiveWeapon():IsValid() then
        if muzzlePos == nil then
            draw.SimpleTextOutlined(ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()), "main", 1440 * scaleX, 810 * scaleY, Color(196, 150, 110, 255), 0, 0, 1, Color(0, 0, 0, 255))
        elseif ply:GetActiveWeapon():Clip1() != -1 and ply:GetActiveWeapon():GetPrimaryAmmoType() != nil then
            local plyWep = ply:GetActiveWeapon()
            local plyAmmo = plyWep:Clip1()
            local plyAmmoReserve = ply:GetAmmoCount(plyWep:GetPrimaryAmmoType())

            local muzzlePosToScreen = muzzlePos:ToScreen()
            draw.SimpleTextOutlined(plyAmmo, "main", muzzlePosToScreen.x - 10, muzzlePosToScreen.y, Color(196, 150, 110, HUDAmmoAlpha), 0, 0, 1, Color(0, 0, 0, HUDAmmoAlpha))
            draw.SimpleTextOutlined("+ " .. plyAmmoReserve, "main", muzzlePosToScreen.x + 20, muzzlePosToScreen.y, Color(106, 92, 52, HUDAmmoAlpha), 0, 0, 1, Color(0, 0, 0, HUDAmmoAlpha))
        end
    end

    if isAlwaysVisible > 0 then
        HUDAlpha = 255
        HUDAmmoAlpha = 255
    else
        if CurTime() - lastActionDamage > fadeTime then
            HUDAlpha = Lerp((CurTime() - lastActionDamage - fadeTime), HUDAlpha, 1)
        end

        if CurTime() - lastActionAmmo > fadeTime then
            HUDAmmoAlpha = Lerp((CurTime() - lastActionAmmo - fadeTime), HUDAmmoAlpha, 1)
        end
    end

    if plyHP - plyMaxHP > 0 then
        draw.SimpleText("+" .. plyHP - plyMaxHP, "main2", 452 * scaleX, 834 * scaleY, Color(255, 255, 255, HUDAlpha), 0, 0)
    end

    draw.RoundedBox(0, 50 * scaleX, 840 * scaleY, 400 * scaleX, 2, Color(0, 0, 0, HUDAlpha))
    draw.RoundedBox(0, 50 * scaleX, 840 * scaleY, (math.Clamp(400 * (lerpingPlayerHP / plyMaxHP), 0, 400)) * scaleX, 2, Color(83, 160, 61, HUDAlpha))

    if plyArmor - plyMaxArmor > 0 then
        draw.SimpleText("+" .. plyArmor - plyMaxArmor, "main2", 452 * scaleX, 845 * scaleY, Color(255, 255, 255, HUDAlpha), 0, 0)
    end

    draw.RoundedBox(0, 50 * scaleX, 850 * scaleY, 400 * scaleX, 2, Color(0, 0, 0, HUDAlpha))
    draw.RoundedBox(0, 50 * scaleX, 850 * scaleY, (math.Clamp(400 * (lerpingPlayerArmor / plyMaxArmor), 0, 400)) * scaleX, 2, Color(67, 166, 198, HUDAlpha))
end)

hook.Add("PlayerBindPress", "checkReload", function(ply, bind, pressed)
    if bind == "+reload" and pressed then
        if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():IsWeapon() then
            HUDAmmoAlpha = 255
            lastActionAmmo = CurTime()
        end
    end
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

pickedUpItems = {}

local function addPickUp(itemName)
    local pickup = {}
    pickup.time = CurTime()
    pickup.name = itemName
    pickup.holdtime = 5

    table.insert(pickedUpItems, pickup)

    return pickup
end

hook.Add("HUDWeaponPickedUp", "addWeaponToTable", function(wep)
    if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end
    if ( !IsValid( wep ) ) then return end
    if ( !isfunction( wep.GetPrintName ) ) then return end
    if GetConVar("easy_hud_hide_pickup"):GetFloat() > 0 then return end

    local pickup = addPickUp(wep:GetPrintName())
    pickup.color = Color(255, 201, 46, 255)
end)

hook.Add("HUDItemPickedUp", "addItemToTable", function(item)
    if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end
    if GetConVar("easy_hud_hide_pickup"):GetFloat() > 0 then return end

    local pickup = addPickUp("#" .. item)
    pickup.color = Color(181, 255, 181, 255)
end)

hook.Add("HUDAmmoPickedUp", "addAmmoToTable", function(item, amt)
    if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end
    if GetConVar("easy_hud_hide_pickup"):GetFloat() > 0 then return end

    local pickup = addPickUp("#" .. item .. "_ammo")
    pickup.amount = tostring(amt)
    pickup.color = Color(181, 201, 255, 255)
end)

local maxNotifications = 12 -- Maximum number of notifications to display at once

hook.Add("HUDDrawPickupHistory", "drawHistory", function()
    if (pickedUpItems == nil) then return end
    if GetConVar("easy_hud_hide_pickup"):GetFloat() > 0 then return end

    local scaleX = ScrW() / 1600 
    local scaleY = ScrH() / 900 -- It's divided by 1600 and 900 because I was creating it on that resolution.

    local totalHeight = 0
    local displayedNotifications = 0 

    for k, v in pairs(pickedUpItems) do
        if (v.time + v.holdtime >= CurTime()) then
            local delta = (v.time + v.holdtime) - CurTime()
            delta = delta / v.holdtime

            local alpha = 255

            if (delta < 0.3) then
                alpha = delta * (255 / 0.3)
            end

            surface.SetFont("pickUp") -- this is here so that surface.GetTextSize() works properly

            -- funny box
            surface.SetDrawColor(v.color.r, v.color.g, v.color.b, alpha)
            surface.DrawRect(20 * scaleX, (totalHeight + 210) * scaleY, 2, 15)
            -- name of thing
            draw.SimpleTextOutlined(v.name, "pickUp", 25 * scaleX, (totalHeight + 210) * scaleY, Color(255, 255, 255, alpha), 0, 0, 0.5, Color(0, 0, 0, 255))

            if v.amount then
                draw.SimpleTextOutlined("x" .. v.amount, "pickUp", (30 + surface.GetTextSize(v.name)) * scaleX, (totalHeight + 210) * scaleY, Color(255, 255, 255, alpha), 0, 0, 0.5, Color(0, 0, 0, 255))
            end 

            totalHeight = totalHeight + 25
            displayedNotifications = displayedNotifications + 1

            if alpha == 0 then
                pickedUpItems[k] = nil
            end

            if displayedNotifications >= maxNotifications then
                break
            end
        end
    end

    return false
end)