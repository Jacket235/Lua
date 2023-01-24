// Fonts

local function LoadFonts()
	surface.CreateFont("Primary", {
		font = "DIN Next LT Arabic Medium",
		size = ScrW() * .026042,
	} )
	surface.CreateFont( "Ammo", {
		font = "DIN Next LT Arabic Medium",
		size = ScrW() * .02344,
		} )	
	surface.CreateFont("Text", {
		font = "DIN Next LT Arabic Medium",
		size = ScrW() * .01042,
	} )
end

LoadFonts()

// Maths and shapes (I fucking despise this part)

function draw.JCircle(PositionX, PositionY, Radius)
    local circle = {}
    local i = 0
    for ang = 0, 360 do
        i = i + 1
        circle[i] = {
            x = PositionX + math.cos(ang) * Radius,
            y = PositionY + math.sin(ang) * Radius
        }
    end
    surface.DrawPoly(circle)
    return circle
end

function draw.JPie(PositionX, PositionY, Radius, StartAng, EndAng)

    // This part is custom
    StartAng = StartAng - 115
    EndAng = EndAng - 115
    // This part is custom
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
    surface.DrawPoly(pie)
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

// Gun icons 
local pistol = Material("materials/TLoU2Icons/pistol.png")
local revolver = Material("materials/TLoU2Icons/revolver.png")
local grenade = Material("materials/TLoU2Icons/grenade.png")
local crossbow = Material("materials/TLoU2Icons/crossbow.png")
local ar2 = Material("materials/TLoU2Icons/ar.png")
local smg = Material("materials/TLoU2Icons/submg.png")
local shotgun = Material("materials/TLoU2Icons/shotgun.png") 
local rpg = Material("materials/TLoU2Icons/rpg.png")

// The actual HUD part

local function weaponsAndAmmo()
	local ply = LocalPlayer()
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(ScrW() * .80209, ScrH() * 0.7046, ScrW() * .107 , ScrH() * .06944)
    surface.SetDrawColor(150, 150, 150, 100)
    surface.DrawRect(ScrW() * .80209, ScrH() * 0.7046, ScrW() * .10678, ScrH() * .00185186)
    
    local currWep = ply:GetActiveWeapon()

    if (currWep:IsValid()) then
        if(currWep:Clip1() != -1 and currWep:GetPrimaryAmmoType() != nil) then
            draw.SimpleText(currWep:Clip1(), "Primary", ScrW() * .8635421, ScrH() * .72963, Color( 255, 255, 255, 255 ), 0, 0)
            draw.SimpleText("|", "Text", ScrW() * .88021, ScrH() * .745371, Color(180, 180, 180, 255), 0, 0)
            draw.SimpleText(ply:GetAmmoCount(currWep:GetPrimaryAmmoType()), "Ammo", ScrW() * .883334, ScrH() * .73241, Color(180, 180, 180, 255), 0, 0)
            local k = 0
            local l = 0
            if currWep:Clip1() <= ScrW() * 0.014584 then
                local maxClip = currWep:GetMaxClip1()

                // Draws grey boxes behind ammo
                if maxClip > ScrW() * 0.014584 then
                    for j = 1, ScrW() * 0.014584 do
                        l = l + 4
                        surface.SetDrawColor(140,140,140,255)
                        surface.DrawRect(ScrW() * .803125 + l, ScrH() * .75926, ScrW() * 0.001042, ScrH() * 0.00741)
                    end
                else
                    for j = 1, maxClip do
                        l = l + 4
                        surface.SetDrawColor(140,140,140,255)
                        surface.DrawRect(ScrW() * .803125 + l, ScrH() * .75926, ScrW() * 0.001042, ScrH() * 0.00741)
                    end
                end

                // Draws current ammo
                for i = 1, currWep:Clip1() do
                    k = k + 4
                    surface.SetDrawColor(255,255,255,255)
                    surface.DrawRect(ScrW() * .803125 + k, ScrH() * .75926, ScrW() * 0.001042, ScrH() * 0.00741) 
                end
            else
                for i = 1, ScrW() * 0.014584 do
                    k = k + 4
                    surface.SetDrawColor(255,255,255,255)
                    surface.DrawRect(ScrW() * .803125 + k, ScrH() * .75926, ScrW() * 0.001042, ScrH() * 0.00741) 
                end
            end

            // Draws gun icons
            if currWep:GetPrimaryAmmoType() == 1 then
                surface.SetMaterial(ar2)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.708333, ScrW() * 0.0625, ScrH() * 0.03889)
            elseif currWep:GetPrimaryAmmoType() == 3 then
                surface.SetMaterial(pistol)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.708333, ScrW() * 0.039063, ScrH() * 0.0426)
            elseif currWep:GetPrimaryAmmoType() == 4 then
                surface.SetMaterial(smg)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.708333, ScrW() * 0.0625, ScrH() * 0.044445)
            elseif currWep:GetPrimaryAmmoType() == 5 then
                surface.SetMaterial(revolver)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.708333, ScrW() * 0.041667, ScrH() * 0.0426)
            elseif currWep:GetPrimaryAmmoType() == 7 then
                surface.SetMaterial(shotgun)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.717592, ScrW() * 0.0625, ScrH() * 0.02778)
            elseif currWep:GetPrimaryAmmoType() == 6 then
                surface.SetMaterial(crossbow)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.708333, ScrW() * 0.0625, ScrH() * 0.046297)
            end 
        else
            if currWep:GetPrimaryAmmoType() == 10 then
                surface.SetMaterial(grenade)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.708333, ScrW() * 0.0349, ScrH() * 0.06204)
                draw.SimpleText(ply:GetAmmoCount(currWep:GetPrimaryAmmoType()), "Ammo", ScrW() * .88542, ScrH() * .73149, Color(255,255,255,255), 0, 0)
             elseif currWep:GetPrimaryAmmoType() == 8 then
                surface.SetMaterial(rpg)
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRect(ScrW() * 0.80729, ScrH() * 0.717592, ScrW() * 0.0651042, ScrH() * 0.027778)
                draw.SimpleText(ply:GetAmmoCount(currWep:GetPrimaryAmmoType()), "Ammo", ScrW() * .88542, ScrH() * .73149, Color(255,255,255,255), 0, 0)
            end
        end
    end
end

local smoothHP = 1
local smoothHP2 = 1
local smoothArmor = 1

local function healthBar()
	local ply = LocalPlayer()
    local hp = ply:Health()
    local maxHp = ply:GetMaxHealth()
    smoothHP = math.Approach(smoothHP,((hp / maxHp) * 100) * 2.25, FrameTime() / 0.005)
    smoothHP2 = math.Approach(smoothHP2,smoothHP, FrameTime() / 0.0175)

    surface.SetDrawColor(100,100,100,255)
    draw.JRing(ScrW() * .89063, ScrH() * .7408, ScrH() * .070291, ScrW() * .0041667, 2, 225)

    for i = 0, 180, 45 do
        function HpAng(i, maxAng)
            local curSeg = (i / maxAng) + 1
            local segAng =  (maxHp / 5)
            local segMax = segAng * curSeg
            if segMax <= hp then
                return i + maxAng
            end
            return smoothHP
        end
        function HpSmoothAng(i, maxAng)
            local curSeg = (i / maxAng) + 1
            local segAng =  (maxHp / 5)
            local segMax = segAng * curSeg
            if segMax <= hp then
                return i + maxAng
            end
            return smoothHP2
        end
        surface.SetDrawColor(149,21,37,255)
        draw.JRing(ScrW() * .89063, ScrH() * .7408, ScrH() * .070291, ScrW() * .0041667, i + 2, math.Clamp(HpSmoothAng(i,45), 0, 225))

        if hp <= 30 then
            surface.SetDrawColor(253,101,93,255) 
            draw.JRing(ScrW() * .89063, ScrH() * .7408, ScrH() * .070291, ScrW() * .0041667, i + 2, math.Clamp(HpAng(i, 45),0,225))
        else
            surface.SetDrawColor(225,225,225,255)
            draw.JRing(ScrW() * .89063, ScrH() * .7408, ScrH() * .070291, ScrW() * .0041667, i + 2, math.Clamp(HpAng(i, 45),0,225))
        end
    end 
end 

local function armorBar()
	local ply = LocalPlayer()
    local armor = ply:Armor()
    local maxArmor = ply:GetMaxArmor()
    smoothArmor = math.Approach(smoothArmor,((armor / maxArmor) * 100) * 2.25, FrameTime() / 0.002)

    surface.SetDrawColor(30,30,30,150)
    if armor > 0 then
        draw.JRing(ScrW() * .89063, ScrH() * .7408, ScrH() * .080555, ScrW() * .0041667, 2, 225)
    end
    
    for k = 0, 180, 45 do
        function ArmorAng(k, maxAng)
            local curSeg = (k / maxAng) + 1
            local segAng =  (maxArmor / 5)
            local segMax = segAng * curSeg
            if segMax <= armor then
                return k + maxAng
            end
            return smoothArmor
        end
        surface.SetDrawColor(0,0,225,255)
        draw.JRing(ScrW() * .89063, ScrH() * .7408, ScrH() * .080555, ScrW() * .0041667, k + 2, ArmorAng(k, 45))
    end 
end

hook.Add("HUDPaint", "tlouhud", function()
    if LocalPlayer():Alive() then
        healthBar()
        armorBar()
        weaponsAndAmmo()
    end
end)

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
    ["CHudWeapon"] = true
	}
	if ( hide[ name ] ) then
		return false
	end
end)

// DRAW ANOTHER BAR THAT GOES UP IN THICKNESSS AND GOES DOWN IN ALPHA IN COLOR

// WHEN PLAYER IS LOW HEALTH, TO MAKE THE GLOW ANIMATION MAKE A NEW VARIABLE THAT GOES FROM 1 TO 0, THATS THE ONE THAT WILL BE USED FOR 
// THE OPACITY, AND MAKE ANOTHER VARIABLE THAT GOES FROM 0 TO SOMETHING, THAT WILL BE THE THICKNESS OF THE BAR GROWING. THEN WHEN CERTAIN
// AMOUNT OF TIME IS UP RESET THE VARIABLES