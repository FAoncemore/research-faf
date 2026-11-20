#****************************************************************************
#**
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**
#**  Summary  :  UEF Commander Script
#**
#**  Copyright ?2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local TerranWeaponFile = import('/lua/terranweapons.lua')

#wep1
local TDFZephyrCannonWeapon = TerranWeaponFile.TDFZephyrCannonWeapon

#wep2
local TDFHeavyPlasmaCannonWeapon = TerranWeaponFile.TDFHeavyPlasmaCannonWeapon

#wep3
local TSAMLauncher = TerranWeaponFile.TSAMLauncher

#wep4
local TDFIonizedPlasmaCannon = TerranWeaponFile.TDFIonizedPlasmaCannon

#wep5
local CIFArtilleryWeapon = import('/lua/cybranweapons.lua').CIFArtilleryWeapon

#wep6
local TOrbitalDeathLaserBeamWeapon = TerranWeaponFile.TOrbitalDeathLaserBeamWeapon

#wep7
local TANTorpedoLandWeapon = TerranWeaponFile.TANTorpedoLandWeapon

local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon

FPSFAHERO = Class(TWalkingLandUnit) {    
    DeathThreadDestructionWaitTime = 2,
    Weapons = {
	    #targeting laser weapon, fake weapon, by this we no need to walk toward the targets, donot delect it.
        TargetingLaser = Class(TDFZephyrCannonWeapon) {},
		
		#acu default
        Wep1 = Class(TDFZephyrCannonWeapon) {},
		
		#t3 pd
        Wep2 = Class(TDFHeavyPlasmaCannonWeapon) {},
		
		#t3 tsam launcher
        Wep3 = Class(TSAMLauncher) {},
		
		#t3 percival
        Wep4 = Class(TDFIonizedPlasmaCannon) {},
		
		#t3 cybran artillery
        Wep5 = Class(CIFArtilleryWeapon) {},
		
		#satellite
        Wep6 = Class(TOrbitalDeathLaserBeamWeapon) {},
		
		#T2 torpedo
        Wep7 = Class(TANTorpedoLandWeapon) {},
		
		DeathWeapon = Class(DeathNukeWeapon) {},
		
    },

    OnCreate = function(self)
        TWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        self:HideBone('Back_Upgrade_B01', true)
        self:SetupBuildBones()
        self.HasLeftPod = false
        self.HasRightPod = false
        #self:SetWeaponEnabledByLabel('TargetingLaser', true)
        self:SetWeaponEnabledByLabel('Wep1', true)
        self:SetWeaponEnabledByLabel('Wep2', false)
        self:SetWeaponEnabledByLabel('Wep3', false)
        self:SetWeaponEnabledByLabel('Wep4', false)
        self:SetWeaponEnabledByLabel('Wep5', false)
        self:SetWeaponEnabledByLabel('Wep6', false)
        self:SetWeaponEnabledByLabel('Wep7', false)
    end,

    OnPrepareArmToBuild = function(self)
        TWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('Wep1'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        TWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:GetWeaponManipulatorByLabel('Wep1'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        TWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:GetWeaponManipulatorByLabel('Wep1'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        TWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:GetWeaponManipulatorByLabel('Wep1'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    GiveInitialResources = function(self)
        WaitTicks(5)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        if self:BeenDestroyed() then return end
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        if self.IdleAnim then
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        self:BuildManipulatorSetEnabled(false)
        self:ForkThread(self.GiveInitialResources)
		self:ForkThread(self.HealthPercentage)
    end,

    HealthPercentage = function(self)
        while true do
		    local percentage = self:GetHealth()/self:GetMaxHealth()
			Sync.FPSFAHeroHealth = percentage
			WaitSeconds(1)
		end
    end,
	
    PlayCommanderWarpInEffect = function(self)
        self:HideBone(0, true)
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self:ForkThread(self.WarpInEffectThread)
    end,

    WarpInEffectThread = function(self)
        self:PlayUnitSound('CommanderArrival')
        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(2.1)
        self:ShowBone(0, true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        self:HideBone('Back_Upgrade_B01', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)

        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitSeconds(6)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        TWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.Animator then
            self.Animator:SetRate(0)
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,

    OnFailedToBuild = function(self)
        TWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:GetWeaponManipulatorByLabel('Wep1'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        # If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
            EffectUtil.CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            EffectUtil.CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        
        end           
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        TWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        if (self.IdleAnim and not self:IsDead()) then
            self.Animator:PlayAnim(self.IdleAnim, true)
        end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:GetWeaponManipulatorByLabel('Wep1'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,
    
    OnPaused = function(self)
        TWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        TWalkingLandUnit.OnUnpaused(self)
    end,     

    NotifyOfPodDeath = function(self, pod)
    end, 
	
    OnKilled = function(self, instigator, type, overkillRatio)
        TWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
		Death = true
		local DFVZ = import('/Mods/Research FAF/lua/DFAbilityControl.lua').DFVZ
		if DFVZ then 
		    DFVZ:Destroy()
			DFVZ = false
		end
        Sync.DefenderLost = Death
    end,

}

TypeClass = FPSFAHERO