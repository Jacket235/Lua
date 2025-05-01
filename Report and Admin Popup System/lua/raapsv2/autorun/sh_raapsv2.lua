RAAPS = {}

RAAPS.cfg = {
	addon = "ulx",
	shouldAdminsCreateReports = true,
	reportUpdatePrefix = "#",
	repMenuCmd = "!rep"
}

RAAPS.Commands = {
	ulx = {
		Goto = "ulx goto ",
		Bring = "ulx bring ",
		Return = "ulx return ",
		Freeze = "ulx freeze ",
		Unfreeze = "ulx unfreeze ",
		Mute = "ulx mute ",
		Unmute = "ulx unmute "
	}
}

function isStaff(ply)
	return ply:IsAdmin()
end