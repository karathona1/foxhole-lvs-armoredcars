AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_tankview.lua" )
AddCSLuaFile( "sh_turret.lua" )
AddCSLuaFile( "sh_tracks.lua" )
include("shared.lua")
include("sh_tracks.lua")
include("sh_turret.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(20.3,0,35), Angle(0,-90,0) )
	DriverSeat.ExitPos = Vector(104,0,30)
	DriverSeat.HidePlayer = true

	local GunnerSeat = self:AddPassengerSeat( Vector(0,0,60), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = false
	self:SetGunnerSeat( GunnerSeat )

	local ID = self:LookupAttachment( "muzzle_mg1" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 100 )
	self.SNDTurretMG:SetParent( self, ID )

	local ID2 = self:LookupAttachment( "muzzle_mg2" )
	local Muzzle2 = self:GetAttachment( ID2 )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle2.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 100 )
	self.SNDTurretMG:SetParent( self, ID2 )

	self:AddEngine( Vector(-48,0,75), Angle(0,-90,0) )
	self:AddFuelTank( Vector(-48,0,75), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )

	self:AddTrailerHitch( Vector(-79,0,31.81), LVS.HITCHTYPE_MALE )

	-- FRONT ARMOR
	self:AddArmor( Vector(70,0,35), Angle( 0,0,0 ), Vector(-10,-35,-15), Vector(10,35,42), 400, self.FrontArmor )

	-- LEFT ARMOR
	self:AddArmor( Vector(0,35,35), Angle( 0,0,0 ), Vector(-40,-10,-15), Vector(60,10,42), 300, self.SideArmor )

	-- Right ARMOR
	self:AddArmor( Vector(0,-35,35), Angle( 0,0,0 ), Vector(-40,-10,-15), Vector(60,10,42), 300, self.SideArmor )

	-- FRONT ARMOR
	self:AddArmor( Vector(-45,0,35), Angle( 0,0,0 ), Vector(-50,-15,-15), Vector(10,15,55), 200, self.RearArmor )


	-- TURRET ARMOR
	local TurretArmor = self:AddArmor( Vector(6,0,75), Angle(0,0,0), Vector(-25,-25,0), Vector(25,25,30), 1000, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )
	
end

-- set material on death
function ENT:OnDestroyed()
	self:SetMaterial("props/metal_damaged")
end
