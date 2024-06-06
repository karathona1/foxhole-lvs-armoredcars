AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile("sh_turret.lua")
include("shared.lua")
include("sh_turret.lua")


function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(20,0,28), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true

	local GunnerSeat = self:AddPassengerSeat( Vector(10,0,57), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	local ID = self:LookupAttachment( "muzzle_rpg1" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "vehicles/RPGLauncher01.wav", "vehicles/RPGLauncher01.wav" )
	self.SNDTurret:SetSoundLevel( 100 )
	self.SNDTurret:SetParent( self, ID )

	local ID2 = self:LookupAttachment( "muzzle_rpg2" )
	local Muzzle2 = self:GetAttachment( ID2 )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle2.Pos ), "vehicles/RPGLauncher01.wav", "vehicles/RPGLauncher01.wav" )
	self.SNDTurret:SetSoundLevel( 100 )
	self.SNDTurret:SetParent( self, ID )

	self:AddEngine( Vector(-72,0,72), Angle(0,-90,0) )
	self:AddFuelTank( Vector(-82,0,71), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )

	-- example:
	local WheelModel = "models/wheel_xiphos.mdl"

	local WheelFrontLeft = self:AddWheel( { pos = Vector(53,41,25), mdl = WheelModel, mdl_ang = Angle(0,180,0) } )
	local WheelFrontRight = self:AddWheel( { pos = Vector(53,-41,25), mdl = WheelModel } )

	local WheelRearLeft = self:AddWheel( { pos = Vector(-67,41,25), mdl = WheelModel, mdl_ang = Angle(0,180,0) } )
	local WheelRearRight = self:AddWheel( { pos = Vector(-67,-41,25), mdl = WheelModel} )

	local SuspensionSettings = {
		Height = 7,
		MaxTravel = 7,
		ControlArmLength = 25,
		SpringConstant = 20000,
		SpringDamping = 2000,
		SpringRelativeDamping = 2000,
	}

	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_FRONT,
			SteerAngle = 30,
			TorqueFactor = 0.3,
			BrakeFactor = 1,
		},
		Wheels = { WheelFrontLeft, WheelFrontRight },
		Suspension = SuspensionSettings,
	} )

	local RearAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_NONE,
			TorqueFactor = 0.7,
			BrakeFactor = 1,
			UseHandbrake = true,
		},
		Wheels = { WheelRearLeft, WheelRearRight },
		Suspension = SuspensionSettings,
	} )

		//FRONT ARMOR
		self:AddArmor( Vector(85,0,35), Angle( -35,0,0 ), Vector(-10,-35,-15), Vector(10,35,50), 400, self.FrontArmor )

		//LEFT ARMOR
		self:AddArmor( Vector(0,35,35), Angle( 0,0,0 ), Vector(-40,-10,-15), Vector(60,10,42), 300, self.SideArmor )
	
		//Right ARMOR
		self:AddArmor( Vector(0,-35,35), Angle( 0,0,0 ), Vector(-40,-10,-15), Vector(60,10,42), 300, self.SideArmor )
	
		//BACK ARMOR
		self:AddArmor( Vector(-45,0,35), Angle( 0,0,0 ), Vector(-50,-35,-15), Vector(10,35,42), 200, self.BackArmor )
	
	
		//TURRET ARMOR
		local TurretArmor = self:AddArmor( Vector(10,0,75), Angle(0,0,0), Vector(-30,-25,0), Vector(30,25,30), 800, self.TurretArmor )
		TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
		TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
		TurretArmor:SetLabel( "Turret" )
		self:SetTurretArmor( TurretArmor )
end
