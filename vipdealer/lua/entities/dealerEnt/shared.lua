RankNPC = {}
RankNPC.Staff = {
	"superadmin",
	"admin",
	"operator"
}

ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.AutomaticFrameAdvance = true

ENT.PrintName = "VIP Rank Store"

ENT.Spawnable = true

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
    self.AutomaticFrameAdvance = bUsingAnim
end 