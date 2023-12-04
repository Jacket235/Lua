JTC = {}
JTC.Players = {}
JTC.Jobs = {}

jobTimesCommand = "!jobleaderboard" 

local saveDir = "JobTime"

function JTC.Load()
	local data = file.Read(saveDir .. "/jobs.txt", "DATA")
	if not data then return end

	JTC.Jobs = util.JSONToTable(data)
end

function JTC.Save()
	if not file.Exists(saveDir, "DATA") then
		file.CreateDir(saveDir)
	end
	file.Write(saveDir .. "/jobs.txt", util.TableToJSON(JTC.Jobs, true))
end