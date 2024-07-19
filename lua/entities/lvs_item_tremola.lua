AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName = "Tremola GPb-1"
ENT.Author = "Kalamari"
ENT.Category = "[LVS] - Foxhole"

ENT.Spawnable		= true
ENT.AdminOnly		= true

if CLIENT then return end -- do not do this logic on the client
ENT.ExplodeDelay = 4

if SERVER then
	function ENT:SetDamage( num ) self._dmg = num end
	function ENT:SetRadius( num ) self._radius = num end
	function ENT:SetAttacker( ent ) self._attacker = ent end

	function ENT:GetAttacker() return self._attacker or NULL end
	function ENT:GetDamage() return (self._dmg or 400) end
	function ENT:GetRadius() return (self._radius or 250) end

	function ENT:SpawnFunction( ply, tr, ClassName )
		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 5 )
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function ENT:Initialize()	
		self:SetModel( "models/proj_tremola.mdl" )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

		self.TrailEntity = util.SpriteTrail( self, 0, Color(120,120,120,120), false, 5, 40, 0.2, 1 / ( 15 + 1 ) * 0.5, "trails/smoke" )

		self.CreateTime = CurTime()
	end

	function ENT:Think()
		self:NextThink( CurTime() )

		if CurTime() - self.CreateTime >= self.ExplodeDelay then
			self:Detonate()
		end

		return true
	end

	function ENT:Detonate()
		if self.IsExploded then return end

		self.IsExploded = true

		local Pos = self:GetPos()

		local effectdata = EffectData()
		effectdata:SetOrigin( Pos )

		if self:WaterLevel() >= 2 then
			util.Effect( "WaterSurfaceExplosion", effectdata, true, true )
		else
			util.Effect( "lvs_defence_explosion", effectdata )
		end

		local dmginfo = DamageInfo()
		dmginfo:SetDamage( self:GetDamage() )
		dmginfo:SetAttacker( IsValid( self:GetAttacker() ) and self:GetAttacker() or self )
		dmginfo:SetDamageType( DMG_DIRECT )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamagePosition( Pos )

		util.BlastDamageInfo( dmginfo, Pos, self:GetRadius() )

		self:Remove()
	end

	function ENT:PhysicsCollide( data, physobj )
		self.Active = true

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
else
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:Think()
		return false
	end

	function ENT:OnRemove()
	end
end