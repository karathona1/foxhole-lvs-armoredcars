AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_turret.lua")
AddCSLuaFile("sh_tracks.lua")
include("shared.lua")
include("sh_turret.lua")
include("sh_tracks.lua")


function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(35,0,40), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true

	local GunnerSeat = self:AddPassengerSeat( Vector(20,0,62), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = false
	self:SetGunnerSeat( GunnerSeat )

	local ID = self:LookupAttachment( "muzzle_mgl" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local ID2 = self:LookupAttachment( "muzzle_mgr" )
	local Muzzle2 = self:GetAttachment( ID2 )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle2.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID2 )

	self:AddEngine( Vector(-72,0,72), Angle(0,-90,0) )
	self:AddFuelTank( Vector(-82,0,71), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )

	//FRONT ARMOR
	self:AddArmor( Vector(85,0,35), Angle( -35,0,0 ), Vector(-10,-35,-15), Vector(10,35,50), 400, self.FrontArmor )

	//LEFT ARMOR
	self:AddArmor( Vector(0,35,35), Angle( 0,0,0 ), Vector(-40,-10,-15), Vector(60,10,42), 300, self.SideArmor )

	//Right ARMOR
	self:AddArmor( Vector(0,-35,35), Angle( 0,0,0 ), Vector(-40,-10,-15), Vector(60,10,42), 300, self.SideArmor )

	//BACK ARMOR
	self:AddArmor( Vector(-45,0,35), Angle( 0,0,0 ), Vector(-50,-35,-15), Vector(10,35,42), 200, self.BackArmor )


	//TURRET ARMOR
	local TurretArmor = self:AddArmor( Vector(20,0,75), Angle(0,0,0), Vector(-30,-25,0), Vector(30,25,30), 800, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )
end

-- set material on death
function ENT:OnDestroyed()
	self:SetMaterial("props/metal_damaged")
end