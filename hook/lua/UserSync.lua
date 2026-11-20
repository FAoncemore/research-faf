#****************************************************************************
#**
#**  File     :  /hook/lua/UserSync.lua
#**  Author(s):  novaprim3
#**
#**  Summary  :  Multi-Phantom Mod for Forged Alliance
#**
#****************************************************************************

local ResearchOnSync = OnSync
function OnSync()
	ResearchOnSync ()
	
	# research abilities from kill counts
	if Sync.ResearchUpdatedAbilityCount then
		import('/Mods/Research FAF/lua/ui/AbilityMenu.lua').CollectedAbility(Sync.ResearchUpdatedAbilityCount)
		import('/Mods/Research FAF/lua/ui/EnhPanel.lua').CollectedAbility(Sync.ResearchUpdatedAbilityCount)
		import('/Mods/Research FAF/lua/ui/FieldPanel.lua').CollectedAbility(Sync.ResearchUpdatedAbilityCount)
		import('/Mods/Research FAF/lua/ui/IntelPanel.lua').CollectedAbility(Sync.ResearchUpdatedAbilityCount)
		import('/Mods/Research FAF/lua/ui/SWPPanel.lua').CollectedAbility(Sync.ResearchUpdatedAbilityCount)
		import('/Mods/Research FAF/lua/ui/DFPanel.lua').CollectedAbility(Sync.ResearchUpdatedAbilityCount)
	end
	
	# abilities from research labs
	if Sync.ResearchLabsCount then
		import('/Mods/Research FAF/lua/ui/AbilityMenu.lua').ResearchLabHandle(Sync.ResearchLabsCount)
		import('/Mods/Research FAF/lua/ui/EnhPanel.lua').ResearchLabHandle(Sync.ResearchLabsCount)
		import('/Mods/Research FAF/lua/ui/FieldPanel.lua').ResearchLabHandle(Sync.ResearchLabsCount)
		import('/Mods/Research FAF/lua/ui/IntelPanel.lua').ResearchLabHandle(Sync.ResearchLabsCount)
		import('/Mods/Research FAF/lua/ui/SWPPanel.lua').ResearchLabHandle(Sync.ResearchLabsCount)
		import('/Mods/Research FAF/lua/ui/DFPanel.lua').ResearchLabHandle(Sync.ResearchLabsCount)
	end
	
	# abilities generate ratio from research labs
	if Sync.ResearchLabsRatio then
		import('/Mods/Research FAF/lua/ui/AbilityMenu.lua').ResearchLabProgress(Sync.ResearchLabsRatio)
	end
	
	# abilities kills progress
	if Sync.ResearchUpdatedKillsProgress then
		import('/Mods/Research FAF/lua/ui/AbilityMenu.lua').ResearchKillsProgress(Sync.ResearchUpdatedKillsProgress)
	end
	
	# map size viz off
	if Sync.NotifyVizOff then
	    import('/mods/Research FAF/lua/ui/IntelPanel.lua').MapSizeVizCountDown(Sync.NotifyVizOff)
	end
	
	# hero health percentage
	if Sync.FPSFAHeroHealth then
		import('/Mods/Research FAF/lua/ui/FPSHero.lua').ShowHealth(Sync.FPSFAHeroHealth)
	end
	
	# defender lost
	if Sync.DefenderLost then
		import('/Mods/Research FAF/lua/ui/DFPanel.lua').DefenderLost(Sync.DefenderLost)
	end
	
	# enemy nuke counts
	if Sync.EnemyNukesQty then
		import('/mods/Research FAF/lua/ui/NukeDialog.lua').EnemyNukesCounts(Sync.EnemyNukesQty)
	end
	
	# enemy game ender counts
	if Sync.EnemyMavorQty then
	    import('/mods/Research FAF/lua/ui/IntelPanel.lua').EnemyMavorCounts(Sync.EnemyMavorQty)
	end
	
	# enemy game ender counts
	if Sync.EnemyParagonQty then
	    import('/mods/Research FAF/lua/ui/IntelPanel.lua').EnemyParagonCounts(Sync.EnemyParagonQty)
	end
	
	# enemy game ender counts
	if Sync.EnemySalvationQty then
	    import('/mods/Research FAF/lua/ui/IntelPanel.lua').EnemySalvationCounts(Sync.EnemySalvationQty)
	end
	
	# enemy game ender counts
	if Sync.EnemyScathisQty then
	    import('/mods/Research FAF/lua/ui/IntelPanel.lua').EnemyScathisCounts(Sync.EnemyScathisQty)
	end
	
	# enemy game ender counts
	if Sync.EnemyYOQty then
	    import('/mods/Research FAF/lua/ui/IntelPanel.lua').EnemyYOCounts(Sync.EnemyYOQty)
	end
	
	# Game Ender detected pos
	if Sync.MavorPos then
		import('/Mods/Research FAF/lua/ui/FieldInfo.lua').MavorAlertPos(Sync.MavorPos)
	end
	if Sync.ParagonPos then
		import('/Mods/Research FAF/lua/ui/FieldInfo.lua').ParagonAlertPos(Sync.ParagonPos)
	end
	if Sync.SalvationPos then
		import('/Mods/Research FAF/lua/ui/FieldInfo.lua').SalvationAlertPos(Sync.SalvationPos)
	end
	if Sync.ScathisPos then
		import('/Mods/Research FAF/lua/ui/FieldInfo.lua').ScathisAlertPos(Sync.ScathisPos)
	end
	if Sync.YolonaossPos then
		import('/Mods/Research FAF/lua/ui/FieldInfo.lua').YolonaossAlertPos(Sync.YolonaossPos)
	end
	
	#unit detecte
	if Sync.ExpDetectedEvent then
		import('/Mods/Research FAF/lua/ui/EventTab.lua').EventAlertId(Sync.ExpDetectedEvent)
		import('/Mods/Research FAF/lua/ui/EventVoice.lua').ExpDetected(Sync.ExpDetectedEvent)
	end
	if Sync.NukeDetectedEvent then
		import('/Mods/Research FAF/lua/ui/EventTab.lua').EventAlertId(Sync.NukeDetectedEvent)
	end
	if Sync.ArtDetectedEvent then
		import('/Mods/Research FAF/lua/ui/EventTab.lua').EventAlertId(Sync.ArtDetectedEvent)
	end

	#exp destroy
	if Sync.EXPDestroy then
		import('/Mods/Research FAF/lua/ui/EventTab.lua').EventAlertId(Sync.EXPDestroy)
	end
	
	#nuke destroy
	if Sync.NukeDestroy then
		import('/Mods/Research FAF/lua/ui/EventTab.lua').EventAlertId(Sync.NukeDestroy)
	end
	
	#artillery destroy
	if Sync.ArtilleryDestroy then
		import('/Mods/Research FAF/lua/ui/EventTab.lua').EventAlertId(Sync.ArtilleryDestroy)
		import('/Mods/Research FAF/lua/ui/EventVoice.lua').ArtilleryDestory()
	end
	
	#show unit shield
	if Sync.UnitShieldValue then
		import('/Mods/Research FAF/lua/ui/ShowUnitShieldValue.lua').ShowShield(Sync.UnitShieldValue)
	end
	
	#kill enenmy acu and return with engineer
	if Sync.SetAvailableEng then
		import('/Mods/Research FAF/lua/ui/FieldPanel.lua').SetAvailableEng(Sync.SetAvailableEng)
	end
	
	#area detect alert
	if Sync.AreaDetect then
		import('/Mods/Research FAF/lua/ui/AreaDetect.lua').Initial(Sync.AreaDetect)
	end
end
