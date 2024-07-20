AddCSLuaFile()

ENT.Base = "lvs_bomb"

ENT.PrintName = "Tremola GPb-1"
ENT.Author = "Kalamari"
ENT.Category = "[LVS] - Foxhole"

ENT.Spawnable		= false

-- used in lvs_bomb to determine the explosion effect.
ENT.ExplosionEffect = "lvs_explosion_small"

-- Our defined delay
ENT.ExplodeDelay = 4

if SERVER then

	function ENT:Initialize()
		self:SetModel( "models/proj_tremola.mdl" )

		self.TrailEntity = util.SpriteTrail( self, 0, Color(120,120,120,120), false, 5, 40, 0.2, 1 / ( 15 + 1 ) * 0.5, "trails/smoke" )
	end

	function ENT:Think()
		local T = CurTime()
		self:NextThink( T )

		self:UpdateTrajectory()

		-- self.SpawnTime is set in lvs_bomb when the bomb is actually fired
		if not self.SpawnTime then return true end
		if (self.SpawnTime + self.ExplodeDelay) < T then
			self:Detonate()
		end
		return true
	end

	-- This override's lvs_bomb's StartTouch function so it does not detonate on impact
	function ENT:StartTouch( entity )
	end

	-- This override's lvs_bomb's PhysicsCollide function so it does not detonate on impact
	-- Also plays grenade tink sounds
	function ENT:PhysicsCollide( data, physobj )
		if not self.IsEnabled then return end
		if istable( self._FilterEnts ) and self._FilterEnts[ data.HitEntity ] then return end

		-- The first time collision happens, disable the custom motion controller and enable gravity
		if not self.Collided then
			self.Collided = true
			-- Must be in a timer, MotionController cannot be stopped during physics collision
			timer.Simple(0.01, function()
				self:StopMotionController()
				self:GetPhysicsObject():EnableGravity(true)
			end)
		end

		if data.Speed > 60 and data.DeltaTime > 0.2 then
			local VelDif = data.OurOldVelocity:Length() - data.OurNewVelocity:Length()

			if VelDif > 200 then
				self:EmitSound( "Grenade.ImpactHard" )
			else
				self:EmitSound( "Grenade.ImpactSoft" )
			end

			physobj:SetVelocity( data.OurOldVelocity * 0.5 )
		end
	end

	-- This is the same code as in lvs_bomb
	-- We override it in order to change the projectile mass
	function ENT:Enable()
		if self.IsEnabled then return end
		local Parent = self:GetParent()
		if IsValid(Parent) then
			self:SetOwner(Parent)
			self:SetParent(NULL)
		end

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:PhysWake()
		timer.Simple(0.5, function()
			if not IsValid(self) then return end
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
		end)

		self.IsEnabled = true
		local pObj = self:GetPhysicsObject()
		if not IsValid(pObj) then
			self:Remove()
			print("LVS: missing model. Missile terminated.")
			return
		end

		pObj:SetMass(50) -- default was 500
		pObj:EnableGravity(false)
		pObj:EnableMotion(true)
		pObj:EnableDrag(false)
		pObj:SetVelocityInstantaneous(self:GetSpeed())

		-- Makes the entity call StartTouch, Touch and EndTouch
		self:SetTrigger(true)

		-- Makes the entity call PhysicsSimulate to do custom physics behavior
		-- Probably used to make the bomb more accurately follow the trajectory
		self:StartMotionController()

		self:PhysWake()
		self.SpawnTime = CurTime()
		self:SetActive(true)
	end
end