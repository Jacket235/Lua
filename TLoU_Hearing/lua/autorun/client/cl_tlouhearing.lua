CreateClientConVar("hearingability", "H", true, true)
CreateClientConVar("hearingability_distance", "500", true, true)

local alpha = 0
local target = {}

hook.Add( "PreDrawHalos", "addingGlow", function()

    for _, ent in ipairs(ents.FindByClass('npc_*')) do
        local dist = LocalPlayer():EyePos():DistToSqr(ent:GetPos() + ent:OBBCenter())
        if dist > GetConVar("hearingability_distance"):GetInt() ^2 then 
            if target[ent] then 
                target[ent] = nil 
            end
        else
            local alphaIndi = (1 - dist / GetConVar("hearingability_distance"):GetInt() ^2)
            target[ent] = Color(255, 255, 255, alphaIndi * 70)
        end
    end
    for _, ply in ipairs(player.GetAll()) do
        local dist = LocalPlayer():EyePos():DistToSqr(ply:GetPos() + ply:OBBCenter())
        if dist > GetConVar("hearingability_distance"):GetInt() ^2 then 
            if target[ply] then 
                target[ply] = nil 
            end
        else
            local alphaIndi = 1 - dist / GetConVar("hearingability_distance"):GetInt() ^2
            target[ply] = Color(255, 255, 255, alphaIndi * 70)
        end
    end

    if input.IsKeyDown( input.GetKeyCode(GetConVar("hearingability"):GetString()) ) && LocalPlayer():Alive() then

        // This is only needed for singleplayer
        if game.SinglePlayer() then
            net.Start("listenActivated")
                net.WriteBool(true)
            net.SendToServer()
        end


        alpha = math.Approach( alpha, 1, FrameTime() / 0.8 )
        local color = Color( 255, 255, 255, 70 * alpha )
        surface.SetDrawColor(0, 0 ,0, 210 * alpha)
        surface.DrawRect(-200, -200, ScrW(), ScrH())
        

        for ent, col in pairs(target) do
            if not IsValid(ent) or col == nil then continue end
            halo.Add({ent}, col, 6, 4, 1, true, true)
        end

        // Sounds played from the cl
        hook.Add("EntityEmitSound", "mufflingSounds", function( clientTab )
            clientTab.Volume = clientTab.Volume * 0.3
            clientTab.Pitch = clientTab.Pitch * 0.95
            clientTab.SoundLevel = clientTab.SoundLevel * 0.8

            return true
        end)

    else
        // Only needed for singleplayer
        net.Start("listenActivated")
            net.WriteBool(false)
        net.SendToServer()

        alpha = math.Approach(alpha, 0, FrameTime() / 0.3)
        if alpha > 0 then
            surface.SetDrawColor(0, 0 ,0, 200 * alpha)
            surface.DrawRect(-200, -200, ScrW(), ScrH())
        end
        hook.Remove("EntityEmitSound", "mufflingSounds")
    end
end )

