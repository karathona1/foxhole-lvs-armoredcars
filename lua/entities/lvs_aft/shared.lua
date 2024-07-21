
ENT.Base = "lvs_tank_wheeldrive"

ENT.PrintName = "Armoured Fighting Tractor"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's Foxhole Vehicles"
ENT.Category = "[LVS] - Foxhole"

ENT.VehicleCategory = "Foxhole"
ENT.VehicleSubCategory = "Armored Car"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/tank_aft.mdl"

ENT.AITEAM = 2

ENT.MaxHealth = 1250

//damage system
ENT.DSArmorIgnoreForce = 1202
ENT.CannonArmorPenetration = 3900

ENT.MaxVelocity = 250
ENT.MaxVelocityReverse = 200

ENT.EngineCurve = 0.8
ENT.EngineTorque = 200

ENT.TransGears = 3
ENT.TransGearsReverse = 1

ENT.FastSteerAngleClamp = 10
ENT.FastSteerDeactivationDriftAngle = 10

ENT.PhysicsWeightScale = 1
ENT.PhysicsDampingForward = true
ENT.PhysicsDampingReverse = true

ENT.lvsShowInSpawner = true

ENT.WheelBrakeAutoLockup = true
ENT.WheelBrakeLockupRPM = 15

ENT.EngineSounds = {
	{
		sound = "vehicles/ACIdle.wav",
		Volume = 1,
		Pitch = 100,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "vehicles/ACDrive.wav",
		Volume = 1.33,
		Pitch = 50,
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
				pos = Vector(68.78,26.4,40.05),
				colorB = 200,
				colorA = 150,
			},
			[2] = {
				pos = Vector(68.78,-26.4,40.05),
				colorB = 200,
				colorA = 150,
			},
		},
		ProjectedTextures = {
			[1] = {
				pos = Vector(68.78,26.4,40.05),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
			[2] = {
				pos = Vector(68.78,-26.4,40.05),
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

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/792mm.png")
	weapon.Ammo = 750
	weapon.Delay = 0.1
	weapon.HeatRateUp = 0.15
	weapon.HeatRateDown = 0.2
	weapon.Attack = function( ent )
		//MACHINEGUN 1
		local ID = ent:LookupAttachment( "muzzle_mg1" )

		local Muzzle = ent:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= -Muzzle.Ang:Forward()
		bullet.Spread 	= Vector(0.005,0.005,0.005)
		bullet.TracerName = "lvs_tracer_yellow_small"
		bullet.Force	= 100
		bullet.HullSize = 0
		bullet.Damage	= 12
		bullet.Velocity = 30000
		bullet.Attacker = ent:GetDriver()
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		//MACHINEGUN 2
		local ID2 = ent:LookupAttachment( "muzzle_mg2" )

		local Muzzle2 = ent:GetAttachment( ID2 )

		if not Muzzle2 then return end

		local bullet2 = {}
		bullet2.Src 	= Muzzle2.Pos
		bullet2.Dir 	= -Muzzle2.Ang:Forward()
		bullet2.Spread 	= Vector(0.005,0.005,0.005)
		bullet2.TracerName = "lvs_tracer_yellow_small"
		bullet2.Force	= 100
		bullet2.HullSize = 0
		bullet2.Damage	= 12
		bullet2.Velocity = 30000
		bullet2.Attacker = ent:GetDriver()
		ent:LVSFireBullet( bullet2 )

		local effectdata2 = EffectData()
		effectdata:SetOrigin( bullet2.Src )
		effectdata:SetNormal( bullet2.Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata2 )

		local PhysObj = ent:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -bullet.Dir * 10000, bullet.Src )
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
		local ID = ent:LookupAttachment( "muzzle_mg" )

		local Muzzle = ent:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos, 
				endpos = Muzzle.Pos + -Muzzle.Ang:Right() * 50000,
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
	weapon.Icon = Material("lvs/weapons/cross.png")
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
		pos = Vector(-95.79,-0.29,76.85),
		ang = Angle(0,180,0),
	},
}
