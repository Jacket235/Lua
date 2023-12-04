CreateClientConVar("hpregen_nohittime", 4, true, false)
CreateClientConVar("hpregen_regento", 50, true, false)

local plyStartHP, plyOldHP, plyNewHP = 0, -1, -1
local lastActionDamage = -1

hook.Add("Think", "hpregen", function()
	local ply = LocalPlayer()

    local plyHP = ply:Health()
    local plyMaxHP = ply:GetMaxHealth()

    if lastActionDamage == -1 then
        lastActionDamage = CurTime()
    end

    if plyOldHP == -1 and plyNewHP == -1 then
        plyOldHP = plyHP
        plyNewHP = plyHP
    end

    if plyNewHP ~= plyHP then
        plyOldHP = plyNewHP
        plyStartHP = CurTime()
        lastActionDamage = CurTime()
        plyNewHP = plyHP
    end

    // if the player's health is lower than 50, then if no damage is taken for 5 seconds, regen the player.

    if plyHP < GetConVar("hpregen_regento"):GetInt() then
    	if CurTime() - lastActionDamage > GetConVar("hpregen_nohittime"):GetInt() then
    		net.Start("regenPlayer")
    		net.WriteInt(GetConVar("hpregen_regento"):GetInt(), 32)
    		net.SendToServer()
    	end
    end
end)