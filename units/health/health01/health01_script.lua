#****************************************************************************
#**
#**  File     :  /units/XSB5102/XSB5102_script.lua
#**
#**  Summary  :  Transport Beacon Unit
#**
#**  Copyright ?2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local STransportBeaconUnit = import('/lua/seraphimunits.lua').STransportBeaconUnit

health01 = Class(STransportBeaconUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        STransportBeaconUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread(self.HealthBox)
    end,

    #buff health
    HealthBox = function(self)   
        local x,y,z = unpack(self:GetPosition())
        local dist = 5
        local selfStorage = self:GetBlueprint().Defense.MaxHealthStorage or 10000
        local oldRem = selfStorage
        while true do
            local newRem = oldRem
            local units = GetUnitsInRect(x-dist, z-dist, x+dist, z+dist)
            for k,v in units do
                if EntityCategoryContains(categories.FPSFAHERO, v) then
                    local maxHealth = v:GetMaxHealth()
                    local curHealth = v:GetHealth()
                    local reqHealth = maxHealth - curHealth
                    if reqHealth > 0 then
                        if newRem <= reqHealth then
                            giveHealth = newRem
                        elseif newRem > reqHealth then
                            giveHealth = reqHealth
                        end
                        v:AdjustHealth(v, giveHealth) 
                        oldRem = oldRem - giveHealth
                        local id = self:GetEntityId()
                        FloatingEntityText(id, math.floor(oldRem))
                        if oldRem < 1 then
                            self:Destroy()
                        end
                    end
                end
            end
            WaitSeconds(.5)
        end
    end,

}

TypeClass = health01