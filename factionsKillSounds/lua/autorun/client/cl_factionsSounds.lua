include("autorun/shared.lua")
CreateClientConVar("factions_set_voice", "sergeant", true, false)

local function createCategory()
	spawnmenu.AddToolCategory( "Utilities", "voiceSett", "#Voice Settings" )
end 

local function createSettings()
	spawnmenu.AddToolMenuOption( "Utilities", "voiceSett", "voiceSett", "#Voices", "", "", function(panel)
		panel:ClearControls()
		
		local selectLabel = vgui.Create( "DLabel", panel )
		selectLabel:SetTextColor(Color(0,0,0))
		selectLabel:SetPos( 115, 20 )
		selectLabel:SetSize( 120, 20)
		selectLabel:SetText( "Select a voice" )

		local pickVoice = vgui.Create( "DComboBox", panel )
		pickVoice:SetPos(100,40)
		pickVoice:SetSize(100,20)
		pickVoice:SetValue("Pick a voice")
		pickVoice:AddChoice("Sergeant", "sergeant")
		pickVoice:AddChoice("Veteran", "veteran")
		pickVoice:AddChoice("Rookie", "rookie")
		pickVoice:AddChoice("Ranger", "ranger")
		function pickVoice:OnSelect(index, value, data)
			GetConVar("factions_set_voice"):SetString(data)
			net.Start("SelectedVoice")
				net.WriteString(data)
			net.SendToServer()
		end
	end)
end

hook.Add("AddToolMenuCategories", "createCategory", createCategory)
hook.Add("PopulateToolMenu", "createSettings", createSettings)
