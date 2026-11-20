local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Prefs = import('/lua/user/prefs.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1
local sysEnable = Sound({Bank = 'XGG', Cue = 'Computer_Computer_Basic_Orders_01173'})

local AbilityGenerated = 0
local AbilityCollected = 0
local AbilitySpent = 0

local resbalanceButton
local ShieldbuffButton
local buildratebuffButton
local killreclaimButton
local estorageButton
local SpeedButton

local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl

local BuildrateBuffTable = {1}
local buildratebuffPercentage = {"20%", "40%", "60%", "80%", "100%"}
local buildratebuffMulti = {0.2, 0.4, 0.6, 0.8, 1.0}
local buildratebuffAbility = {2,4,6,8,10}
local buildratebufficonsTable = {	
	{UIUtil.UIFile('/game/seraphim-enhancements/efm_btn_up.dds')},
	{UIUtil.UIFile('/game/seraphim-enhancements/efm_btn_down.dds')},
	{UIUtil.UIFile('/game/seraphim-enhancements/efm_btn_over.dds')},
	{UIUtil.UIFile('/game/seraphim-enhancements/efm_btn_sel.dds')}
}

local SpeedTable = {1}
local SpeedPercentage = {"20%", "40%", "60%", "80%", "100%"}
local SpeedMulti = {1.2, 1.4, 1.6, 1.8, 2.0}
local SpeedAbility = {2,4,6,8,10}
local SpeediconsTable = {	
	{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_up.dds')},
	{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_down.dds')},
	{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_over.dds')},
	{UIUtil.UIFile('/small-vert_scroll-uef/arrow-up_scr_dis.dds')}
}

local balanceThread = false
local kcThread = false

local ResourceBalanceAbility = 2
local KillReclaimAbility = 3
local GiveMassAbility = 4
local GiveEnergyStorageAbility = 5

local leftButtons = {'ResBuff'}
local rightButtons = {'HPBuff', 'ShieldBuff', 'ROFBuff', 'DamageBuff', 'RangeBuff', 'VizBuff', 'VetBuff'}

local EnhTab = {
    --Left buttons
    --Resources Buff   
	['ResBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {0.2, 0.4, 0.6, 0.8, 1.0},
		['Percentage'] = {"20%", "40%", "60%", "80%", "100%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_up.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_down.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/ras_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Resources Buff',
			['description'] = 'Mass & Energy output + ',
			['tips'] = '',
		},
	},
	
    --Right buttons
    --Health Buff   
	['HPBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {0.2, 0.4, 0.6, 0.8, 1.0},
		['Percentage'] = {"20%", "40%", "60%", "80%", "100%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_up.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_down.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/dss_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Health Buff',
			['description'] = 'Mobile units HP + ',
			['tips'] = 'Affects only new-built units',
		},
	},
    --Shield Buff   
	['ShieldBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {0.2, 0.4, 0.6, 0.8, 1.0},
		['Percentage'] = {"20%", "40%", "60%", "80%", "100%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_up.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_down.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/sp_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Shield & Buff',
			['description'] = 'Mobile units personal shield, HP = unit HP x ',
			['tips'] = 'Select an unit & Alt-I to show shield value',
		},
	},
    --Rate of Fire Buff   
	['ROFBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {0.1, 0.2, 0.3, 0.4, 0.5},
		['Percentage'] = {"10%", "20%", "30%", "40%", "50%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_up.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_down.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/hsa_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Rate of Fire Buff',
			['description'] = 'Certain mobile units ROF + ',
			['tips'] = '',
		},
	},
    --Damage Buff   
	['DamageBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {0.2, 0.4, 0.6, 0.8, 1.0},
		['Percentage'] = {"20%", "40%", "60%", "80%", "100%"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_up.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_down.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/seraphim-enhancements/cba_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Damage Buff',
			['description'] = 'Certain mobile units damage + ',
			['tips'] = '',
		},
	},
    --Range Buff   
	['RangeBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {0.1, 0.2, 0.3, 0.4, 0.5},
		['Percentage'] = {"10%", "20%", "30%", "40%", "50%"},
		['Ability'] = {1,2,3,4,5},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/aeon-enhancements/cba_btn_up.dds')},
				{UIUtil.UIFile('/game/aeon-enhancements/cba_btn_down.dds')},
				{UIUtil.UIFile('/game/aeon-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/aeon-enhancements/cba_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/aeon-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/aeon-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/aeon-enhancements/cba_btn_over.dds')},
				{UIUtil.UIFile('/game/aeon-enhancements/cba_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Weapon Range Buff',
			['description'] = 'Certain mobile units wep range + ',
			['tips'] = '',
		},
	},
    --Vision Buff   
	['VizBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {0.1, 0.2, 0.3, 0.4, 0.5},
		['Percentage'] = {"10%", "20%", "30%", "40%", "50%"},
		['Ability'] = {1,2,3,4,5},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_up.dds')},
				{UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_down.dds')},
				{UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_over.dds')},
				{UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_sel.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_over.dds')},
				{UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_over.dds')},
				{UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_over.dds')},
				{UIUtil.UIFile('/game/cybran-enhancements/cfs_btn_over.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Vision Buff',
			['description'] = 'Certain mobile units vision range + ',
			['tips'] = '',
		},
	},
    --Veterancy Buff   
	['VetBuff'] = {
	    --tables
		['Table'] = {1},
		['Multi'] = {1, 2, 3, 4, 5},
		['Percentage'] = {"1", "2", "3", "4", "5"},
		['Ability'] = {2,4,6,8,10},
		--button
	    ['Button'] = {
		    --inactive
		    ['Inactive'] = {
			    {UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
				{UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
				{UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
				{UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
			},
		    ['Active'] = {
			    {UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
				{UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
				{UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
				{UIUtil.UIFile('/game/veteran-logo_bmp/uef-veteran_bmp.dds')},
			},
		},
		--text
		['Text'] = { 
		    ['title'] = 'Veterancy Buff',
			['description'] = '(Max 5)Certain mobile units Vet = ',
			['tips'] = '',
		},
	},
}

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
    --left buttons
    ForkThread(function()
	    for i, key in ipairs(leftButtons) do
			CreateLeftButton(leftBG, rightBG, i, key, EnhTab[key]['Table'][1], intAbility)
        end
	end)
	CreateResourceBalanceButton(leftBG, rightBG, intAbility)
	CreateKillReclaimButton(leftBG, rightBG, intAbility)
	CreateGiveEnergyStorageButton(leftBG, rightBG, intAbility)
	CreateBuildrateBuffButton(leftBG, rightBG, BuildrateBuffTable[1], intAbility)
	CreateSpeedBuffButton(leftBG, SpeedTable[1],  intAbility)
	
	--right buttons
    ForkThread(function()
	    for i, key in ipairs(rightButtons) do
			CreateRightButton(rightBG, i, key, EnhTab[key]['Table'][1], intAbility)
        end
	end)
end

function CreateLeftButton(leftBG, rightBG, i, key, num, intAbility)
    local button
	local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
    if num <= buffLvl then
	    button = Button(
	        leftBG, 
			EnhTab[key]['Button']['Inactive'][1], 
			EnhTab[key]['Button']['Inactive'][2], 
			EnhTab[key]['Button']['Inactive'][3], 
			EnhTab[key]['Button']['Inactive'][4] 
		)
	else
	    button = Button(
	        leftBG, 
			EnhTab[key]['Button']['Active'][3], 
			EnhTab[key]['Button']['Active'][3], 
			EnhTab[key]['Button']['Active'][3], 
			EnhTab[key]['Button']['Active'][3] 
		)
	end 
	local tempTable = {}
	tempTable = {
	    button = button,
		ID = num,
	}
	LayoutHelpers.AtCenterIn(tempTable.button, leftBG)
	local topdist = (5 + (50*i - 50))*scale
	tempTable.button.Top:Set(function() return leftBG.Top() + topdist end)
	tempTable.button.Width:Set(48*scale)
	tempTable.button.Height:Set(48*scale)
	tempTable.button.Depth:Set(leftBG.Depth() + 1)
	button.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
			CreateABDialog(button, rightBG, EnhTab[key]['Ability'][1]*num, EnhTab[key]['Text']['title'], EnhTab[key]['Text']['description']..EnhTab[key]['Percentage'][num], EnhTab[key]['Text']['tips'])
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
			if currentAbilities < EnhTab[key]['Ability'][1]*num then
			    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
			else
			    SimCallback({Func = 'Pass'..key, Args = EnhTab[key]['Multi'][1]*num})
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + EnhTab[key]['Ability'][1]*num
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				currentAbilities = leftAbilities
				table.removeByValue(EnhTab[key]['Table'], tempTable.ID)
				table.insert(EnhTab[key]['Table'], tempTable.ID + 1)
				tempTable.button:Destroy()
				--updates
				CreateLeftButton(leftBG, rightBG, i, key, EnhTab[key]['Table'][1], intAbility)
			end
		end
	end
end

function CreateRightButton(rightBG, i, key, num, intAbility)
    local button
	local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
    if num <= buffLvl then
	    button = Button(
	        rightBG, 
			EnhTab[key]['Button']['Inactive'][1], 
			EnhTab[key]['Button']['Inactive'][2], 
			EnhTab[key]['Button']['Inactive'][3], 
			EnhTab[key]['Button']['Inactive'][4] 
		)
	else
	    button = Button(
	        rightBG, 
			EnhTab[key]['Button']['Active'][3], 
			EnhTab[key]['Button']['Active'][3], 
			EnhTab[key]['Button']['Active'][3], 
			EnhTab[key]['Button']['Active'][3] 
		)
	end  
	local tempTable = {}
	tempTable = {
	    button = button,
		ID = num,
	}
	LayoutHelpers.AtCenterIn(button, rightBG)
	local topdist = (5 + (50*i - 50))*scale
	button.Top:Set(function() return rightBG.Top() + topdist end)
	tempTable.button.Width:Set(48*scale)
	tempTable.button.Height:Set(48*scale)
	tempTable.button.Depth:Set(rightBG.Depth() + 1)

	button.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(button, rightBG, EnhTab[key]['Ability'][1]*num, EnhTab[key]['Text']['title'], EnhTab[key]['Text']['description']..EnhTab[key]['Percentage'][num], EnhTab[key]['Text']['tips'])
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    button.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	tempTable.button.OnClick = function()
	    if tempTable.ID > buffLvl then
		    --do nothing
		else
		    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
			if currentAbilities < EnhTab[key]['Ability'][1]*num then
			    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
			else
			    SimCallback({Func = 'Pass'..key, Args = EnhTab[key]['Multi'][1]*num})
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + EnhTab[key]['Ability'][1]*num
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				currentAbilities = leftAbilities
				table.removeByValue(EnhTab[key]['Table'], tempTable.ID)
				table.insert(EnhTab[key]['Table'], tempTable.ID + 1)
				tempTable.button:Destroy()
				--updates
				CreateRightButton(rightBG, i, key, EnhTab[key]['Table'][1], intAbility)
			end
		end
	end		
end

function CreateResourceBalanceButton(leftBG, rightBG, intAbility)
    if balanceThread == true then
	    local skin = UIUtil.UIFile('/game/seraphim-enhancements/eras_btn_over.dds')
	    resbalanceButton = Button(leftBG, skin, skin, skin, skin)
	else
	    resbalanceButton = Button(
	        leftBG, 
	        UIUtil.UIFile('/game/seraphim-enhancements/eras_btn_up.dds'), 
		    UIUtil.UIFile('/game/seraphim-enhancements/eras_btn_down.dds'), 
		    UIUtil.UIFile('/game/seraphim-enhancements/eras_btn_over.dds'), 
		    UIUtil.UIFile('/game/seraphim-enhancements/eras_btn_sel.dds')
	    )
	end
	
	LayoutHelpers.AtCenterIn(resbalanceButton, leftBG)
	resbalanceButton.Top:Set(function() return leftBG.Top() + 50*scale end)
	resbalanceButton.Width:Set(48*scale)
	resbalanceButton.Height:Set(48*scale)
	resbalanceButton.Depth:Set(leftBG.Depth() + 1)

	local title = 'Resource Balance'
	local description = 'Auto 1500e to 16m or reverse'
	local tips = 'Turn it off if Paragon (UI/Option/Interface)'
	resbalanceButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(resbalanceButton, rightBG, ResourceBalanceAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    resbalanceButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	resbalanceButton.OnClick = function()
	    if balanceThread == true then
		    --do nothing
		else
			local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		    if currentAbilities < ResourceBalanceAbility then
				import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		    else
				Prefs.SetOption('vo_eco_bal_ex', true)
				SimCallback({Func = 'PassEcoBalanceData'})
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + ResourceBalanceAbility
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				balanceThread = true
				currentAbilities = leftAbilities
				resbalanceButton:Destroy()
				CreateResourceBalanceButton(leftBG, rightBG, intAbility)
			end
		end
	end
end

function CreateKillReclaimButton(leftBG, rightBG, intAbility)
    if kcThread == true then
	    local skin = UIUtil.UIFile('/game/orders/reclaim_btn_over.dds')
	    killreclaimButton = Button(leftBG, skin, skin, skin, skin)
	else
	    killreclaimButton = Button(
	        leftBG, 
	        UIUtil.UIFile('/game/orders/reclaim_btn_up.dds'), 
		    UIUtil.UIFile('/game/orders/reclaim_btn_up_sel.dds'), 
		    UIUtil.UIFile('/game/orders/reclaim_btn_over.dds'), 
		    UIUtil.UIFile('/game/orders/reclaim_btn_over_sel.dds')
	    )
	end
	
	LayoutHelpers.AtCenterIn(killreclaimButton, leftBG)
	killreclaimButton.Top:Set(function() return leftBG.Top() + 100*scale end)
	killreclaimButton.Width:Set(48*scale)
	killreclaimButton.Height:Set(48*scale)
	killreclaimButton.Depth:Set(leftBG.Depth() + 1)
	
	local title = 'Mass from Kills'
	local description = 'Get 5% from killed mass value'
	local tips = ''
	killreclaimButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(killreclaimButton, rightBG, KillReclaimAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    killreclaimButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	killreclaimButton.OnClick = function()
		if kcThread == true then
		    --do nothing
		else
			local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		    if currentAbilities < KillReclaimAbility then
				import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		    else
				SimCallback({Func = 'PassKillReclaimData'})
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + KillReclaimAbility
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility- AbilitySpent
				kcThread = true
				currentAbilities = leftAbilities
				killreclaimButton:Destroy()
				CreateKillReclaimButton(leftBG, rightBG, intAbility)
			end
		end
	end
end

function CreateGiveEnergyStorageButton(leftBG, rightBG, intAbility)
	estorageButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/resources/energy_btn_up.dds'), 
		UIUtil.UIFile('/game/resources/energy_btn_over.dds'), 
		UIUtil.UIFile('/game/resources/energy_btn_down.dds'), 
		UIUtil.UIFile('/game/resources/energy_btn_dis.dds')
	)
	LayoutHelpers.AtCenterIn(estorageButton, leftBG)
	estorageButton.Top:Set(function() return leftBG.Top() + 150*scale end)
	estorageButton.Depth:Set(leftBG.Depth() + 1)
	estorageButton.Width:Set(48*scale)
	estorageButton.Height:Set(48*scale)
	
	local title = '50K Energy Storage'
	local description = 'Purchase 50K Energy Storage'
	local tips = ''
	estorageButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(estorageButton, rightBG, GiveEnergyStorageAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    estorageButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	estorageButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < GiveEnergyStorageAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			ForkThread(function()
				SimCallback({Func = 'PassGiveEnergyStorageData', Args = {id = "Energy", qty = 500000}})
				PlayVoice(sysEnable)
			end)
			AbilitySpent = AbilitySpent + GiveEnergyStorageAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility- AbilitySpent
			currentAbilities = leftAbilities
		end
	end

end

function CreateBuildrateBuffButton(leftBG, rightBG, num, intAbility)
    local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
	if num <= buffLvl then
	    buildratebuffButton = Button(
	        leftBG, 
			buildratebufficonsTable[1],
			buildratebufficonsTable[2],
			buildratebufficonsTable[3],  
			buildratebufficonsTable[4]
		)
	else
	    buildratebuffButton = Button(
	        leftBG, 
			buildratebufficonsTable[3],
			buildratebufficonsTable[3],
			buildratebufficonsTable[3],  
			buildratebufficonsTable[3]
		)
	end  

	    local tempTable = {}
	    tempTable = {
	    	button = buildratebuffButton,
	    	ID = num,
	    }
	
	    LayoutHelpers.AtCenterIn(buildratebuffButton, leftBG)
		buildratebuffButton.Top:Set(function() return leftBG.Top() + 200*scale end)
		tempTable.button.Width:Set(48*scale)
		tempTable.button.Height:Set(48*scale)
	    tempTable.button.Depth:Set(leftBG.Depth() + 1)
		
	local i = num
	if i > buffLvl then
	    i = buffLvl
	end
	local title = 'Build Rate Buff'
	local tips = ''
	local description = 'Engineer & factory build rate + '..(20*num)..'%'
	buildratebuffButton.HandleEvent = function(self, event)
		if event.Type == 'MouseEnter' then
			CreateABDialog(buildratebuffButton, rightBG, buildratebuffAbility[1]*num, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    buildratebuffButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end

		
	    tempTable.button.OnClick = function()
		    if tempTable.ID > buffLvl then
			    --do nothing
			else
				local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
				if currentAbilities < buildratebuffAbility[1]*num then
				    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
				else
					SimCallback({Func = 'PassbuildratebuffAddData', Args = buildratebuffMulti[1]*num})
				    PlayVoice(sysEnable)
					AbilitySpent = AbilitySpent + buildratebuffAbility[1]*num
				    NotifyAllPanels(AbilitySpent)
				    local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				    currentAbilities = leftAbilities
		            table.removeByValue(BuildrateBuffTable, tempTable.ID)
					table.insert(BuildrateBuffTable, tempTable.ID + 1)
					tempTable.button:Destroy()
					CreateBuildrateBuffButton(leftBG, rightBG, BuildrateBuffTable[1], intAbility)
				end
			end
	    end
	
end

function CreateSpeedBuffButton(leftBG, num,  intAbility)
    local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
	local myLvl = buffLvl
	if buffLvl > 5 then
	    myLvl = 5
	end
    if num <= myLvl then
	    SpeedButton = Button(
	        leftBG, 
			SpeediconsTable[1], 
			SpeediconsTable[2],  
			SpeediconsTable[3],   
			SpeediconsTable[4]
		)
	else
	    SpeedButton = Button(
	        leftBG, 
			SpeediconsTable[3], 
			SpeediconsTable[3],  
			SpeediconsTable[3],   
			SpeediconsTable[3]
		)
	end 

	    local tempTable = {}
	    tempTable = {
	    	button = SpeedButton,
	    	ID = num,
	    }
	
	    LayoutHelpers.AtCenterIn(SpeedButton, leftBG)
		SpeedButton.Top:Set(function() return leftBG.Top() + 260*scale end)
		tempTable.button.Width:Set(36*scale)
		tempTable.button.Height:Set(28*scale)
		tempTable.button.Depth:Set(leftBG.Depth() + 1)
		
	local i = num
	if i > myLvl then
	    i = myLvl
	end
		local title = 'Mobile Speed Buff'
		local description = 'Mobile move speed + '..SpeedPercentage[i]..' (Max +100%)'
		local tips = ''
		tempTable.button.HandleEvent = function(self, event)
		    if event.Type == 'MouseEnter' then
				CreateABDialog(SpeedButton, leftBG, SpeedAbility[1]*num, title, description, tips)
				PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
			elseif event.Type == 'ButtonPress' then
			    tempTable.button.OnClick()
			elseif event.Type == 'MouseExit' then
			    KillABDialog()
			end
		end

		
	    tempTable.button.OnClick = function()
		    if tempTable.ID > myLvl then
		    	--do nothing
		    else
				local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		        if currentAbilities < SpeedAbility[num] then
			    	import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		        else
	                SimCallback({Func = 'PassLandSpeedBuffData', Args = SpeedMulti[num]})
					SimCallback({Func = 'StartLandSpeedBuff', Args = SpeedMulti[num]})
			    	PlayVoice(Sound{Bank = 'XGG', Cue = 'XGG_Computer_CV01_04735'}, true)
			    	AbilitySpent = AbilitySpent + SpeedAbility[num]
				    NotifyAllPanels(AbilitySpent)
			        local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				    currentAbilities = leftAbilities
		            table.removeByValue(SpeedTable, tempTable.ID)
		            table.insert(SpeedTable, tempTable.ID + 1)
					tempTable.button:Destroy()
			    	CreateSpeedBuffButton(leftBG, SpeedTable[1],  intAbility)
				end
			end
	    end

end

function NotifyAllPanels(spent) 
	import('/mods/Research FAF/lua/ui/AbilityMenu.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/FieldPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/IntelPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/SWPPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/DFPanel.lua').SpentAbility(spent)
end

function CreateABDialog(curBtn, bg, AB, title, description, tips)
	import('/mods/Research FAF/lua/ui/TipsDialogs.lua').Initial(curBtn, bg, AB, title, description, tips)
end

function KillABDialog()
    import('/mods/Research FAF/lua/ui/TipsDialogs.lua').KillABDialog()
end