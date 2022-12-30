CreateClientConVar("hearingability", "H", true, false)
CreateClientConVar("hearingability_distance", "500", true, false)
CreateClientConVar("hearingability_cooldown", "1", true, false)

local alpha = 0
alphaIndividual = 0
local time = CurTime()

hook.Add( "PreDrawHalos", "addingGlow", function()
	local haloInfo = {}
	local target = {}

	// Get info about targets
	for _, ply in ipairs(player.GetAll()) do
		local dist = LocalPlayer():GetPos():DistToSqr(ply:GetPos())
		if dist < GetConVar("hearingability_distance"):GetInt() ^2 then
			haloInfo[#haloInfo + 1] = {target = ply, distance = dist, color = Color(255, 255, 255, 70)}
		end
	end
	for _, ent in ipairs(ents.FindByClass( "npc_*" )) do
		local dist = LocalPlayer():GetPos():DistToSqr(ent:GetPos())
		if dist < GetConVar("hearingability_distance"):GetInt() ^2 then
			haloInfo[#haloInfo + 1] = {target = ent, distance = dist, color = Color(255,255,255, 70)}
		end
	end
	// Add targets into a seperate table
	for k, v in pairs(haloInfo) do
		target[#target + 1] = v.target
	end

	if input.IsKeyDown( input.GetKeyCode(GetConVar("hearingability"):GetString()) ) && CurTime() - time > GetConVar("hearingability_cooldown"):GetInt() then
		alpha = math.Approach( alpha, 1, FrameTime() / 1.20 )
		local colorOutline = Color( 255, 255, 255, 70 * alpha )

		surface.SetDrawColor(0, 0 ,0, 200 * alpha)
		surface.DrawRect(-200, -200, ScrW(), ScrH())
		halo.Add( target, colorOutline, 6, 3, 1, true, true )
		
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
What I've tried doing:
- In the loop that adds entities that should draw, if you multiply by alphaIndividual then the alpha goes up as soon as an entity was added,
so pressing the button does nothing
*/

















/*
CreateClientConVar("hearingability", "H", true, false)
CreateClientConVar("hearingability_distance", "500", true, false)
CreateClientConVar("hearingability_cooldown", "1", true, false)

local alpha = 0
alphaIndividual = 0
local time = CurTime()

hook.Add( "PreDrawHalos", "addingGlow", function()
	local haloInfo = {}
	local target = {}

	// Get info about targets
	for _, ply in ipairs(player.GetAll()) do
		local dist = LocalPlayer():GetPos():DistToSqr(ply:GetPos())
		if dist < GetConVar("hearingability_distance"):GetInt() ^2 then
			haloInfo[#haloInfo + 1] = {target = ply, distance = dist, color = Color(255, 255, 255, 70)}
		end
	end
	for _, ent in ipairs(ents.FindByClass( "npc_*" )) do
		local dist = LocalPlayer():GetPos():DistToSqr(ent:GetPos())
		if dist < GetConVar("hearingability_distance"):GetInt() ^2 then
			haloInfo[#haloInfo + 1] = {target = ent, distance = dist, color = Color(255,255,255, 70)}
		end
	end
	// Add targets into a seperate table
	for k, v in pairs(haloInfo) do
		target[#target + 1] = v.target
	end

	if input.IsKeyDown( input.GetKeyCode(GetConVar("hearingability"):GetString()) ) && CurTime() - time > GetConVar("hearingability_cooldown"):GetInt() then
		alpha = math.Approach( alpha, 1, FrameTime() / 1.20 )
		local colorOutline = Color( 255, 255, 255, 70 * alpha )

		surface.SetDrawColor(0, 0 ,0, 200 * alpha)
		surface.DrawRect(-200, -200, ScrW(), ScrH())
		halo.Add( target, colorOutline, 6, 3, 1, true, true )
		
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
*/
