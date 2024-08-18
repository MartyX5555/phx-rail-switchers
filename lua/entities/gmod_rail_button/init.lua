AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SwitchStatus( ForceBool )

	local Bool             = ForceBool or self.RailActivate
	local Base             = self.RailBase
	local StraightPiece    = self.StraightPiece
	local CurvePiece       = self.CurvePiece
	local CurvePiece2      = self.CurvePiece2
	local IColor 			= Bool and Color(255,255,0) or Color(0,255,0)

	if IsValid(self.PHXIndicator) then
		self.PHXIndicator:SetColor(IColor)
	end

	if IsValid(StraightPiece) and IsValid(CurvePiece) and IsValid(CurvePiece2) then

		local SwitchAngle = self.Direction == "left" and Angle(0,1,0) or Angle(0,-1,0)

		if Bool then
			StraightPiece:SetSolid(SOLID_NONE)
			CurvePiece:SetSolid(SOLID_VPHYSICS)

			CurvePiece2:SetAngles( Base:LocalToWorldAngles( SwitchAngle ) )
		else
			StraightPiece:SetSolid(SOLID_VPHYSICS)
			CurvePiece:SetSolid(SOLID_NONE)

			CurvePiece2:SetAngles( Base:LocalToWorldAngles( Angle(0,0,0) ) )
		end

	end
end

function ENT:Initialize()

	self.RailActivate = false

	self:SetUseType( SIMPLE_USE )
	self:SetModel("models/hunter/blocks/cube1x2x05.mdl")
	self:SetMaterial("phoenix_storms/cube")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysicObj = self:GetPhysicsObject()
	if not self.PhysicObj:IsValid() then return end

	local phys = self.PhysicObj
	phys:EnableMotion(false)
	phys:SetMass(1000)

	local Indicator = ents.Create("prop_physics")
	if IsValid(Indicator) then
		Indicator:SetPos(self:GetPos() + Vector(0,0,15))
		Indicator:SetAngles(self:GetAngles())
		Indicator:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		Indicator:SetMaterial("phoenix_storms/fender_white")
		Indicator:Spawn()
		Indicator:SetParent(self)
		Indicator:SetSolid(SOLID_NONE)

		self.PHXIndicator = Indicator
	end

	self:SwitchStatus()
end

function ENT:Use()

	if not self.OnCoolDown then
		self.OnCoolDown	= true

		-- Me gustaria que la palanca no pueda volver a ser usada en 0.25 segundos de haberlo hecho.
		timer.Simple(0.25,function()
			if not IsValid(self) then return end
			self.OnCoolDown	= nil
		end)
		self.RailActivate = not self.RailActivate
		sound.Play( "buttons/lever6.wav", self:GetPos() + Vector(0,0,50), 100, 100, 1 )
		self:SwitchStatus()
	end
end
