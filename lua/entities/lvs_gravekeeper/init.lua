AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile("sh_turret.lua")
include("shared.lua")
include("sh_turret.lua")


function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(35,0,40), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true

	local GunnerSeat = self:AddPassengerSeat( Vector(20,0,62), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = false
	self:SetGunnerSeat( GunnerSeat )

	local ID = self:LookupAttachment( "muzzle_rpg" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "vehicles/RPGLauncher01.wav", "vehicles/RPGLauncher01.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	self:AddEngine( Vector(-72,0,72), Angle(0,-90,0) )
	self:AddFuelTank( Vector(-82,0,71), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )

	-- example:
	local WheelModel = "models/wheel_obrien.mdl"

	local WheelFrontLeft = self:AddWheel( { pos = Vector(53,41,25), mdl = WheelModel, mdl_ang = Angle(0,-90,0) } )
	local WheelFrontRight = self:AddWheel( { pos = Vector(53,-41,25), mdl = WheelModel, mdl_ang = Angle(0,90,0) } )

	local WheelRearLeft = self:AddWheel( { pos = Vector(-67,41,25), mdl = WheelModel, mdl_ang = Angle(0,-90,0) } )
	local WheelRearRight = self:AddWheel( { pos = Vector(-67,-41,25), mdl = WheelModel, mdl_ang = Angle(0,90,0) } )

	local SuspensionSettings = {
		Height = 12,
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
	local TurretArmor = self:AddArmor( Vector(20,0,75), Angle(0,0,0), Vector(-30,-25,0), Vector(30,25,30), 800, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )
end

function ENT:MakeProjectile()

	local ID = self:LookupAttachment( "muzzle_rpg" )
	local Muzzle = self:GetAttachment( ID )

	if not Muzzle then return end

	local Driver = self:GetDriver()

	local projectile = ents.Create( "lvs_bomb" )
	projectile:SetPos( Muzzle.Pos )
	projectile:SetAngles( Muzzle.Ang )
	projectile:SetParent( self, ID )
	projectile:Spawn()
	projectile:Activate()
	projectile:SetModel("models/proj_arcrpg.mdl")
	projectile:SetAttacker( IsValid( Driver ) and Driver or self )
	projectile:SetEntityFilter( self:GetCrosshairFilterEnts() )
	projectile:SetSpeed( Muzzle.Ang:Forward() * 2500 )
	projectile:SetDamage( 600 )
	projectile.UpdateTrajectory = function( bomb )
		bomb:SetSpeed( bomb:GetForward() * 2500 )
	end

	if projectile.SetMaskSolid then
		projectile:SetMaskSolid( true )
	end

	self._ProjectileEntity = projectile
end

function ENT:FireProjectile()

	local ID = self:LookupAttachment( "muzzle_rpg" )
	local Muzzle = self:GetAttachment( ID )

	if not Muzzle or not IsValid( self._ProjectileEntity ) then return end

	self._ProjectileEntity:Enable()
	self._ProjectileEntity:SetCollisionGroup( COLLISION_GROUP_NONE )

	local effectdata = EffectData()
		effectdata:SetOrigin( self._ProjectileEntity:GetPos() )
		effectdata:SetEntity( self._ProjectileEntity )
	util.Effect( "lvs_haubitze_trail", effectdata )

	local effectdata = EffectData()
	effectdata:SetOrigin( Muzzle.Pos)
	effectdata:SetNormal( Muzzle.Ang:Forward() )
	effectdata:SetEntity( self )
	util.Effect( "lvs_muzzle", effectdata )

	local PhysObj = self:GetPhysicsObject()
	if IsValid( PhysObj ) then
		PhysObj:ApplyForceOffset( -Muzzle.Ang:Forward() * 150000, Muzzle.Pos )
	end

	self:TakeAmmo()
	self:SetHeat( 1 )
	self:SetOverheated( true )

	self._ProjectileEntity = nil

	if not IsValid( self.SNDTurret ) then return end

	self.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )

	self:EmitSound("vehicles/RPGReload2.wav", 100, 100, 1, CHAN_WEAPON )
end

-- set material on death
function ENT:OnDestroyed()
	self:SetMaterial("props/metal_damaged")
end