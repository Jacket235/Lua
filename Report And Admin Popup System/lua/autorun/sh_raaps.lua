activeClaims = {}
cfg = {}

cfg.xpos = 20 -- Changes where the claims appear on the X axis. 
cfg.ypos = 20 -- Changes where the claims appear on the Y axis.
cfg.shouldAdminsReport = true -- Should admins be able to use the !report command and create pop ups.
cfg.adminMod = "ulx" -- Available: ulx, sg (serverguard, but type sg for it to work), sam, sa (sAdmin).
cfg.reportUpdatePrefix = "#" -- The prefix for updating report info.
cfg.gapBetweenClaims = 22 -- How big is the gap between the claims

/*Don't touch stuff below*/

cfg.modCommands = {
	ulx = {
		Goto = "ulx goto " ,
		Bring = "ulx bring ",
		Return = "ulx return ",
		Freeze = "ulx freeze ",
		Unfreeze = "ulx unfreeze ",
		Gag = "ulx gag ",
		Ungag = "ulx ungag ",
		God = "ulx god ",
		Ungod = "ulx ungod ",
		Cloak = "ulx cloak ",
		Uncloak = "ulx uncloak ",
	},
	sam = {
		Goto = "sam goto " ,
		Bring = "sam bring ",
		Return = "sam return ",
		Freeze = "sam freeze ",
		Unfreeze = "sam unfreeze ",
		Gag = "sam gag ",
		Ungag = "sam ungag ",
		God = "sam god ",
		Ungod = "sam ungod ",
		Cloak = "sam cloak ",
		Uncloak = "sam uncloak "
	},
	sg = {
		Goto = "sg goto " ,
		Bring = "sg bring ",
		Return = "sg return ",
		Freeze = "sg freeze ",
		Unfreeze = "sg unfreeze ",
		Gag = "sg gag ",
		Ungag = "sg ungag ",
		God = "sg god ",
		Ungod = "sg ungod ",
		Cloak = "sg invisible ",
		Uncloak = "sg invisible "
	},
	sa = {
		Goto = "sa goto " ,
		Bring = "sa bring ",
		Return = "sa return ",
		Freeze = "sa freeze ",
		Unfreeze = "sa unfreeze ",
		Gag = "sa gag ",
		Ungag = "sa ungag ",
		God = "sa god ",
		Ungod = "sa ungod ",
		Cloak = "sa cloak ",
		Uncloak = "sa uncloak "
	},
}

function hasAccess(ply)
	if ulx then return ply:query("ulx seeasay")	end
	if serverguard then return serverguard.player:HasPermission(ply, "Manage Reports") end
	if sam then return ply:HasPermission( "see_admin_chat" ) end	
	if sAdmin then return sAdmin.hasPermission( ply, "is_staff" ) end

	return ply:IsAdmin()
end