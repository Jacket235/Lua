CreateClientConVar("hearingability", "H", true, false)

local alpha = 0

hook.Add( "PreDrawHalos", "addingGlow", function()
	local players = {}
	local entits = {}

	for _, ply in ipairs(player.GetAll()) do
		players[#players + 1] = ply
	end
	for _, ent in ipairs( ents.FindByClass( "npc_*" ) ) do
		entits[#entits + 1] = ent
	end

	if input.IsKeyDown( input.GetKeyCode(GetConVar("hearingability"):GetString())) then
		alpha = math.Approach(alpha, 1, FrameTime() / 1.15)
		local color = Color( 255, 255, 255, 180 * alpha)
		surface.SetDrawColor(0, 0 ,0, 200 * alpha)
		surface.DrawRect(-200, -200, ScrW(), ScrH())
		halo.Add(  players, color, 2, 5, 10, true, true )
	end
	if !input.IsKeyDown( input.GetKeyCode(GetConVar("hearingability"):GetString())) then
		alpha = 0
	end
end )

/*
- Cooldown on the listening mode,
- Grey screen when going into listening mode,
- Polish the outlines,
- Outline shit, only when it is in a certain range.
- MAYBE The closer you are to someone, the outlines thickens
*/