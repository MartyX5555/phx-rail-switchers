AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()



	self:SetModel("models/props_phx/trains/tracks/track_switch2.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysicObj = self:GetPhysicsObject()
	if not self.PhysicObj:IsValid() then return end

	local phys = self.PhysicObj
	phys:EnableMotion(false)
	phys:SetMass(50000)
	phys:Wake()

	local SLPos = Vector(0,0.01,-1.33)
	local SLAng = Angle(0,0,0)
	local StraightPiece = ents.Create( "prop_dynamic" )
	StraightPiece:SetSolid( SOLID_VPHYSICS )
	StraightPiece:SetMoveType( MOVETYPE_VPHYSICS  )
	StraightPiece:PhysicsInit( SOLID_VPHYSICS )
	StraightPiece:SetPos( self:LocalToWorld( SLPos ) )
	StraightPiece:SetAngles( self:LocalToWorldAngles( SLAng ) )
	StraightPiece:SetModel( "models/props_phx/trains/tracks/track_8x.mdl" )
	StraightPiece:SetNoDraw( true )
	StraightPiece:Spawn()

	self:DeleteOnRemove( StraightPiece )
	StraightPiece.PhysgunDisabled = true

	local CLPos = Vector(547.62,-7.43,0.00)
	local CLAng = Angle(0,-135,0)
	local CurvePiece = ents.Create( "prop_dynamic" )
	CurvePiece:SetSolid( SOLID_VPHYSICS )
	CurvePiece:SetMoveType( MOVETYPE_VPHYSICS  )
	CurvePiece:PhysicsInit( SOLID_VPHYSICS )
	CurvePiece:SetPos( self:LocalToWorld( CLPos ) )
	CurvePiece:SetAngles( self:LocalToWorldAngles( CLAng ) )
	CurvePiece:SetModel( "models/props_phx/trains/tracks/track_turn45.mdl" )
	CurvePiece:SetNoDraw( true )
	CurvePiece:Spawn()

	self:DeleteOnRemove( CurvePiece )
	CurvePiece.PhysgunDisabled = true

	local CLPos2 = Vector(240,-38,-1)
	local CLAng2 = Angle(0,0,0)
	local CurvePiece2 = ents.Create( "prop_dynamic" )
	CurvePiece2:SetSolid( SOLID_NONE )
	CurvePiece2:SetMoveType( MOVETYPE_VPHYSICS  )
	CurvePiece2:PhysicsInit( SOLID_VPHYSICS )
	CurvePiece2:SetPos( self:LocalToWorld( CLPos2 ) )
	CurvePiece2:SetAngles( self:LocalToWorldAngles( CLAng2 ) )
	CurvePiece2:SetModel( "models/props_phx/trains/tracks/track_switcher2.mdl" )
	CurvePiece2:Spawn()

	timer.Simple(0,function()
		if IsValid(CurvePiece2) then
			CurvePiece2:SetColor( self:GetColor() or Color(255,255,255,255) )
			CurvePiece2:SetMaterial( self:GetMaterial() or "" )
		end
	end)

	self:DeleteOnRemove( CurvePiece2 )
	CurvePiece2.PhysgunDisabled = true

	local BLPos = Vector(545,132,9)
	local BLAng = Angle(0,0,0)
	local SwitchButton = ents.Create( "gmod_rail_button" )
	SwitchButton:SetSolid( SOLID_VPHYSICS )
	SwitchButton:SetMoveType( MOVETYPE_VPHYSICS  )
	SwitchButton:PhysicsInit( SOLID_VPHYSICS )
	SwitchButton:SetPos( self:LocalToWorld( BLPos ) )
	SwitchButton:SetAngles( self:LocalToWorldAngles( BLAng ) )

	SwitchButton.PhysgunDisabled = true
	SwitchButton.RailBase 		= self
	SwitchButton.StraightPiece 	= StraightPiece
	SwitchButton.CurvePiece 	= CurvePiece
	SwitchButton.CurvePiece2 	= CurvePiece2
	SwitchButton.Direction 		= "left"

	self.AssignedButton = SwitchButton
	self.IgnoreParts = { self, StraightPiece, CurvePiece, CurvePiece2}

	SwitchButton:Spawn()
	self:DeleteOnRemove( SwitchButton )
	self.SwitchButton = SwitchButton

end

do

	--Svec(-370.04,0.01,1.48)	Cvec(-158.34,-338.09,1.48)

	local CRLPos = Vector(-370,0,1.48) --Curve Ranger Local Pos: Posicion del sensor para abrir la curva.
	local SRLPos = Vector(-158.34,-338,1.48) --Straight Ranger Local Pos: lo mismo, pero para dejarlo recto.

	function ENT:Think()

		local tr1 = {}
		tr1.start 			= self:LocalToWorld( CRLPos ) debugoverlay.Box( tr1.start, -Vector(1,1,1) * 100, Vector(1,1,1) * 100, 0.1, Color(255,0,0,25) )
		tr1.endpos 			= tr1.start + self:GetUp() * 200
		tr1.collisiongroup 	= COLLISION_GROUP_WEAPON
		tr1.ignoreworld 	= true
		tr1.filter 			= self.IgnoreParts
		local trace1 = util.TraceLine(tr1)
		if trace1.Hit then
			self.AssignedButton.RailActivate = false
			self.SwitchButton:SwitchStatus()
		end

		local tr2 = {}
		tr2.start 			= self:LocalToWorld( SRLPos ) debugoverlay.Box( tr2.start, -Vector(1,1,1) * 100, Vector(1,1,1) * 100, 0.1, Color(255,0,0,25) )
		tr2.endpos 			= tr2.start + self:GetUp() * 200
		tr2.collisiongroup 	= COLLISION_GROUP_WEAPON
		tr2.ignoreworld 	= true
		tr2.filter 			= self.IgnoreParts
		local trace2 = util.TraceLine(tr2)
		if trace2.Hit then
			self.AssignedButton.RailActivate = true
			self.SwitchButton:SwitchStatus()
		end

		self:NextThink(CurTime() + 0.1)
		return true
	end

end