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

URA0006 = Class(CAirUnit) {
    OnStopBeingBuilt = function(self, builder, layer)
        CAirUnit.OnStopBeingBuilt(self, builder, layer)
		self:HideBone(0, true)
        self:SetCanTakeDamage(false)
        self:SetCapturable(false)
        self:SetReclaimable(false)
		self:ForkThread(self.ShieldDispenser)
    end,
	
    ShieldDispenser = function(self)
        while not self:IsDead() do
		    local pos = self:GetPosition()
			CreateUnit('URA0007', self:GetArmy(), pos[1], pos[2], pos[3], 0,0,0,0, 'Air')
		    WaitSeconds(3)
		end
    end,

}
TypeClass = URA0006