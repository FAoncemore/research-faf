#****************************************************************************
#**
#**  File     :  /cdimage/units/URA0001/URA0001_script.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  Cybran Builder bot units
#**
#**  Copyright ?2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local CRadarJammerUnit = import('/lua/cybranunits.lua').CRadarJammerUnit
local CAirUnit = import('/lua/cybranunits.lua').CAirUnit

URA0009 = Class(CRadarJammerUnit) {

    OnStopBeingBuilt = function(self, builder, layer)
        CRadarJammerUnit.OnStopBeingBuilt(self, builder, layer)
		self:HideBone(0, true)
		#survive even from nuke
        self:SetCanTakeDamage(false)
        self:SetCapturable(false)
        self:SetReclaimable(false)
		self:ForkThread(self.LifeSpan)
    end,
	
    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,
	
    OnKilled = function(self, instigator, type, overkillRatio)
        CRadarJammerUnit.OnKilled(self, instigator, type, overkillRatio)
        IssueClearCommands(self)
        if not self.Parent:IsDead() then
		    self.Parent:NotifyOfFieldRadarDroneDeath(self.Drone)
            table.removeByValue(self.Parent.FieldRadarDroneTable, self)
            self.Parent = nil
        end
    end,
	
    LifeSpan = function(self)
        WaitSeconds(120)
		self:Destroy()
    end,
}
TypeClass = URA0009