ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "O'Brien V.113 Gravekeeper"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's Foxhole Vehicles"
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Tanks"
ENT.VehicleSubCategory = "Foxhole"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/car_gravekeeper.mdl"
ENT.MDL_DESTROYED = "models/car_obrien_destroyed.mdl"

ENT.GibModels = {
	"models/wheel_obrien.mdl",
	"models/wheel_obrien.mdl",
	"models/wheel_obrien.mdl",
	"models/wheel_obrien.mdl",
}


ENT.AITEAM = 1

ENT.MaxHealth = 900

ENT.SpawnNormalOffset = 40

//damage system
ENT.DSArmorIgnoreForce = 1200
ENT.CannonArmorPenetration = 3900

ENT.MaxVelocity = 700

ENT.EngineCurve = 0.2
ENT.EngineTorque = 200

ENT.TransGears = 3
ENT.TransGearsReverse = 1

ENT.FastSteerAngleClamp = 15
ENT.FastSteerDeactivationDriftAngle = 12

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
		Pitch = 100,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "vehicles/ACDrive.wav",
		Volume = 1.33,
		Pitch = 100,
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
	weapon.Icon = Material("lvs/weapons/bomb.png")
	weapon.Ammo = 8
	weapon.Delay = 4.5
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0.2
		weapon.StartAttack = function( ent )
	
			if self:GetAI() then return end
	
			self:MakeProjectile()
		end
		weapon.FinishAttack = function( ent )
			if self:GetAI() then return end
	
			self:FireProjectile()
		end
		weapon.Attack = function( ent )
			if not self:GetAI() then return end
	
			self:MakeProjectile()
			self:FireProjectile()
		end
		weapon.HudPaint = function( ent, X, Y, ply )
			local Pos2D = ent:GetEyeTrace().HitPos:ToScreen()
	
			ent:LVSPaintHitMarker( Pos2D )
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