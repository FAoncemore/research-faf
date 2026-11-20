local Buff = import('/lua/sim/Buff.lua')
local ObjectiveArrow = import('/lua/objectiveArrow.lua').ObjectiveArrow
local Objectives = import('/lua/ScenarioFramework.lua').Objectives

#field regen
CreateFieldRegen = function(data)		
    SetIgnoreArmyUnitCap(GetFocusArmy(), true)
    if not Buffs['RegenField'] then
	    BuffBlueprint {
		    Name = 'RegenField',
			DisplayName = 'RegenField',
			BuffType = 'Aura',
			Stacks = 'REPLACE',
			Duration = -1,
			Affects = {
			    #Steam uses RegenPercent
			    Regen = {
					Add = 0,
					Mult = 0.03,
					Ceil = 200,
				},
			},
		}
	end
	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
	ForkThread(RegenBuffThread, data)
end
	
RegenBuffThread = function(data)
    # one time field repair droping
	local units = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint(ArmyBrains[GetFocusArmy()], categories.ALLUNITS, data.pos, data.radius)
	for _,unit in units do
	    if unit:GetFractionComplete() == 1 and not Buff.HasBuff(unit, 'RegenField') then
		    Buff.ApplyBuff(unit, 'RegenField')
			ForkThread(UnitHasRepairFeatures, unit)			
		end
	end
end

UnitHasRepairFeatures = function(unit)
    while not unit:IsDead() do
	    if unit:GetHealthPercent() < 1 then
		    local position = unit:GetPosition(0)
			local pingSpec = {Owner = unit, Location = position}
			local ping = import('/lua/sim/Entity.lua').Entity(pingSpec)
			Warp(ping, unit:GetPosition(0))
			ping:AttachBoneTo( -1, unit, 0 )
			ping:SetMesh('/mods/Research FAF/units/repair/Regen_Repair_mesh')
			ping:SetVizToFocusPlayer('Always')
			ping:SetVizToEnemies('Always')
			ping:SetVizToAllies('Always')
			ping:SetVizToNeutrals('Always')
			local RepairAnimThread = ForkThread(AnimatePingMesh, ping)	
			ForkThread(function() 
			    WaitSeconds(2)
				KillThread(RepairAnimThread)
				ping:Destroy()
			end)
		end
		WaitSeconds(2)
	end
end

#ping animating
AnimatePingMesh = function(entity)
    local time = 0
	local ascending = true
	while entity do
	    entity:SetScale(MATH_Lerp(math.sin(time), -.9, 0.9, .05, .1))
		time = time + .3
		WaitSeconds(.001)
	end
end

#field support units
CreateFieldSupports = function(data)
    SetIgnoreArmyUnitCap(GetFocusArmy(), true)
    CreateUnit(data.id, GetFocusArmy(), data.pos[1], data.pos[2], data.pos[3], 0,0,0,0, 'Land')
	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
end

#mart selected units
MarkSelectedUnits = function(data)
    for _, unitId in data.id do
	    local unit = GetEntityById(unitId)
		if unit then
		    if not unit.Marked then
			    unit.Marked = true
				ObjectiveArrow{AttachTo = unit}
			end
			unit:SetStrategicUnderlay('')
			unit:SetStrategicUnderlay(data.tag)
		end
	end
end