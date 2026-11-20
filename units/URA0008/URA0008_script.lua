#****************************************************************************
#**
#**  File     :  /cdimage/units/URA0001/URA0001_script.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  Cybran Builder bot units
#**
#**  Copyright ?2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local CAirUnit = import('/lua/cybranunits.lua').CAirUnit
local EffectUtil = import('/lua/EffectUtilities.lua')
local patrolRange

URA0008 = Class(CAirUnit) {
    OnStopBeingBuilt = function(self, builder, layer)
        CAirUnit.OnStopBeingBuilt(self, builder, layer)
		self:HideBone(0, true)
        self:SetCanTakeDamage(false)
        self:SetCapturable(false)
        self:SetReclaimable(false)
        self:ForkThread(self.Patrolplatform)  
		self:ForkThread(self.DistanceHeartbeat)		
		patrolRange = self:GetBlueprint().Intel.VisionRadius
    end,

     OnMotionHorzEventChange = function(self, new, old)
        if new == 'Stopped' then
            self:ForkThread(self.Patrolplatform)
        end
        CAirUnit.OnMotionHorzEventChange(self, new, old)
    end,

    #thanks to Mithy --Mithy: Added range heartbeat
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
            if baseDist >= patrolRange + 20 and self.MoveToBase == false then
                self.MoveToBase = true
                self:SetSpeedMult(3.0)
                self:SetAccMult(3.0)
                IssueClearCommands({self})
                IssueMove({self}, basePos)
                for k, cap in self.CapTable do
                    self:RemoveCommandCap(cap)
                end
            elseif baseDist <= patrolRange + 10 and self.MoveToBase == true then
                self.MoveToBase = false
                self:SetSpeedMult(1.0)
				self:SetAccMult(1.0)
                self:RestoreCommandCaps()
                IssueStop({self})
            else
                if self:IsIdleState() then
                    self:ForkThread(self.Patrolplatform)
                end
            end
            WaitSeconds(5)
        end
    end,

    #thanks to Mithy
    Patrolplatform = function(self)
        if not self:IsDead() and self:IsIdleState() then
            local x, z = self:GetAIBrain():GetRealStartLocation()
			local elevation = 25
			location = {x, elevation, z}
			
            IssueClearCommands({self})
            local patroltable = {
	            {location[1]+patrolRange, location[2], location[3]-patrolRange*0.4},
	            {location[1]+patrolRange, location[2], location[3]+patrolRange*0.4},
	            {location[1]+patrolRange*0.4, location[2], location[3]+patrolRange},
	            {location[1]-patrolRange*0.4, location[2], location[3]+patrolRange},
	            {location[1]-patrolRange, location[2], location[3]+patrolRange*0.4},
	            {location[1]-patrolRange, location[2], location[3]-patrolRange*0.4},
	            {location[1]-patrolRange*0.4, location[2], location[3]-patrolRange},
	            {location[1]+patrolRange*0.4, location[2], location[3]-patrolRange},
	        }
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
}
TypeClass = URA0008