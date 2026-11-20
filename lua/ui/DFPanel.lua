local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Prefs = import('/lua/user/prefs.lua')
local cmdMode = import('/lua/ui/game/commandmode.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local sysEnable = Sound({Bank = 'XGG', Cue = 'Computer_Computer_Basic_Orders_01173'})

local AbilityGenerated = 0
local AbilityCollected = 0
local AbilitySpent = 0

#defender
local DefenderThread = false
local vzDroneActive = false

local DefenderAbility = 2
local SiloSupplyAbility = 2
local HealthSupplyAbility = 2

local defenderButton
local vzButton

local iconsTable = {	
	{UIUtil.UIFile('/icons/units/UEL0001_icon.dds')},
	{UIUtil.UIFile('/icons/units/xeb2306_icon.dds')},
	{UIUtil.UIFile('/icons/units/UEB2304_icon.dds')},
	{UIUtil.UIFile('/icons/units/xel0305_icon.dds')},
	{UIUtil.UIFile('/icons/units/URB2302_icon.dds')},
	{UIUtil.UIFile('/icons/units/xea0002_icon.dds')},
	{UIUtil.UIFile('/icons/units/UEB2109_icon.dds')}
}

local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl

local leftButtons = {'DFHPBuff', 'DFShieldBuff', 'DFSpeedBuff'}
local DFTab = {
    --Left buttons
    --Health Buff   
	['DFHPBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {2, 4, 6, 8, 10},
		['Percentage'] = {"200%", "400%", "600%", "800%", "1000%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/uef-enhancements/dsu_btn_up.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/dsu_btn_down.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/dsu_btn_over.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/dsu_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/uef-enhancements/dsu_btn_over.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/dsu_btn_over.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/dsu_btn_over.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/dsu_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Defender HP Buff',
			['description'] = 'Defender HP x ',
			['tips'] = '',
		},
	},
    --Shield Buff   
	['DFShieldBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {2, 4, 6, 8, 10},
		['Percentage'] = {"200%", "400%", "600%", "800%", "1000%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/uef-enhancements/psg_btn_up.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/psg_btn_down.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/psg_btn_down.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/psg_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/uef-enhancements/psg_btn_down.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/psg_btn_down.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/psg_btn_down.dds')},
				{UIUtil.UIFile('/game/uef-enhancements/psg_btn_down.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Defender Shield Buff',
			['description'] = 'Defender Shield HP = Defender HP x ',
			['tips'] = '',
		},
	},
    --Speed Buff   
	['DFSpeedBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {1.2, 1.4, 1.6, 1.8, 2.0},
		['Percentage'] = {"20%", "40%", "60%", "80%", "100%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_up.dds')},
				{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_down.dds')},
				{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_over.dds')},
				{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_dis.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_over.dds')},
				{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_over.dds')},
				{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_over.dds')},
				{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Defender Speed Buff',
			['description'] = 'Defender move speed + ',
			['tips'] = '',
		},
	},
}

local vzAbility = 1
local WepAbility = {0,1,2,2,6,6,2}
local WepTable = {1, 2, 3, 4, 5, 6, 7}
WepActiveTable = {1}

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

function CreateButtons(leftBG, rightBG, intAbility)
    if DefenderThread == false then
	    CreateDefender(leftBG, rightBG, intAbility)
	else
	    CreateSiloSupplyButton(leftBG, intAbility)
		CreateHealthSupplyButton(leftBG, intAbility)
		ForkThread(function()
		    for i, key in ipairs(leftButtons) do
			    CreateLeftButton(leftBG, i, key, DFTab[key]['Table'][1], intAbility)
			end
		end)
		CreateVZButton(leftBG, intAbility)
		
		#Hero weapons
		ForkThread(function()
		    for k, v in WepTable do 
			    CreateHeroWepButton(rightBG, v, intAbility)
			end
			for k, v in WepActiveTable do 
			    CreateHeroWepActiveButton(rightBG, v, intAbility)
			end
		end)
	end
end

function CreateDefender(leftBG, rightBG, intAbility)
    defenderButton = Button(
	        leftBG, 
	        UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'), 
		    UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'), 
		    UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'), 
		    UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds')
	    )
	
	LayoutHelpers.AtCenterIn(defenderButton, leftBG)
	defenderButton.Top:Set(function() return leftBG.Top() + 5*scale end)
	defenderButton.Width:Set(40*scale)
	defenderButton.Height:Set(40*scale)
	defenderButton.Depth:Set(leftBG.Depth()+ 1)
	
	local title = 'Call for Defender'
	local description = 'A commander type of defender, upgradable'
	local tips = ''
	defenderButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(defenderButton, leftBG, DefenderAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    defenderButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
		
	defenderButton.OnClick = function()
	    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < DefenderAbility then
		    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else			
		    local ID = 'FPSFAHERO'
			ForkThread(function()
			    DefenderHandler(ID, defenderButton, leftBG, rightBG, intAbility)
			end)
			#PlayVoice(sysEnable)
			AbilitySpent = AbilitySpent + DefenderAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities

		end
	end
end

function CreateHealthSupplyButton(leftBG, intAbility)
	local healthButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/orders/repair_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/repair_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/repair_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/repair_btn_sel.dds')
	)
	
	LayoutHelpers.AtCenterIn(healthButton, leftBG)
	healthButton.Top:Set(function() return leftBG.Top() + 50*scale end)
	healthButton.Width:Set(48*scale)
	healthButton.Height:Set(48*scale)
	healthButton.Depth:Set(leftBG.Depth()+ 1)
	
	local title = '10K HP for Defender'
	local description = '10K HP for Defender, put it near defender'
	local tips = ''
	healthButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(healthButton, leftBG, HealthSupplyAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    healthButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	healthButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < HealthSupplyAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = 'health01'
			--ForkThread(function()
			    FieldSupportHandler(ID)
				#PlayVoice(sysEnable)
			--end)
			AbilitySpent = AbilitySpent + HealthSupplyAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
end

function CreateSiloSupplyButton(leftBG, intAbility)
	local siloButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/orders/tactical_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/tactical_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/tactical_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/tactical_btn_sel.dds')
	)
	
	LayoutHelpers.AtCenterIn(siloButton, leftBG)
	siloButton.Top:Set(function() return leftBG.Top() + 5*scale end)
	siloButton.Width:Set(48*scale)
	siloButton.Height:Set(48*scale)
	siloButton.Depth:Set(leftBG.Depth()+ 1)
	
	local title = 'Ammo for Defender'
	local description = '199 ammo for Defender, put it near defender'
	local tips = ''
	siloButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(siloButton, leftBG, SiloSupplyAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    siloButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	siloButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < SiloSupplyAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = 'ammo01'
			--ForkThread(function()
			    FieldSupportHandler(ID)
				#PlayVoice(sysEnable)
			--end)
			AbilitySpent = AbilitySpent + SiloSupplyAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
end

function CreateLeftButton(leftBG, i, key, num, intAbility)
    local button
	local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
    if num <= buffLvl then
	    button = Button(
	        leftBG, 
			DFTab[key]['Button']['Inactive'][1], 
			DFTab[key]['Button']['Inactive'][2], 
			DFTab[key]['Button']['Inactive'][3], 
			DFTab[key]['Button']['Inactive'][4] 
		)
	else
	    button = Button(
	        leftBG, 
			DFTab[key]['Button']['Active'][3], 
			DFTab[key]['Button']['Active'][3], 
			DFTab[key]['Button']['Active'][3], 
			DFTab[key]['Button']['Active'][3] 
		)
	end 
	local tempTable = {}
	tempTable = {
	    button = button,
		ID = num,
	}
	LayoutHelpers.AtCenterIn(tempTable.button, leftBG)
	local topdist = (100+(50*i - 50))*scale
	button.Top:Set(function() return leftBG.Top() + topdist end)
	tempTable.button.Width:Set(48*scale)
	tempTable.button.Height:Set(48*scale)
	tempTable.button.Depth:Set(leftBG.Depth()+ 1)
	
	tempTable.button.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
			CreateABDialog(button, leftBG, DFTab[key]['Ability'][1]*num, DFTab[key]['Text']['title'], DFTab[key]['Text']['description']..DFTab[key]['Percentage'][num], DFTab[key]['Text']['tips'])
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    tempTable.button.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	tempTable.button.OnClick = function()
	    if tempTable.ID > buffLvl then
		    --do nothing
		else
		    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
			if currentAbilities < DFTab[key]['Ability'][1]*num then
			    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
			else
			    SimCallback({Func = 'Pass'..key, Args = DFTab[key]['Multi'][1]*num})
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + DFTab[key]['Ability'][1]*num
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				currentAbilities = leftAbilities
				table.removeByValue(DFTab[key]['Table'], tempTable.ID)
				table.insert(DFTab[key]['Table'], tempTable.ID + 1)
				tempTable.button:Destroy()
				CreateLeftButton(leftBG, i, key, DFTab[key]['Table'][1], intAbility)
			end
		end
	end	
end

function CreateVZButton(leftBG, intAbility)
    if vzDroneActive == true then
	    local skin = UIUtil.UIFile('/game/orders/intel_btn_down.dds')
	    vzButton = Button(leftBG, skin, skin, skin, skin)
	else
	    vzButton = Button(
	        leftBG, 
	        UIUtil.UIFile('/game/orders/intel_btn_dis.dds'),  
		    UIUtil.UIFile('/game/orders/intel_btn_dis.dds'), 
		    UIUtil.UIFile('/game/orders/intel_btn_dis.dds'), 
		    UIUtil.UIFile('/game/orders/intel_btn_dis.dds')
	    )
	end

	LayoutHelpers.AtCenterIn(vzButton, leftBG)
	vzButton.Top:Set(function() return leftBG.Top() + 250*scale end)
	vzButton.Width:Set(48*scale)
	vzButton.Height:Set(48*scale)
	vzButton.Depth:Set(leftBG.Depth()+ 1)
	
	local title = 'Vision & Shield'
	local description = 'Vision, radar, omni, shield cube'
	local tips = ''
	vzButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(vzButton, leftBG, vzAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    vzButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	vzButton.OnClick = function()
		if vzDroneActive == true then
		    --do nothing
		else
		    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		    if currentAbilities < vzAbility then
				import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		    else
				SimCallback({Func = 'DefenderVZ'})
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + vzAbility
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				vzDroneActive = true
				currentAbilities = leftAbilities
				vzButton:Destroy()
				CreateVZButton(leftBG, intAbility)
			end
		end
	end
end

function CreateHeroWepButton(rightBG, num, intAbility)
	local wepButton = Button(
	    rightBG, 
		iconsTable[num], 
		iconsTable[num], 
		iconsTable[num], 
		iconsTable[num]
	)
	local z = (5 + (num-1)*48)*scale
	LayoutHelpers.AtCenterIn(wepButton, rightBG)
	wepButton.Top:Set(function() return rightBG.Top() + z end)
	wepButton.Width:Set(40*scale)
	wepButton.Height:Set(40*scale)
	wepButton.Depth:Set(rightBG.Depth()+ 1)
	
	local title = 'Defender Weapon'
	local description = 'Active the weapon for Defender'
	local tips = ''
	wepButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(wepButton, rightBG, WepAbility[num], title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    wepButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	wepButton.OnClick = function()		
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < WepAbility[num] then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			ForkThread(function()
			    local wepActive = num
			    import('/mods/Research FAF/lua/ui/FPSKeysControl.lua').WeaponAvailable(wepActive)
				PlayVoice(sysEnable)
				WaitSeconds(.1)
				import('/mods/Research FAF/lua/ui/FPSKeysControl.lua').ChangeWeapon(wepActive)
			end)
			AbilitySpent = AbilitySpent + WepAbility[num]
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
			table.removeByValue(WepTable, num)
			table.insert(WepActiveTable, num)
			wepButton:Destroy()
			CreateHeroWepActiveButton(rightBG, num, intAbility)
		end
	end

end

function CreateHeroWepActiveButton(rightBG, num, intAbility)
    local wepactiveButton = Button(
	    rightBG, 
		iconsTable[num], 
		iconsTable[num], 
		iconsTable[num], 
		iconsTable[num]
	)
	local z = (5 + (num-1)*48)*scale
	LayoutHelpers.AtCenterIn(wepactiveButton, rightBG)
	wepactiveButton.Top:Set(function() return rightBG.Top() + z end)
	wepactiveButton.Width:Set(40*scale)
	wepactiveButton.Height:Set(40*scale)
	wepactiveButton.Depth:Set(rightBG.Depth()+ 1)
	
	local title = 'Use This Weapon'
	local description = 'Click to use this weapon'
	local tips = ''
	wepactiveButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(wepactiveButton, rightBG, 0, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    wepactiveButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	wepactiveButton.OnClick = function()		
	    local wepActive = num
		PlayVoice(sysEnable)
		import('/mods/Research FAF/lua/ui/FPSKeysControl.lua').ChangeWeapon(wepActive)
	end
end

--special thanks to CDRMV, the author of Commander Survival Kit
function DefenderHandler(ID, defenderButton, leftBG, rightBG, intAbility)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			ForkThread(function()
			    --local cmd = 'CreateUnit ' .. ID .. ' ' .. (GetFocusArmy() -1)
			    --ConExecuteSave(cmd) -- require CheatOn
				local position = GetMouseWorldPos()
				SimCallback({Func = 'PassFieldSupports', Args = {id = ID, pos = position}})
			    ID = nil
			end)
			ForkThread(function()
			    DefenderThread = true
				defenderButton:Destroy()
				CreateButtons(leftBG, rightBG, intAbility)
				import('/mods/Research FAF/lua/ui/FPSHero.lua').CreateUI()
			end)
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

--special thanks to CDRMV, the author of Commander Survival Kit
function FieldSupportHandler(ID)
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

function NotifyAllPanels(spent) 
	import('/mods/Research FAF/lua/ui/AbilityMenu.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/EnhPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/FieldPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/IntelPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/SWPPanel.lua').SpentAbility(spent)
end

function CreateABDialog(curBtn, bg, AB, title, description, tips)
	import('/mods/Research FAF/lua/ui/TipsDialogs.lua').Initial(curBtn, bg, AB, title, description, tips)
end

function KillABDialog()
    import('/mods/Research FAF/lua/ui/TipsDialogs.lua').KillABDialog()
end

function DefenderLost(death)
	PlayVoice(Sound({Cue = 'XGG_HQ_GD1_04222', Bank = 'XGG'}))
	import('/mods/Research FAF/lua/ui/FPSHero.lua').DestroyPanel()
	DefenderThread = false		
	vzDroneActive = false
	import('/mods/Research FAF/lua/ui/AbilityMenu.lua').abilityButton:OnClick()
	ForkThread(function()
		RestoreDefenderSettings()
	end)
end

function RestoreDefenderSettings()
    local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
	for i = 1, (buffLvl+1) do
        table.removeByValue(HeroHealthTable, i)
		table.removeByValue(HeroShieldTable, i)
		table.removeByValue(HeroSpeedTable, i)
        table.removeByValue(WepTable, i)
		table.insert(WepTable, i)
		table.removeByValue(WepActiveTable, i)
	end
	table.insert(HeroHealthTable, 1)
	table.insert(HeroShieldTable, 1)
	table.insert(HeroSpeedTable, 1)
	table.insert(WepActiveTable, 1)
    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').DFwindow:SetSolidColor('1acccccc')
end