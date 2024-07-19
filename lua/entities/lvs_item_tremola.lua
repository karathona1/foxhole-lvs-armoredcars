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
end