local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Prefs = import('/lua/user/prefs.lua')
local cmdMode = import('/lua/ui/game/commandmode.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local sysEnable = Sound({Bank = 'XGG', Cue = 'Computer_Computer_Basic_Orders_01173'})
local Window = import('/lua/maui/window.lua').Window
local Edit = import('/lua/maui/edit.lua').Edit
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local BaseDroneAbility = 2
local MapSizeVisionAbility = 7
local FogOfWarAbility = 0
local enderAbility = 0
local FieldStealthRadarAbility = 2
local FieldJammerCrystalAbility = 1
local UnlockExpAlertAbility = 1
local eventCameraAbility = 2
local MonitorAbility = 0

local parentBG = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg
local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor

local vizButtonText, fogText = false
local vizButtonBusy = false
local vizButtonLeft
local vizButtonRight
local vizButtonAB
local BaseDroneActive = false
local FogOfWarCountTable = {1}
local ExpAlertThread = false
local eventCameraButtonCountTable = {1}
local eventCameraActive = false
local eventCameraPaid = false

local AbilityGenerated = 0
local AbilityCollected = 0
local AbilitySpent = 0
local nukeCounts = 0
local infoLabel
mavorCounts = 0
paragonCounts = 0
salvationCounts = 0
scathisCounts = 0
yoCounts = 0

local unlockExpButton
local fogButton
local vizButton
local droneButton
local unitsButton
local shieldunitsButton
local aaButton
local stealthButton
local crystalButton
local infoButton
local monitorButton
local eventcameraButton

function ResearchLabHandle(generated)
	ForkThread(function()
		AbilityGenerated = AbilityGenerated + generated
	end)
end

function CollectedAbility(Collected)
	AbilityCollected = Collected
end

function SpentAbility(Spent)
	AbilitySpent = Spent
end

function EnemyNukesCounts(nuke)
	nukeCounts = nuke
end

function EnemyMavorCounts(mavor)
	mavorCounts = mavor
end

function EnemyParagonCounts(paragon)
	paragonCounts = paragon
end

function EnemySalvationCounts(sv)
	salvationCounts = sv
end

function EnemyScathisCounts(scathis)
	scathisCounts = scathis
end

function EnemyYOCounts(yo)
	yoCounts = yo
end

function CreateButtons(leftBG, rightBG, intAbility)
	CreateBaseDroneButton(leftBG, rightBG, intAbility)
	CreateMapSizeVisionButton(leftBG, rightBG, intAbility)
	CreateFogOfWarButton(leftBG, rightBG, intAbility)

	ForkThread(function()
		CreateInfoButton(leftBG, rightBG, intAbility)
	end)

	CreateFieldStealthRadarButton(rightBG, intAbility)
	CreateFieldJammerCrystal(rightBG, intAbility)
	CreateUnlockExpAlertButton(rightBG, intAbility)
	CreateEventCameraButton(rightBG, intAbility)
	CreateMonitorButton(rightBG, intAbility)
	
	CreateAreaDetectButton(rightBG, intAbility)
end

function CreateBaseDroneButton(leftBG, rightBG, intAbility)
    if BaseDroneActive == true then
	    local skin = UIUtil.UIFile('/game/uef-enhancements/red_btn_over.dds')
	    droneButton = Button(leftBG, skin, skin, skin, skin)
	else
	    droneButton = Button(
	        leftBG, 
	        UIUtil.UIFile('/game/uef-enhancements/red_btn_up.dds'), 
		    UIUtil.UIFile('/game/uef-enhancements/red_btn_down.dds'), 
		    UIUtil.UIFile('/game/uef-enhancements/red_btn_over.dds'), 
		    UIUtil.UIFile('/game/uef-enhancements/red_btn_sel.dds')
	    )
	end
	
	LayoutHelpers.AtCenterIn(droneButton, leftBG)
	droneButton.Top:Set(function() return leftBG.Top() + 5*scale end)
	droneButton.Width:Set(48*scale)
	droneButton.Height:Set(48*scale)
	droneButton.Depth:Set(leftBG.Depth() + 1)

	local title = 'Drones at main base'
	local description = 'One vision drone and 4 ENG drones at main base'
	local tips = ''
	droneButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(droneButton, rightBG, BaseDroneAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    droneButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	droneButton.OnClick = function()
		if BaseDroneActive == true then
		    --do nothing
		else
		    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		    if currentAbilities < BaseDroneAbility then
				import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		    else
				SimCallback({Func = 'PassBaseDroneData'})
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + BaseDroneAbility
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				BaseDroneActive = true
				currentAbilities = leftAbilities
				droneButton:Destroy()
				CreateBaseDroneButton(leftBG, rightBG, intAbility)
			end
		end
	end

end

function CreateMapSizeVisionButton(leftBG, rightBG, intAbility)

    if vizButtonBusy == true then
	    local skin = UIUtil.UIFile('/game/seraphim-enhancements/sre_btn_over.dds')
	    vizButton = Button(leftBG, skin, skin, skin, skin)
	else
	    vizButton = Button(
	        leftBG, 
	        UIUtil.UIFile('/game/seraphim-enhancements/sre_btn_up.dds'), 
		    UIUtil.UIFile('/game/seraphim-enhancements/sre_btn_down.dds'),
		    UIUtil.UIFile('/game/seraphim-enhancements/sre_btn_over.dds'), 
		    UIUtil.UIFile('/game/seraphim-enhancements/sre_btn_sel.dds')
	    )
	end

	LayoutHelpers.AtCenterIn(vizButton, leftBG)
	vizButton.Top:Set(function() return leftBG.Top() + 50*scale end)
	vizButton.Width:Set(48*scale)
	vizButton.Height:Set(48*scale)
	vizButton.Depth:Set(leftBG.Depth() + 1)
	vizButtonText = UIUtil.CreateText(vizButton, LOC(''), 16)
	LayoutHelpers.AtTopIn(vizButtonText, vizButton, 4)
	LayoutHelpers.AtHorizontalCenterIn(vizButtonText, vizButton)
	if vizButtonBusy == false then vizButtonText:SetText('') end
	
	local title = 'Vision and Omni'
	local description = 'Create a map-size vision and omni for 60 seconds'
	local tips = ''
	vizButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(vizButton, rightBG, MapSizeVisionAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    vizButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end

    vizButtonLeft = leftBG
	vizButtonRight = rightBG
	vizButtonAB = intAbility
	
	vizButton.OnClick = function()
	    if vizButtonBusy == false then
		    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		    if currentAbilities < MapSizeVisionAbility then
				import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		    else
		        local lifeTime = 60
			    SimCallback({Func = 'PassMapSizeVizData', Args = lifeTime})
				vizButtonBusy = true
			    PlayVoice(sysEnable)
			    AbilitySpent = AbilitySpent + MapSizeVisionAbility
			    NotifyAllPanels(AbilitySpent)
			    local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			    currentAbilities = leftAbilities
				vizButton:Destroy()
				CreateMapSizeVisionButton(leftBG, rightBG, intAbility)
		    end
		end
	end
end

function MapSizeVizCountDown(data)
    if data > 0 then 
	    vizButtonBusy = true
		vizButtonText:SetText(data)
	else
		vizButtonBusy = false
		vizButtonText:SetText('')
		CreateMapSizeVisionButton(vizButtonLeft, vizButtonRight, vizButtonAB)
	end
end

function CreateFogOfWarButton(leftBG, rightBG, intAbility)
	local num = table.getn(FogOfWarCountTable)
	local mod = math.mod(num, 2)
	if mod == 0 then
	    local skin = UIUtil.UIFile('/game/cybran-enhancements/sfs_btn_over.dds')
	    fogButton = Button(leftBG, skin, skin, skin, skin)
	else
	    fogButton = Button(
	        leftBG, 
			UIUtil.UIFile('/game/cybran-enhancements/sfs_btn_up.dds'), 
			UIUtil.UIFile('/game/cybran-enhancements/sfs_btn_down.dds'), 
			UIUtil.UIFile('/game/cybran-enhancements/sfs_btn_over.dds'), 
			UIUtil.UIFile('/game/cybran-enhancements/sfs_btn_sel.dds')
	    )
	end
    
	LayoutHelpers.AtCenterIn(fogButton, leftBG)
	fogButton.Top:Set(function() return leftBG.Top() + 100*scale end)
	fogButton.Width:Set(48*scale)
	fogButton.Height:Set(48*scale)
	fogButton.Depth:Set(leftBG.Depth() + 1)
	fogText = UIUtil.CreateText(fogButton, LOC('Off'), 16)
	LayoutHelpers.AtTopIn(fogText, fogButton, 4)
	LayoutHelpers.AtHorizontalCenterIn(fogText, fogButton)
	
	local title = 'Fog of War'
	local description = '(Requires Cheat On) Turn Fog of War On/Off'
	local tips = ''
	fogButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(fogButton, rightBG, FogOfWarAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    fogButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	if mod == 0 then
		fogText:SetText('On')
	else
	    fogText:SetText('Off')
	end
	
	fogButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < FogOfWarAbility then
		    if mod == 0 then
			    #need Cheat On
			    ConExecute('SallyShears')
				PlayVoice(sysEnable)
				num = num + 1
				table.insert(FogOfWarCountTable, num)
				fogText:SetText('Off')
				CreateFogOfWarButton(leftBG, rightBG, intAbility)
		    else
				import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
			end
		else
		    if mod == 0 then
			    ConExecute('SallyShears')
				PlayVoice(sysEnable)
				num = num + 1
				table.insert(FogOfWarCountTable, num)
				fogText:SetText('Off')
				CreateFogOfWarButton(leftBG, rightBG, intAbility)
		    else
                ConExecute('SallyShears')
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + FogOfWarAbility
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				num = num + 1
				table.insert(FogOfWarCountTable, num)
				currentAbilities = leftAbilities
				fogText:SetText('On')
				CreateFogOfWarButton(leftBG, rightBG, intAbility)
			end
		end
	end
end

function CreateInfoButton(leftBG, rightBG, intAbility)
	infoButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/options_btn/inbox_btn_up.dds'), 
		UIUtil.UIFile('/game/options_btn/inbox_btn_down.dds'), 
		UIUtil.UIFile('/game/options_btn/inbox_btn_over.dds'), 
		UIUtil.UIFile('/game/options_btn/inbox_btn_dis.dds')
	)
    
	LayoutHelpers.AtCenterIn(infoButton, leftBG)
	infoButton.Top:Set(function() return leftBG.Top() + 150*scale end)
	infoButton.Width:Set(48*scale)
	infoButton.Height:Set(48*scale)
	infoButton.Depth:Set(leftBG.Depth() + 1)
	infoLabel = UIUtil.CreateText(infoButton, '', 12, UIUtil.bodyFont)
	LayoutHelpers.AtCenterIn(infoLabel, infoButton)
	infoLabel.Top:Set(function() return infoButton.Bottom() + 2*scale end)
	
	local title = 'Check Game Ender'
	local description = 'Check QTY of game enders'
	local tips = ''
	infoButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(infoButton, rightBG, enderAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    infoButton.OnClick()
			KillABDialog()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	infoButton.OnClick = function()
		local title = 'Checking Game Ender'
		SimCallback({Func = 'CountEnemyGameEnderNum'})
		import('/mods/Research FAF/lua/ui/FieldInfo.lua').Initial(infoButton, rightBG, title, mavorCounts, paragonCounts, salvationCounts, scathisCounts, yoCounts)
		PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
	end
end

function CreateFieldStealthRadarButton(rightBG, intAbility)

	stealthButton = Button(
	    rightBG, 
	    UIUtil.UIFile('/game/orders/skry-target_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/skry-target_btn_up_sel.dds'), 
		UIUtil.UIFile('/game/orders/skry-target_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/skry-target_btn_over_sel.dds')
	)
	
	LayoutHelpers.AtCenterIn(stealthButton, rightBG)
	stealthButton.Top:Set(function() return rightBG.Top() + 5*scale end)
	stealthButton.Width:Set(48*scale)
	stealthButton.Height:Set(48*scale)
	stealthButton.Depth:Set(rightBG.Depth() + 1)

	local title = 'Remote Filed Intel 120s'
	local description = 'Vision 100, Radar 150, Omni 100, RadarStealth 150'
	local tips = ''
	stealthButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(stealthButton, rightBG, FieldStealthRadarAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    stealthButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
		
	stealthButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < FieldStealthRadarAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = 'URA0009'
			#120s radar, stealth, vision remote support
			ForkThread(function()
				CreateFieldIntelUnit(ID)
			end)
			AbilitySpent = AbilitySpent + FieldStealthRadarAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
end

function CreateFieldJammerCrystal(rightBG, intAbility)
    local crystalIcon = UIUtil.UIFile('/icons/units/XSC9002_icon.dds')
	crystalButton	= Button(rightBG, crystalIcon, crystalIcon, crystalIcon, crystalIcon)	
	LayoutHelpers.AtCenterIn(crystalButton, rightBG)
	crystalButton.Top:Set(function() return rightBG.Top() + 50*scale end)
	crystalButton.Width:Set(48*scale)
	crystalButton.Height:Set(48*scale)
	crystalButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Remote Field Jamming Crystal'
	local description = 'A Jamming Crystal'
	local tips = ''
	crystalButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(crystalButton, rightBG, FieldJammerCrystalAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    crystalButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	crystalButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < FieldJammerCrystalAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = 'XSC9002'
			ForkThread(function()
			    CreateFieldIntelUnit(ID)
			end)
			AbilitySpent = AbilitySpent + FieldJammerCrystalAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

#exp alert
function CreateUnlockExpAlertButton(rightBG, intAbility)
    if ExpAlertThread == true then
	    local skin = UIUtil.UIFile('/game/tech-icons-sm_btn/experimental_icon_btn_over.dds')
	    unlockExpButton = Button(rightBG, skin, skin, skin, skin)
	else
	    unlockExpButton = Button(
	        rightBG, 
			UIUtil.UIFile('/game/tech-icons-sm_btn/experimental_icon_btn_up.dds'), 
			UIUtil.UIFile('/game/tech-icons-sm_btn/experimental_icon_btn_down.dds'), 
			UIUtil.UIFile('/game/tech-icons-sm_btn/experimental_icon_btn_over.dds'), 
			UIUtil.UIFile('/game/tech-icons-sm_btn/experimental_icon_btn_dis.dds')
	    )
	end

	unlockExpButton.Width:Set(48*scale)
	unlockExpButton.Height:Set(48*scale)
	LayoutHelpers.AtCenterIn(unlockExpButton, rightBG)
	unlockExpButton.Top:Set(function() return rightBG.Top() + 100*scale end)
	unlockExpButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Experimental Alert'
	local description = 'Voice alert for Exp detected'
	local tips = 'Better to turn on Event Reminder (below) together'
	unlockExpButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(unlockExpButton, rightBG, UnlockExpAlertAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    unlockExpButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	unlockExpButton.OnClick = function()
		if ExpAlertThread == true then
		    #do nothing
		else
		    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		    if currentAbilities < UnlockExpAlertAbility then
			    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		    else
				import('/mods/Research FAF/lua/ui/EventVoice.lua').ExpAlert = true
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + UnlockExpAlertAbility
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility- AbilitySpent
				ExpAlertThread = true
				currentAbilities = leftAbilities
				unlockExpButton:Destroy()
				CreateUnlockExpAlertButton(rightBG, intAbility)
			end
		end
	end
	
end

#event camera
function CreateEventCameraButton(rightBG, intAbility)
    local num = table.getn(eventCameraButtonCountTable)
	local mod = math.mod(num, 2)
	local icon
	if mod == 0 then
	    icon = UIUtil.UIFile('/game/camera-btn/pinned_btn_over.dds')
	else
	    icon = UIUtil.UIFile('/game/camera-btn/pinned_btn_dis.dds')
	end
	eventcameraButton = Button(rightBG, icon, icon, icon, icon)

	eventcameraButton.Width:Set(36*scale)
	eventcameraButton.Height:Set(36*scale)
	LayoutHelpers.AtCenterIn(eventcameraButton, rightBG)
	eventcameraButton.Top:Set(function() return rightBG.Top() + 150*scale end)
	eventcameraButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Event Reminder'
	local description = 'Events for detect/destroy from Exp, Nuke, Artillery'
	local tips = 'Click to turn On/Off event reminder'
	eventcameraButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(eventcameraButton, rightBG, eventCameraAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    eventcameraButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	eventcameraButton.OnClick = function()
	    if mod == 0 then
		    eventCameraActive = false
			import('/mods/Research FAF/lua/ui/EventTab.lua').Initial(eventCameraActive)
			num = num + 1
			table.insert(eventCameraButtonCountTable, num)
			CreateEventCameraButton(rightBG, intAbility)
		else
		    if eventCameraPaid == false then
			    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
				if currentAbilities < eventCameraAbility then
				    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
				else
				    PlayVoice(sysEnable)
					eventCameraActive = true
					eventCameraPaid = true
					import('/mods/Research FAF/lua/ui/EventTab.lua').Initial(eventCameraActive)
					AbilitySpent = AbilitySpent + eventCameraAbility
					NotifyAllPanels(AbilitySpent)
					local leftAbilities = AbilityCollected + intAbility- AbilitySpent
					currentAbilities = leftAbilities
					num = num + 1
					table.insert(eventCameraButtonCountTable, num)
					eventCameraAbility = 0
					CreateEventCameraButton(rightBG, intAbility)
				end
			else
			    PlayVoice(sysEnable)
				eventCameraActive = true
				import('/mods/Research FAF/lua/ui/EventTab.lua').Initial(eventCameraActive)
				num = num + 1
				table.insert(eventCameraButtonCountTable, num)
				CreateEventCameraButton(rightBG, intAbility)
			end
		end
	end
end

#monitor field
function CreateMonitorButton(rightBG, intAbility)
    local image = UIUtil.UIFile('/game/avatar/pulse-bars_bmp.dds')
    monitorButton = Button(
	        rightBG, 
			image,
			image,
			image,
			image
	    )

	monitorButton.Width:Set(48*scale)
	monitorButton.Height:Set(48*scale)
	LayoutHelpers.AtCenterIn(monitorButton, rightBG)
	monitorButton.Top:Set(function() return rightBG.Top() + 200*scale end)
	monitorButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Mini Map'
	local description = 'Another mini map for watching closer to key unit'
	local tips = 'Ctrl+T track unit in the mini map'
	monitorButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(monitorButton, rightBG, MonitorAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    monitorButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	monitorButton.OnClick = function()
	    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < MonitorAbility then
		    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			local ID = 'test'
			ForkThread(function()
				CreateAreaMonitor(ID)
			end)
			AbilitySpent = AbilitySpent + MonitorAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility- AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

local catKey = 1 --default Experimental units
function SetupWatchCat(key) 
	catKey = key
end

#area enemy units detected
function CreateAreaDetectButton(rightBG, intAbility)
    --local image = UIUtil.UIFile('/game/orders/autocast_bmp.dds')
	local image = UIUtil.UIFile('/env/utility/decals/objective_debug_albedo.dds')
    local detectButton = Button(
	        rightBG, 
			image,
			image,
			image,
			image
	    )

	detectButton.Width:Set(40*scale)
	detectButton.Height:Set(40*scale)
	LayoutHelpers.AtCenterIn(detectButton, rightBG)
	detectButton.Top:Set(function() return rightBG.Top() + 250*scale end)
	detectButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Area Watch'
	local description = 'Detect enemy units in the area'
	local tips = 'Unit type can be setup in Research Options'
	detectButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(detectButton, rightBG, MonitorAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    detectButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	detectButton.OnClick = function()
	    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < MonitorAbility then
		    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			ForkThread(function()
				local ID = catKey
				CreateAreaDected(ID)
			end)
			AbilitySpent = AbilitySpent + MonitorAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility- AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function NotifyAllPanels(spent) 
	import('/mods/Research FAF/lua/ui/AbilityMenu.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/EnhPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/FieldPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/SWPPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/DFPanel.lua').SpentAbility(spent)
end

--special thanks to CDRMV, the author of Commander Survival Kit
function CreateFieldIntelUnit(ID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			ForkThread(function()
			    --local cmd = 'CreateUnit ' .. ID .. ' ' .. (GetFocusArmy() -1)
			    --ConExecuteSave(cmd) -- requires CheatOn
				local position = GetMouseWorldPos()
				SimCallback({Func = 'PassFieldSupports', Args = {id = ID, pos = position}})
			    ID = nil
			end)
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CreateAreaMonitor(ID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			import('/Mods/Research FAF/lua/ui/AreaMonitor.lua').CreatAreaMonitor(position, ID)
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CreateAreaDected(ID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'CreateDetectAreas', Args = {key = ID, pos = position}})
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CreateABDialog(curBtn, bg, AB, title, description, tips)
    import('/mods/Research FAF/lua/ui/TipsDialogs.lua').Initial(curBtn, bg, AB, title, description, tips)
end

function KillABDialog()
    import('/mods/Research FAF/lua/ui/TipsDialogs.lua').KillABDialog()
end
