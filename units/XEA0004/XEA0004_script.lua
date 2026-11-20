#****************************************************************************
#**
#**  File     :  /cdimage/units/XEA0002/XEA0002_script.lua
#**  Author(s):  Drew Staltman, Gordon Duclos
#**
#**  Summary  :  UEF Defense Satelite Script
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local TAirUnit = import('/lua/terranunits.lua').TAirUnit
local ADFTractorClaw = import ('/lua/aeonweapons.lua').ADFTractorClaw
local EffectTemplate = import('/lua/EffectTemplates.lua')

XEA0004 = Class(TAirUnit) {
    DestroyNoFallRandomChance = 1.1,
    
    HideBones = { 'Shell01', 'Shell02', 'Shell03', 'Shell04', },
		
    Weapons = {
        ArmTractor = Class(ADFTractorClaw) {
            OnWeaponFired = function(self)
                ADFTractorClaw.OnWeaponFired(self)
				local FxLaunch = EffectTemplate.SIFInainoPreLaunch01 
				for k, v in FxLaunch do
				    CreateEmitterAtEntity(self.unit, self.unit:GetArmy(), v)
				end
            end,
		},
    },
		
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.IsDying then 
            return 
        end
        
        local wep = self:GetWeaponByLabel('OrbitalDeathLaserWeapon')
        for k, v in wep.Beams do
            v.Beam:Disable()
        end      
        
        self.IsDying = true
        self.Parent:Kill(instigator, type, 0)
        
        TAirUnit.OnKilled(self, instigator, type, overkillRatio)        
    end,
    
    Open = function(self)
        ChangeState( self, self.OpenState )
    end,
    
    OpenState = State() {
        Main = function(self)
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim( '/mods/Research FAF/units/XEA0004/xea0004_aopen01.sca' )
            self.Trash:Add( self.OpenAnim )
            WaitFor( self.OpenAnim )
            
            self.OpenAnim:PlayAnim( '/mods/Research FAF/units/XEA0004/xea0004_aopen02.sca' )
            
            for k,v in self.HideBones do
                self:HideBone( v, true )
            end
        end,
    },
    
    --Make this unit invulnerable
    OnDamage = function()
    end,
}
TypeClass = XEA0004