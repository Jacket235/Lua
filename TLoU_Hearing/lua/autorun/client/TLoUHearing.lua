CreateClientConVar("hearingability", "H", true, false)
CreateClientConVar("hearingability_distance", "500", true, false)
CreateClientConVar("hearingability_cooldown", "1", true, false)

local alpha = 0
local time = CurTime()

hook.Add( "PreDrawHalos", "addingGlow", function()
	local renderedHalos = {}

	for _, ply in ipairs(player.GetAll()) do
		if LocalPlayer():GetPos():DistToSqr(ply:GetPos() ) < GetConVar("hearingability_distance"):GetInt() * GetConVar("hearingability_distance"):GetInt() then
			renderedHalos[#renderedHalos + 1] = ply
		end
	end
	for _, ent in ipairs(ents.FindByClass( "npc_*" )) do
		if LocalPlayer():GetPos():DistToSqr(ent:GetPos() ) < GetConVar("hearingability_distance"):GetInt() * GetConVar("hearingability_distance"):GetInt() then
			renderedHalos[#renderedHalos + 1] = ent
		end
	end

	if input.IsKeyDown( input.GetKeyCode(GetConVar("hearingability"):GetString()) ) && CurTime() - time > GetConVar("hearingability_cooldown"):GetInt() then
		alpha = math.Approach( alpha, 1, FrameTime() / 1.20 )
		local color = Color( 255, 255, 255, 70 * alpha )

		surface.SetDrawColor(0, 0 ,0, 200 * alpha)
		surface.DrawRect(-200, -200, ScrW(), ScrH())
		halo.Add( renderedHalos, color, 6, 3, 1, true, true )

		hook.Add("EntityEmitSound", "mufflingSounds", function( tab )
			tab.Volume = tab.Volume * 0.3
			tab.Pitch = tab.Pitch * 0.95
			tab.SoundLevel = tab.SoundLevel * 0.8

			return true
		end)
	end
end )
hook.Add( "PlayerButtonUp", "shittingMyPants", function( _, button )
	if button == input.GetKeyCode(GetConVar("hearingability"):GetString()) && CurTime() - time > GetConVar("hearingability_cooldown"):GetInt() then
		time = CurTime()
		alpha = 0
	end
	hook.Remove("EntityEmitSound", "mufflingSounds")
end)

/*
- Make the sound quiet when in listen mode
*/