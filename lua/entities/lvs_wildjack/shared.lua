ENT.Base = "lvs_tank_wheeldrive"

ENT.PrintName = "O'Brien V.130 Wild Jack"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's Foxhole Vehicles"
ENT.Category = "[LVS] - Foxhole"

ENT.VehicleCategory = "Foxhole"
ENT.VehicleSubCategory = "Armored Car"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/car_wildjack.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 900

ENT.SpawnNormalOffset = 40

//damage system
ENT.DSArmorIgnoreForce = 1200
ENT.CannonArmorPenetration = 3900

ENT.MaxVelocity = 233
ENT.MaxVelocityReverse = 200

ENT.EngineCurve = 0.2
ENT.EngineTorque = 500

ENT.TransGears = 3
ENT.TransGearsReverse = 1

ENT.FastSteerAngleClamp = 5
ENT.FastSteerDeactivationDriftAngle = 5

ENT.PhysicsWeightScale = 1.5
ENT.PhysicsDampingForward = true
ENT.PhysicsDampingReverse = true

ENT.lvsShowInSpawner = true

ENT.WheelBrakeAutoLockup = true
ENT.WheelBrakeLockupRPM = 15

ENT.EngineSounds = {
	{
		sound = "vehicles/ACIdle.wav",
		Volume = 0.66,
		Pitch = 80,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "vehicles/ACDrive.wav",
		Volume = 1.33,
		Pitch = 80,
		PitchMul = 100,
		SoundLevel = 75,
		UseDoppler = true,
	},
}

ENT.Lights = {
	{
		Trigger = "main",
		SubMaterialID = 1,
		Sprites = {
			[1] = {
				pos = Vector(57.1,22.3,77.4),
				colorB = 200,
				colorA = 150,
			},
		},
		ProjectedTextures = {
			[1] = {
				pos = Vector(57.1,22.3,77.4),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
		},
	},
}

function ENT:OnSetupDataTables()
	self:AddDT( "Entity", "GunnerSeat" )
end

function ENT:InitWeapons()
	local COLOR_WHITE = Color(255,255,255,255)

	//MACHINEGUN
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/mg.png")
	weapon.Ammo = 500
	weapon.Delay = 0.06
	weapon.HeatRateUp = 0.3
	weapon.HeatRateDown = 0.4
	weapon.Attack = function( ent )
		local ID = ent:LookupAttachment( "muzzle" )
		local Muzzle = ent:GetAttachment( ID )
		if not Muzzle then return end

		local useVFireFireball = false

		local ang = Muzzle.Ang
		ang:RotateAroundAxis(Muzzle.Ang:Right(), math.Rand(-3, 3))
		ang:RotateAroundAxis(Muzzle.Ang:Forward(), math.Rand(-3, 3))

		if vFireInstalled and useVFireFireball then
			local fireball = CreateVFireBall(35, 15, Muzzle.Pos + -ang:Forward() * 16, self:GetVelocity() + -Muzzle.Ang:Forward() * 1500, ent:GetDriver())
		else
			local projectile = ents.Create("lvs_foxhole_flame")
			projectile:SetPos( Muzzle.Pos )
			projectile:SetAngles( -ang )
			projectile:SetOwner(self)
			constraint.NoCollide(self, projectile, 0, 0)
			projectile:Spawn()
			projectile:Activate()

			local PhysObj = projectile:GetPhysicsObject()
			if IsValid( PhysObj ) then
				PhysObj:ApplyForceCenter( -ang:Forward() * 1200 + self:GetVelocity())
			end

		end
		ent:TakeAmmo( 1 )
	end
	weapon.StartAttack = function( ent )
		if not IsValid( ent.SNDTurretMG ) then return end
		ent.SNDTurretMG:Play()
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent.SNDTurretMG ) then return end
		ent.SNDTurretMG:Stop()
	end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	weapon.HudPaint = function( ent, X, Y, ply )
		local ID = ent:LookupAttachment( "muzzle" )

		local Muzzle = ent:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos, 
				endpos = Muzzle.Pos + -Muzzle.Ang:Forward() * 50000,
				filter = ent:GetCrosshairFilterEnts()
			} )

			local MuzzlePos2D = traceTurret.HitPos:ToScreen() 

			ent:PaintCrosshairCenter( MuzzlePos2D, COLOR_WHITE )
			ent:LVSPaintHitMarker( MuzzlePos2D )
		end
	end
	weapon.OnOverheat = function( ent )
		ent:EmitSound("lvs/overheat.wav")
	end
	self:AddWeapon( weapon, 1 )

	//NOTHING
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/tank_noturret.png")
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	weapon.OnSelect = function( ent )
		if ent.SetTurretEnabled then
			ent:SetTurretEnabled( false )
		end
	end
	weapon.OnDeselect = function( ent )
		if ent.SetTurretEnabled then
			ent:SetTurretEnabled( true )
		end
	end
	self:AddWeapon( weapon, 1 )
end


ENT.ExhaustPositions = {
	{
		pos = Vector(-78.3,21.2,57),
		ang = Angle(20,180,0),
	},
	{
		pos = Vector(-78.3,-21.2,57),
		ang = Angle(20,180,0),
	},
}