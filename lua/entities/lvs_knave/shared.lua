ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "O'Brien V.190 Knave"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's Foxhole Vehicles"
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Tanks"
ENT.VehicleSubCategory = "Foxhole"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/car_knave.mdl"

ENT.GibModels = {
	"models/freeman_wheel.mdl",
	"models/freeman_wheel.mdl",
	"models/freeman_wheel.mdl",
	"models/freeman_wheel.mdl",
}

ENT.AITEAM = 1

ENT.MaxHealth = 1250

ENT.SpawnNormalOffset = 40

//damage system
ENT.DSArmorIgnoreForce = 1200
ENT.CannonArmorPenetration = 3900

ENT.MaxVelocity = 400

ENT.EngineCurve = 0.2
ENT.EngineTorque = 250

ENT.TransGears = 3
ENT.TransGearsReverse = 3

ENT.FastSteerAngleClamp = 15
ENT.FastSteerDeactivationDriftAngle = 12

ENT.PhysicsWeightScale = 2.5
ENT.PhysicsDampingForward = true
ENT.PhysicsDampingReverse = true

ENT.lvsShowInSpawner = true

ENT.WheelBrakeAutoLockup = true
ENT.WheelBrakeLockupRPM = 15

ENT.EngineSounds = {
	{
		sound = "vehicles/ACIdle.wav",
		Volume = 0.66,
		Pitch = 70,
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
				pos = Vector(109.12,-0.19,35.82),
				colorB = 200,
				colorA = 150,
			},
		},
		ProjectedTextures = {
			[1] = {
				pos = Vector(109.12,-0.19,35.82),
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
	self:AddDT( "Bool", "AlternateBarrel")
end

//grenade launchers
function ENT:InitWeapons()
	local COLOR_WHITE = Color(255,255,255,255)

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/bomb.png")
	weapon.Ammo = 24
	weapon.Delay = 0.75
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0.5
	weapon.StartAttack = function( ent )
	
		if self:GetAI() then return end

		self:MakeProjectile()
	end
	weapon.FinishAttack = function( ent )
		if self:GetAI() then return end

		self:FireProjectile()
		self:SetAlternateBarrel(not self:GetAlternateBarrel())
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
		pos = Vector(-102.59,13.27,30.76),
		ang = Angle(0,180,0),
	},
	{
		pos = Vector(-102.59,-13.27,30.76),
		ang = Angle(0,180,0),
	},
}