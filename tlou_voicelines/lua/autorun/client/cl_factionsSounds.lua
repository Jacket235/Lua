include("autorun/shared.lua")
CreateClientConVar("factions_set_voice", "aggressor", true, false)

local vlTable = {
	aggressor = {
		ammo = 7,
		comboKill = 1,
		heal = 3,
		hurt = 3,
		kill = 16
	},
	leader = {
		ammo = 6,
		comboKill = 1,
		heal = 3,
		hurt = 3,
		kill = 16
	},
	nerd = {
		ammo = 4,
		comboKill = 1,
		heal = 3,
		hurt = 3,
		kill = 14
	},
	newbie = {
		ammo = 5,
		comboKill = 1,
		heal = 3,
		hurt = 3,
		kill = 17
	},
	ranger = {
		ammo = 6,
		comboKill = 1,
		heal = 3,
		hurt = 3,
		kill = 14
	},
	rookie = {
		ammo = 5,
		comboKill = 1,
		heal = 4,
		hurt = 3,
		kill = 13
	},
	sergeant = {
		ammo = 7,
		comboKill = 1,
		heal = 4,
		hurt = 3,
		kill = 14
	},
	veteran = {
		ammo = 5,
		comboKill = 1,
		heal = 3,
		hurt = 3,
		kill = 11
	}
}

local function createCategory()
	spawnmenu.AddToolCategory( "Utilities", "voiceSett", "#Voice Settings" )
end 

local function createSettings()
	spawnmenu.AddToolMenuOption( "Utilities", "voiceSett", "voiceSett", "#Voices", "", "", function(panel)
		panel:ClearControls()
		
		local selectLabel = vgui.Create( "DLabel", panel )
		selectLabel:SetTextColor(Color(0,0,0))
		selectLabel:SetPos(115, 20)
		selectLabel:SetSize(120, 20)
		selectLabel:SetText( "Select a voice" )

		local pickVoice = vgui.Create( "DComboBox", panel )
		pickVoice:SetPos(100,40)
		pickVoice:SetSize(100,20)
		pickVoice:SetValue("Pick a voice")
		pickVoice:AddChoice("Aggressor", "aggressor")
		pickVoice:AddChoice("Leader", "leader")
		pickVoice:AddChoice("Nerd", "nerd")
		pickVoice:AddChoice("Newbie", "newbie")
		pickVoice:AddChoice("Ranger", "ranger")
		pickVoice:AddChoice("Rookie", "rookie")
		pickVoice:AddChoice("Sergeant", "sergeant")
		pickVoice:AddChoice("Veteran", "veteran")
		function pickVoice:OnSelect(index, value, data)
			GetConVar("factions_set_voice"):SetString(data)
		end
	end)
end

hook.Add("AddToolMenuCategories", "createCategory", createCategory)
hook.Add("PopulateToolMenu", "createSettings", createSettings)

local voiceCoolDownStart = CurTime()
local mentionedAmmo = false
local isRespawning = false
local plyOldHP, plyNewHP = -1, -1

hook.Add("Think", "vlThink", function()
	local ply = LocalPlayer()

	// Ammo
	local currWep = ply:GetActiveWeapon()

	if currWep:IsValid() then
		if(currWep:Clip1() != -1 and currWep:GetPrimaryAmmoType() != nil) then
			if currWep:Clip1() == 0 and ply:GetAmmoCount(currWep:GetPrimaryAmmoType()) == 0 then
				if mentionedAmmo == false then
					LocalPlayer():EmitSound("factions/ammo/" .. GetConVar("factions_set_voice"):GetString() .. math.random(1, vlTable[GetConVar("factions_set_voice"):GetString()].ammo) .. ".mp3")
					mentionedAmmo = true
					voiceCoolDownStart = CurTime()
				end
			end
			if mentionedAmmo == true then
				if currWep:Clip1() ~= 0 or ply:GetAmmoCount(currWep:GetPrimaryAmmoType()) ~= 0 then
					mentionedAmmo = false
				end
			end
		end
	end

	// Healing
	local plyHP = ply:Health()

	if plyOldHP == -1 and plyNewHP == -1 then
        plyOldHP = plyHP
        plyNewHP = plyHP
    end

    if plyNewHP ~= plyHP then
    	if plyHP <= 0 then
	    	isRespawning = true
	    end
    	if (plyHP > plyNewHP) and (CurTime() - voiceCoolDownStart > 4) and (not isRespawning) then
    		LocalPlayer():EmitSound("factions/heal/" .. GetConVar("factions_set_voice"):GetString() .. math.random(1, vlTable[GetConVar("factions_set_voice"):GetString()].heal) .. ".mp3")
    		voiceCoolDownStart = CurTime()
    	end
    	if plyHP >= ply:GetMaxHealth() then
    		isRespawning = false
    	end
    	plyOldHP = plyNewHP
    	plyNewHP = plyHP
    end
end)

local notTooManyCKs = true

net.Receive("vlKill", function()

	if CurTime() - voiceCoolDownStart > 1.5 then
		if notTooManyCKs and (CurTime() - voiceCoolDownStart < 2.5) then
			LocalPlayer():EmitSound("factions/comboKill/" .. GetConVar("factions_set_voice"):GetString() .. "1.mp3")
			voiceCoolDownStart = CurTime()
			notTooManyCKs = false
		else
			LocalPlayer():EmitSound("factions/kill/" .. GetConVar("factions_set_voice"):GetString() .. math.random(1, vlTable[GetConVar("factions_set_voice"):GetString()].kill) .. ".mp3", 100)
			voiceCoolDownStart = CurTime()
			notTooManyCKs = true
		end
	end 
end)

net.Receive("vlHurt", function()
	if CurTime() - voiceCoolDownStart > 15 then
		LocalPlayer():EmitSound("factions/hurt/" .. GetConVar("factions_set_voice"):GetString() .. math.random(1, vlTable[GetConVar("factions_set_voice"):GetString()].hurt) .. ".mp3", 100) 
		voiceCoolDownStart = CurTime()
	end
end)