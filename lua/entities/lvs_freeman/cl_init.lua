AddCSLuaFile( "shared.lua" )
AddCSLuaFile("cl_tankview.lua")
AddCSLuaFile("cl_optics.lua")
include("shared.lua")
include("cl_tankview.lua")
include("cl_optics.lua")

function ENT:OnFrame()
	local Heat = 0
	if self:GetSelectedWeapon() == 1 then
		Heat
 = self:QuickLerp( "mg_heat", self:GetNWHeat(), 10 )
	else
		Heat
 = self:QuickLerp( "mg_heat", 0, 0.25 )
	end
	local name = "freeman_mgglow_"..self:EntIndex()
	if not self.TurretGlow2 then
		self.TurretGlow2 = self:CreateSubMaterial( 2, name )

		return
	end
	if self._oldGunHeat ~= Heat then
		self._oldGunHeat
 = Heat


		self.TurretGlow2:SetFloat("$detailblendfactor", Heat
 ^ 7 )

		self:SetSubMaterial(2, "!"..name)
	end
end