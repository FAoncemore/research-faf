local Buff = import('/lua/sim/Buff.lua')
local dispenser = nil

DFVZ = false

#hero health buff toggle
HeroHealthBuff = function(data)
    local HeroHealthBuff = BuffBlueprint {
	    Name = 'HeroHealthBuff',
		DisplayName = 'HeroHealthBuff',
		BuffType = 'Health',
		Stacks = 'REPLACE',
		Duration = -1,
		Affects = { 
		    Health = {
			    Add = 0,
				Mult = data,
			}, 
			MaxHealth = {
			    Add = 0,
				Mult = data,
			},
		},
	}
	for k,v in ArmyBrains[GetFocusArmy()]:GetListOfUnits(categories.FPSFAHERO, false) do
		Buff.ApplyBuff(v, 'HeroHealthBuff')
	end
end

#hero shield buff
HeroShieldBuff = function(data)
    local shieldSpec = {
	    ImpactEffects = 'UEFShieldHit01',
		OwnerShieldMesh = '/units/uel0001/UEL0001_PhaseShield_mesh',
		PersonalShield = true,
		RegenAssistMult = 10,
		ShieldEnergyDrainRechargeTime = 5,
		ShieldMaxHealth = 10000*data,
		ShieldRechargeTime = 170,
		ShieldRegenRate = 50,
		ShieldRegenStartTime = 1,
		ShieldSize = 3,
		ShieldVerticalOffset = 0,
		StartOn = true,
	}
	for k,v in ArmyBrains[GetFocusArmy()]:GetListOfUnits(categories.FPSFAHERO, false) do
	    v:CreateShield(shieldSpec)
	end
end

#field vz drone
DefenderVZ = function()
	for k,v in ArmyBrains[GetFocusArmy()]:GetListOfUnits(categories.FPSFAHERO, false) do
        DFVZ = import('/lua/sim/Entity.lua').Entity({Owner = v})
		DFVZ:InitIntel(v:GetArmy(),'Vision', 50)
		DFVZ:EnableIntel('Vision')
        DFVZ:AttachBoneTo(-1, v, 'Head')
		DFVZ:SetParentOffset({0,0,40})
		
		v:InitIntel(v:GetArmy(),'Omni', 50)
		v:EnableIntel('Omni')
		v:InitIntel(v:GetArmy(),'Radar', 100)
		v:EnableIntel('Radar')
		ForkThread(ShieldDispenser, v)	
	end
end

ShieldDispenser = function(self)
    while not self:IsDead() do
	    local enemy = self:GetAIBrain():GetUnitsAroundPoint(categories.ALLUNITS, self:GetPosition(), 40, 'Enemy')
		if table.getn(enemy) > 0 then
		    if not dispenser then
			    dispenser = import('/lua/sim/Entity.lua').Entity({Owner = self})
				dispenser:AttachBoneTo(-1, self, 'Head')
				dispenser:SetParentOffset({0,-3,2})
				local pos = dispenser:GetPosition()
				local bubble = CreateUnit('URA0006', self:GetArmy(), pos[1], pos[2], pos[3], 0,0,0,0, 'Air')
				bubble:AttachBoneTo(-1, dispenser, -1)
			end
		elseif table.getn(enemy) == 0 then
		    if dispenser then 
			    dispenser:Destroy()
				dispenser = nil
			end
		end
		WaitSeconds(1)
	end
end

#hero speed
HeroSpeedBuff = function(data)
    local HeroSpeedBuff = BuffBlueprint {
	    Name = 'HeroSpeedBuff',
		DisplayName = 'HeroSpeedBuff',
		BuffType = 'Speed',
		Stacks = 'REPLACE',
		Duration = -1,
		Affects = { 
		    MoveMult = {
			    Add = 0,
				Mult = data,
			},   
		},
	}
	for k,v in ArmyBrains[GetFocusArmy()]:GetListOfUnits(categories.FPSFAHERO, false) do
		Buff.ApplyBuff(v, 'HeroSpeedBuff')
	end
end

