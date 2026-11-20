#****************************************************************************
#**
#**  File     :  /units/XSB5102/XSB5102_script.lua
#**
#**  Summary  :  Transport Beacon Unit
#**
#**  Copyright ?2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local TQuantumGateUnit = import('/lua/terranunits.lua').TQuantumGateUnit

portal_receiver = Class(TQuantumGateUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        TQuantumGateUnit.OnStopBeingBuilt(self,builder,layer)
		self.Sync.Abilities = self:GetBlueprint().Abilities
		self.Sync.Abilities.TargetLocation.Active = true
		self:ForkThread(self.MoveToLocation)
		self.rallypoint = {}
    end,
	
    # sorted units
    MoveToLocation = function(self)  
		local cat = categories.LAND * categories.MOBILE - categories.COMMAND - categories.EXPERIMENTAL - categories.UNTARGETABLE
		while not self:IsDead() do
			local pos = self:GetPosition()
			#self sizeX = 8, sizeZ = 6
			local arrivals = GetUnitsInRect(pos[1]-4, pos[3]-3, pos[1]+4, pos[3]+3)
			if arrivals then
				for k, v in arrivals do
					if EntityCategoryContains(cat, v) then
					    if self.rallypoint.pos then
					        IssueMove({v}, self.rallypoint.pos)
						end
					end
				end
			end
			#keep 1s here, otherwise some units will head back to TX
			WaitSeconds(1)
		end
    end,
	
    # rallypoint setup
    OnTargetLocation = function(self, location)  
		self.rallypoint.pos = location
    end,
}

TypeClass = portal_receiver