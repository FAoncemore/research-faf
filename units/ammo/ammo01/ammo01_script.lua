#****************************************************************************
#**
#**  File     :  /units/XSB5102/XSB5102_script.lua
#**
#**  Summary  :  Transport Beacon Unit
#**
#**  Copyright ?2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local STransportBeaconUnit = import('/lua/seraphimunits.lua').STransportBeaconUnit

ammo01 = Class(STransportBeaconUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        STransportBeaconUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread(self.AmmoBox)
    end,

    #buff ammo
    AmmoBox = function(self)   
        local x,y,z = unpack(self:GetPosition())
        local dist = 5
        local selfStorage = self:GetBlueprint().Defense.MaxProjectileStorage or 199
        local oldRem = selfStorage
        while true do

            local newRem = oldRem
            local units = GetUnitsInRect(x-dist, z-dist, x+dist, z+dist)
			if units then
                for k,v in units do
                    if EntityCategoryContains(categories.FPSFAHERO, v) then
					    local heroStorage = v:GetBlueprint().Defense.MaxProjectileStorage or 99
                        local curAmmo = v:GetTacticalSiloAmmoCount()
                        local reqAmmo = heroStorage - curAmmo
                        if reqAmmo > 0 then
                            if newRem <= reqAmmo then
                                giveAmmo = newRem
                            elseif newRem > reqAmmo then
                                giveAmmo = reqAmmo
                            end
                            v:GiveTacticalSiloAmmo(giveAmmo)
                            oldRem = oldRem - giveAmmo
                            local id = self:GetEntityId()
                            FloatingEntityText(id, oldRem)
                            if oldRem == 0 then
                                self:Destroy()
                            end
                        end
                    end
                end
            end
            WaitSeconds(1)
        end
    end,
	
}

TypeClass = ammo01