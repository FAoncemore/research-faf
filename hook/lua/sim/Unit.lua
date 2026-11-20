#****************************************************************************
#**
#**  File     :  /lua/unit.lua
#**  Author(s):  John Comes, David Tomandl, Gordon Duclos
#**
#**  Summary  : The Unit lua module
#**
#**  Copyright ?2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local MobileShieldCat = categories.MOBILE - categories.SHIELD - categories.CONSTRUCTION - categories.ENGINEER - categories.TRANSPORTATION - categories.EXPERIMENTAL - categories.UNTARGETABLE
local BuffCat = categories.MOBILE - categories.UNTARGETABLE
local path = import('/mods/Research FAF/lua/EnhAbilityControl.lua')

local ResearchUnit = Unit
Unit = Class(ResearchUnit) {    

    OnStopBeingBuilt = function(self, builder, layer)
	    ResearchUnit.OnStopBeingBuilt(self, builder, layer)

		if self:GetAIBrain() == ArmyBrains[GetFocusArmy()] then
		    #creat shields for mobile units
		    if EntityCategoryContains(MobileShieldCat, self) then
		        local FactionName = self:GetBlueprint().General.FactionName
				local unitId = self:GetUnitId()
				local OwnerShieldMeshPath = '/mods/Research FAF/PersonalShieldMesh/'..FactionName..'/'..unitId..'_PhaseShield_mesh'
				#only units listed in the folder can have personal shield, to avoid compatiable issues
				if DiskGetFileInfo(OwnerShieldMeshPath..'.bp') then
				    self:ForkThread(path.ActiveUnitShield(self))
				end
			end
			
			#buff units
			if EntityCategoryContains(BuffCat, self) then
			    self:ForkThread(path.BuffSpeed(self))
				self:ForkThread(path.BuffHP(self))
				self:ForkThread(path.BuffROF(self))
				self:ForkThread(path.BuffDamage(self))
				self:ForkThread(path.BuffRange(self))
				self:ForkThread(path.BuffViz(self))
				self:ForkThread(path.BuffVet(self))
			end
		end
		
	end,
	
    OnDetectedBy = function(self, index)
		ResearchUnit.OnDetectedBy(self, index)
		import('/mods/Research FAF/lua/EventControl.lua').UnitDetected(self)
    end,
	
	OnDestroy = function(self)
		ResearchUnit.OnDestroy(self)
		import('/mods/Research FAF/lua/EventControl.lua').UnitDestroy(self)
    end,
}

