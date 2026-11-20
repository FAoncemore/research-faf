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

URA0007 = Class(CAirUnit) {
    OnStopBeingBuilt = function(self, builder, layer)
        CAirUnit.OnStopBeingBuilt(self, builder, layer)
		self:HideBone(0, true)
        self:SetCanTakeDamage(false)
        self:SetCapturable(false)
        self:SetReclaimable(false)
		self:ForkThread(self.LifeSpan)
		self:ForkThread(self.Elevation)
    end,
	
    Elevation = function(self)
        for i = 1, 10 do
		    self:SetElevation(i+0.5)
			WaitSeconds(1)
		end
    end,

    LifeSpan = function(self)
        WaitSeconds(Random(2,6))
		self:Destroy()
    end,

}
TypeClass = URA0007