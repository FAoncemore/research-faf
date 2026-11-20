do


local EnhAbilityControl = import('/mods/Research FAF/lua/EnhAbilityControl.lua')
local IntelAbilityControl = import('/mods/Research FAF/lua/IntelAbilityControl.lua')
local FieldAbilityControl = import('/mods/Research FAF/lua/FieldAbilityControl.lua')
local SWAbilityControl = import('/mods/Research FAF/lua/SWAbilityControl.lua')
local DFAbilityControl = import('/mods/Research FAF/lua/DFAbilityControl.lua')

--Enh panel
#resource +20/40/60/80/100%
Callbacks.PassResBuff = EnhAbilityControl.EcoStructureAddToggle

#buildratebuff +20/40/60/80/100%
Callbacks.PassbuildratebuffAddData = EnhAbilityControl.BuildratebuffToggle

#speedbuff +20/40/60/80/100%
Callbacks.PassLandSpeedBuffData = EnhAbilityControl.LandSpeedBuffToggle
Callbacks.StartLandSpeedBuff = EnhAbilityControl.StartLandSpeedBuff

#healthbuff +20/40/60/80/100%
Callbacks.PassHPBuff = EnhAbilityControl.HealthBuffToggle

#ROFbuff +10/25/40/65/100%
Callbacks.PassROFBuff = EnhAbilityControl.ROFBuffToggle

#Damagebuff +20/40/60/80/100%
Callbacks.PassDamageBuff = EnhAbilityControl.DamageBuffToggle

#range buff +10/20/30/40/50%
Callbacks.PassRangeBuff = EnhAbilityControl.RangeBuffToggle

#vision buff +10/20/30/40/50%
Callbacks.PassVizBuff = EnhAbilityControl.VisionBuffToggle

#veterancy 1/2/3/4/5
Callbacks.PassVetBuff = EnhAbilityControl.VeterancyBuffToggle

#resource balance
Callbacks.EcoBalExUIToggle = EnhAbilityControl.EcoBalEXUI
Callbacks.PassEcoBalanceData = EnhAbilityControl.EcoEXToggle

#get 5% mass from kills
Callbacks.PassKillReclaimData = EnhAbilityControl.KillReclaimToggle

#give envergy storage 50K
Callbacks.PassGiveEnergyStorageData = EnhAbilityControl.GiveEnergyStorage

#shield buff +20/40/60/80/100%
Callbacks.PassShieldBuff = EnhAbilityControl.ShieldBuffToggle

--intel panel
#base helper drones, vision drone
Callbacks.PassBaseDroneData = IntelAbilityControl.BaseHelperToggle

#map size viz
Callbacks.PassMapSizeVizData = IntelAbilityControl.CreateMapSizeViz

#count enemy nukes number
Callbacks.CountEnemyNukesNum = IntelAbilityControl.AnalyzeEnemyNukes

#count enemy game ender
Callbacks.CountEnemyGameEnderNum = IntelAbilityControl.AnalyzeEnemyGameEnders

#selected units random move
Callbacks.SelectedRandomMove = IntelAbilityControl.RandomMove

#detected enemy units
Callbacks.CreateDetectAreas = IntelAbilityControl.CreateDetectAreas

#setup decal size watch size
Callbacks.SetDecalSize = IntelAbilityControl.SetDecalSize

#setup decal life time seconds
Callbacks.SetDecalLifeTime = IntelAbilityControl.SetDecalLifeTime

#area watch toggle
Callbacks.AreaWatchToggle = IntelAbilityControl.AreaWatchToggle

--field support panel
#field regen
Callbacks.PassFieldRegen = FieldAbilityControl.CreateFieldRegen

#field support units 
Callbacks.PassFieldSupports = FieldAbilityControl.CreateFieldSupports

#mark selected units
Callbacks.MarkSelectedUnits = FieldAbilityControl.MarkSelectedUnits

--super weapon panel
#gate in
Callbacks.PassGateInData = SWAbilityControl.CreateGateInUnit

#gate out
Callbacks.PassGateOutData = SWAbilityControl.CreateGateOutUnit

#teleport units in range
Callbacks.PassUnitstoTeleportData = SWAbilityControl.TeleportUnitsInRange

#UEF black hole
Callbacks.PassUEFBlackHoleStrikeData = SWAbilityControl.CreateUEFBlackHoleStrike

#nuke strike
Callbacks.PassNukeStrikeData = SWAbilityControl.CreateNukeStrike

#text nuke strike
Callbacks.PassTextNukeStrikeData = SWAbilityControl.CreateTextNukeStrike

#UEF Titan square
Callbacks.PassReinforcementData = SWAbilityControl.CreateReinforcementSquare

#weapon control
Callbacks.SelWep = import('/mods/Research FAF/lua/WeaponControl.lua').SelectWeapon

#defender
Callbacks.PassDFHPBuff = DFAbilityControl.HeroHealthBuff
Callbacks.PassDFShieldBuff = DFAbilityControl.HeroShieldBuff
Callbacks.PassDFSpeedBuff = DFAbilityControl.HeroSpeedBuff
Callbacks.DefenderVZ = DFAbilityControl.DefenderVZ

--for slider to adjust unit cap
Callbacks.ResearchUnitCap = function(data)
    for index, brain in ArmyBrains do
        local armyIndex = brain:GetArmyIndex()
        SetArmyUnitCap(armyIndex, data)
    end
end

Callbacks.ShowUnitShield = import('/mods/Research FAF/lua/ShowInfo.lua').GetUnitShieldValue

end

