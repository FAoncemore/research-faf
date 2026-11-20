#****************************************************************************
#**
#**  File     :  /units/XSB5102/XSB5102_script.lua
#**
#**  Summary  :  Transport Beacon Unit
#**
#**  Copyright ?2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local TQuantumGateUnit = import('/lua/terranunits.lua').TQuantumGateUnit

portal_transmitter = Class(TQuantumGateUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        TQuantumGateUnit.OnStopBeingBuilt(self,builder,layer)
		self:ForkThread(self.StartPortal)
    end,
	
    # get guarded RX and teleport units in range to RX
    StartPortal = function(self)  
    	local dist = 12
		local cat = categories.LAND * categories.MOBILE - categories.COMMAND - categories.EXPERIMENTAL - categories.UNTARGETABLE
		while not self:IsDead() do
            local RX = self:GetGuardedUnit()
            if RX and EntityCategoryContains(categories.ResearchPORTALRX, RX) then      
			    local tPos = self:GetPosition()
				local rPos = RX:GetPosition()
				local waitingTeleport = GetUnitsInRect(tPos[1]-dist, tPos[3]-dist, tPos[1]+dist, tPos[3]+dist)
				if waitingTeleport then
				    for k, v in waitingTeleport do
					    if EntityCategoryContains(cat, v) then
						    local random = Random(-1, 1)
							Warp(v, {rPos[1]+random,rPos[2],rPos[3]+random, 0, 0, 0})
							v:PlayTeleportInEffects()
						end
						WaitSeconds(.5)
					end
				end
			end
			WaitSeconds(1)
		end
    end,
}

TypeClass = portal_transmitter