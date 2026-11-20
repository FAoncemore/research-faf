#****************************************************************************
#**
#**  File     :  /cdimage/units/OPC2002/OPC2002_script.lua
#**  Author(s):  Greg R.
#**
#**  Summary  :  Tech for OpC2
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local AConstructionUnit = import('/lua/aeonunits.lua').AConstructionUnit
patrolDist = 60

BaseHelper = Class(AConstructionUnit) {
    
    OnStopBeingBuilt = function(self, builder, layer)
        AConstructionUnit.OnStopBeingBuilt(self, builder, layer)
        #B04 = parent, B03 = ball, B01/2 = rings
        #CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
        self.Trash:Add(CreateRotator(self, 'Shell01', 'x', nil, 0, 60, 40 + Random(0, 20) * self:GetRandomDir()))
        #self.Trash:Add(CreateRotator(self, 'Shell01', 'y', nil, 0, 5, 20 + Random(0, 20) * self:GetRandomDir()))
        self.Trash:Add(CreateRotator(self, 'Shell01', 'z', nil, 0, 60, 80 + Random(0, 20) * self:GetRandomDir()))

        self.Trash:Add(CreateRotator(self, 'Shell02', 'x', nil, 0, 60, 120 + Random(0, 20) * self:GetRandomDir()))
        self.Trash:Add(CreateRotator(self, 'Shell02', 'y', nil, 0, 60, 40 + Random(0, 20) * self:GetRandomDir()))
        #self.Trash:Add(CreateRotator(self, 'Shell02', 'z', nil, 0, 25, 80 + Random(0, 20) * self:GetRandomDir()))

        #self.Trash:Add(CreateRotator(self, 'Orbs', 'x', nil, 0, 15, 80 + Random(0, 20) * self:GetRandomDir()))
        self.Trash:Add(CreateRotator(self, 'Orbs', 'y', nil, 0, 15, 80 + Random(0, 5) * self:GetRandomDir()))
        #self.Trash:Add(CreateRotator(self, 'Orbs', 'z', nil, 0, 15, 0 + Random(0, 20) * self:GetRandomDir()))
		self:SetCanTakeDamage(false)
        self:SetCapturable(false)
        self:SetReclaimable(false)
		self:ForkThread(self.DistanceHeartbeat)
        self:ForkThread(self.Patrolplatform)
		self:ForkThread(self.ReclaimThread)
    end,

    GetRandomDir = function(self)
        local num = Random(0, 2)
        if num > 1 then
            return 1
        end
        return -1
    end,
   
	--Mithy: Extra checks now done within patrolplatform
    OnMotionHorzEventChange = function(self, new, old)
        if new == 'Stopped' then
            self:ForkThread(self.Patrolplatform)
        end
        AConstructionUnit.OnMotionHorzEventChange(self, new, old)
    end,

    --Mithy: Added range heartbeat
    DistanceHeartbeat = function(self)
        self.CapTable = {
            'RULEUCC_Guard',
            'RULEUCC_Move',
            'RULEUCC_Patrol',
            'RULEUCC_Stop',
        }
		self.MoveToBase = false
        while self and not self:IsDead() do
            local dronePos = self:GetPosition()
			local x, z = self:GetAIBrain():GetRealStartLocation()
			local basePos = {x, 0, z}
			local baseDist = VDist2(dronePos[1], dronePos[3], basePos[1], basePos[3])
			if baseDist >= patrolDist + 20 and self.MoveToBase == false then
				self.MoveToBase = true
                --Increase return speed
                self:SetSpeedMult(3.0)
                self:SetAccMult(3.0)
                IssueClearCommands({self})
                IssueMove({self}, basePos)
                --Disable command caps
                for k, cap in self.CapTable do
                    self:RemoveCommandCap(cap)
                end
            elseif baseDist <= patrolDist + 10 and self.MoveToBase == true then
                self.MoveToBase = false
                --Restore speed
                self:SetSpeedMult(1.0)
                self:SetAccMult(1.0)
                --Re-enable command caps
                self:RestoreCommandCaps()
                --This will auto-queue a patrol
                IssueStop({self})
            else
                --If we're idle and our movement check somehow failed, re-queue patrol
                if self:IsIdleState() then
                    self:ForkThread(self.Patrolplatform)
                end
            end
            WaitSeconds(1)
        end
    end,

    Patrolplatform = function(self)
        --Mithy: Now checks idle state, so drones can hover in place without being immediately told to patrol (often interrupting user orders)
        if not self:IsDead() and self:IsIdleState() then
            ### Gets the current position of the main base
            local x, z = self:GetAIBrain():GetRealStartLocation()
			local elevation = 5
			location = {x, elevation, z}

            ###Repair drone patrol area if not currently building
            --Mithy: Now a larger-area octagon instead of a small square
            IssueClearCommands({self})
            local patroltable = {
	            {location[1]+patrolDist, location[2], location[3]-patrolDist*0.4},
	            {location[1]+patrolDist, location[2], location[3]+patrolDist*0.4},
	            {location[1]+patrolDist*0.4, location[2], location[3]+patrolDist},
	            {location[1]-patrolDist*0.4, location[2], location[3]+patrolDist},
	            {location[1]-patrolDist, location[2], location[3]+patrolDist*0.4},
	            {location[1]-patrolDist, location[2], location[3]-patrolDist*0.4},
	            {location[1]-patrolDist*0.4, location[2], location[3]-patrolDist},
	            {location[1]+patrolDist*0.4, location[2], location[3]-patrolDist},
	        }
            --Randomize drone's patrol startpoint
            local ppoint = math.random(1, 8)
            local pointsleft = 8
            while pointsleft > 0 do
            	IssuePatrol({self}, patroltable[ppoint])
            	if ppoint < 8 then
            		ppoint = ppoint + 1
            	else
            		ppoint = 1
            	end
            	pointsleft = pointsleft - 1
            end
       end
    end,
	
	ReclaimThread = function(self) 
        local aiBrain = self:GetAIBrain()
        while true do
            local massRatio = aiBrain:GetEconomyStoredRatio('MASS')
            local energyRatio = aiBrain:GetEconomyStoredRatio('ENERGY')	       
                if massRatio > 0.9 and self:IsUnitState('Reclaiming') then
                    IssueClearCommands({self})
                elseif massRatio < 0.3 or energyRatio < 0.3 then
                    if self:IsUnitState('Repairing') then
                        IssueClearCommands({self})
                    end
               end
            WaitSeconds(2)
        end
    end,
	
}

TypeClass = BaseHelper