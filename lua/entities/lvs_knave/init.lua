AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_turret.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_optics.lua")
AddCSLuaFile("cl_tankview.lua")
include("shared.lua")
include("sh_turret.lua")

function ENT:OnSpawn(PObj)
	local DriverSeat = self:AddDriverSeat(Vector(20, 0, 20), Angle(0, -90, 0))
	DriverSeat.HidePlayer = true
	local GunnerSeat = self:AddPassengerSeat(Vector(-40, 0, 70), Angle(0, -90, 0))
	GunnerSeat.HidePlayer = false
	self:SetGunnerSeat(GunnerSeat)
	local ID = self:LookupAttachment("muzzle_gunl")
	local Muzzle = self:GetAttachment(ID)
	self.SNDTurret = self:AddSoundEmitter(self:WorldToLocal(Muzzle.Pos), "vehicles/GrenadeLauncherCShot01.wav", "vehicles/GrenadeLauncherCShot01.wav")
	self.SNDTurret:SetSoundLevel(100)
	self.SNDTurret:SetParent(self, ID)
	local ID2 = self:LookupAttachment("muzzle_gunr")
	local Muzzle2 = self:GetAttachment(ID2)
	self.SNDTurret = self:AddSoundEmitter(self:WorldToLocal(Muzzle2.Pos), "vehicles/GrenadeLauncherCShot01.wav", "vehicles/GrenadeLauncherCShot01.wav")
	self.SNDTurret:SetSoundLevel(100)
	self.SNDTurret:SetParent(self, ID2)
	self:AddEngine(Vector(-72, 0, 72), Angle(0, -90, 0))
	self:AddFuelTank(Vector(-82, 0, 71), Angle(0, 0, 0), 600, LVS.FUELTYPE_PETROL)
	-- example:
	local WheelModel = "models/freeman_wheel.mdl"

	local WheelFrontLeft = self:AddWheel({
		pos = Vector(65, 36, 25),
		mdl = WheelModel,
		mdl_ang = Angle(0, 0, 0)
	})

	local WheelFrontRight = self:AddWheel({
		pos = Vector(65, -36, 25),
		mdl = WheelModel,
		mdl_ang = Angle(0, 180, 0)
	})

	local WheelRearLeft = self:AddWheel({
		pos = Vector(-53, 36, 23),
		mdl = WheelModel,
		mdl_ang = Angle(0, 0, 0)
	})

	local WheelRearRight = self:AddWheel({
		pos = Vector(-53, -36, 23),
		mdl = WheelModel,
		mdl_ang = Angle(0, 180, 0)
	})

	local SuspensionSettings = {
		Height = 25,
		MaxTravel = 8,
		ControlArmLength = 25,
		SpringConstant = 20000,
		SpringDamping = 2000,
		SpringRelativeDamping = 2000,
	}

	local FrontAxle = self:DefineAxle({
		Axle = {
			ForwardAngle = Angle(0, 0, 0),
			SteerType = LVS.WHEEL_STEER_FRONT,
			SteerAngle = 15,
			TorqueFactor = 0.3,
			BrakeFactor = 1,
		},
		Wheels = {WheelFrontLeft, WheelFrontRight},
		Suspension = SuspensionSettings,
	})

	local RearAxle = self:DefineAxle({
		Axle = {
			ForwardAngle = Angle(0, 0, 0),
			SteerType = LVS.WHEEL_STEER_NONE,
			TorqueFactor = 0.7,
			BrakeFactor = 1,
			UseHandbrake = true,
		},
		Wheels = {WheelRearLeft, WheelRearRight},
		Suspension = SuspensionSettings,
	})

	--FRONT ARMOR
	self:AddArmor(Vector(70, 0, 35), Angle(0, 0, 0), Vector(-55, -25, -15), Vector(25, 25, 35), 600, self.FrontArmor)
	--LEFT ARMOR
	self:AddArmor(Vector(0, 35, 35), Angle(0, 0, 0), Vector(-70, -5, -15), Vector(40, 5, 50), 400, self.SideArmor)
	--Right ARMOR
	self:AddArmor(Vector(0, -35, 35), Angle(0, 0, 0), Vector(-70, -5, -15), Vector(40, 5, 50), 400, self.SideArmor)
	--BACK ARMOR
	self:AddArmor(Vector(-75, 0, 35), Angle(0, 0, 0), Vector(-5, -35, -15), Vector(5, 35, 50), 300, self.BackArmor)
	--VISOR ARMOR
	self:AddArmor(Vector(30, 0, 75), Angle(0, 0, 0), Vector(-10, -25, -10), Vector(10, 25, 10), 400, self.FrontArmor)
	--TURRET ARMOR
	local TurretArmor = self:AddArmor(Vector(-45, 0, 85), Angle(0, 0, 0), Vector(-35, -35, 0), Vector(35, 35, 30), 1000, self.TurretArmor)

	TurretArmor.OnDestroyed = function(ent, dmginfo)
		if not IsValid(self) then return end
		self:SetTurretDestroyed(true)
	end

	TurretArmor.OnRepaired = function(ent)
		if not IsValid(self) then return end
		self:SetTurretDestroyed(false)
	end

	TurretArmor:SetLabel("Turret")
	self:SetTurretArmor(TurretArmor)
end

function ENT:MakeProjectile()
	local ID = self:GetAlternateBarrel() and self:LookupAttachment("muzzle_gunr") or self:LookupAttachment("muzzle_gunl")
	local Muzzle = self:GetAttachment(ID)

	if not Muzzle then return end
	local Driver = self:GetDriver()
	local projectile = ents.Create("lvs_item_tremola")

	local ang = Muzzle.Ang
	projectile:SetPos(Muzzle.Pos)
	ang:RotateAroundAxis(ang:Right(), 180)
	projectile:SetAngles(ang)
	projectile:SetParent(self, ID)
	projectile:Spawn()
	projectile:Activate()
	projectile:SetModel("models/proj_tremola.mdl")
	projectile:SetAttacker(IsValid(Driver) and Driver or self)
	projectile:SetEntityFilter(self:GetCrosshairFilterEnts())
	projectile:SetSpeed(Muzzle.Ang:Forward() * 1500)
	projectile:SetRadius(200)
	projectile:SetDamage(200)

	projectile.UpdateTrajectory = function(bomb)
		bomb:SetSpeed(bomb:GetForward() * 1500)
	end

	if projectile.SetMaskSolid then
		projectile:SetMaskSolid(true)
	end

	self._ProjectileEntity = projectile
end

function ENT:FireProjectile()
	local ID = self:GetAlternateBarrel() and self:LookupAttachment("muzzle_gunr") or self:LookupAttachment("muzzle_gunl")
	local Muzzle = self:GetAttachment(ID)
	if not Muzzle or not IsValid(self._ProjectileEntity) then return end

	self._ProjectileEntity:Enable()
	self._ProjectileEntity:SetCollisionGroup(COLLISION_GROUP_NONE)

	local effectdata = EffectData()
	effectdata:SetOrigin(self._ProjectileEntity:GetPos())
	effectdata:SetEntity(self._ProjectileEntity)
	util.Effect("lvs_haubitze_trail", effectdata)

	effectdata = EffectData()
	effectdata:SetOrigin(Muzzle.Pos)
	effectdata:SetNormal(-Muzzle.Ang:Forward())
	effectdata:SetEntity(self)
	util.Effect("lvs_muzzle", effectdata)

	local PhysObj = self:GetPhysicsObject()
	if IsValid(PhysObj) then
		PhysObj:ApplyForceOffset(Muzzle.Ang:Forward() * 100000, Muzzle.Pos)
	end

	self:TakeAmmo()
	self:SetHeat(1)
	self:SetOverheated(true)
	self._ProjectileEntity = nil
	if not IsValid(self.SNDTurret) then return end
	self.SNDTurret:PlayOnce(100 + math.cos(CurTime() + self:EntIndex() * 1337) * 5 + math.Rand(-1, 1), 1)
	self:EmitSound("vehicles/GrenadeLauncherCReload.wav", 75, 100, 1, CHAN_WEAPON)
end