util.AddNetworkString("listenActivated")

// This whole file is only needed for singleplayer

if game.SinglePlayer() then

	local check = false

	net.Receive("listenActivated", function()
		check = net.ReadBool()

		if check then
			hook.Add("EntityEmitSound", "muffleServerSounds", function( tab )
				tab.Volume = tab.Volume * 0.3
	            tab.Pitch = tab.Pitch * 0.95
	            tab.SoundLevel = tab.SoundLevel * 0.8

	            return true
			end)
		else
			hook.Remove("EntityEmitSound", "muffleServerSounds")
		end
	end)

end

