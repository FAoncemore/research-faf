#****************************************************************************
#**
#**  File     :  /cdimage/units/URB4207/URB4207_script.lua
#**  Author(s):  David Tomandl, Greg Kohne
#**
#**  Summary  :  Cybran Shield Generator lvl X Script
#**
#**  Copyright ?2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local CShieldStructureUnit = import('/lua/cybranunits.lua').CShieldStructureUnit
	
ResearchLab = Class(CShieldStructureUnit) {
    
    OnStopBeingBuilt = function(self,builder,layer)
        CShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
		#decorative bubble
        local entity = import('/lua/sim/Entity.lua').Entity({Owner = self})
        entity:AttachBoneTo( -1, self, -1 )
		#entity:SetParentOffset( {0,0,0} )
        entity:SetMesh('/mods/Research FAF/units/ResearchLab/ResearchLab_Cube_mesh')
        entity:SetDrawScale(1)
        entity:SetVizToFocusPlayer('Always')
        entity:SetVizToAllies('Intel')
        entity:SetVizToNeutrals('Intel')
        entity:SetVizToEnemies('Intel')
        self.Trash:Add(entity)
    end,	
}

TypeClass = ResearchLab