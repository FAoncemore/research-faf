local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Prefs = import('/lua/user/prefs.lua')
local cmdMode = import('/lua/ui/game/commandmode.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1
local BitmapCombo = import('/lua/ui/controls/combo.lua').BitmapCombo

local sysEnable = Sound({Bank = 'XGG', Cue = 'Computer_Computer_Basic_Orders_01173'})

--repair
local RegenAbility = 1

--reinforcements
local ReinforcementsAbility = 6
local reinforcementsThread = false

local AbilityGenerated = 0
local AbilityCollected = 0
local AbilitySpent = 0

local reinforcementsButton
local regenButton

local factionBmps = {
    '/faction_icon-sm/uef_ico.dds',
	'/faction_icon-sm/aeon_ico.dds',
	'/faction_icon-sm/cybran_ico.dds',
	'/faction_icon-sm/seraphim_ico.dds'
}

local EngID = {
    ['u'] = 'UEL0105',
	['a'] = 'UAL0105',
	['c'] = 'URL0105',
	['s'] = 'XSL0105'
}

local factionIcon = {}

function SetAvailableEng(index)
    ForkThread(function()
	    table.removeByValue(factionIcon, factionBmps[index])
		table.insert(factionIcon, factionBmps[index])
		local bpVoice = Sound({Bank = 'XGG', Cue = 'Computer_Computer_UnitRevalation_01370'})
		PlayVoice(bpVoice)
	end)
end

local FieldButtons = {'Assult', 'Shield', 'AA', 'Eng'}
local EngButtons = {'T1', 'T2', 'T3', 'Sub'}

local FieldUnits = {
    ['Assult'] = {
	    ['Ability'] = {2},
		['ID'] = {
		    {'UEL0303'},
			{'UAL0303'},
			{'URL0303'},
			{'XSL0303'},
		},
		['Text'] = { 
		    ['title'] = 'Remote Filed Assault Unit',
			['description'] = 'Purchase a filed support T3 land unit',
			['tips'] = '',
		},
	},
    ['Shield'] = {
	    ['Ability'] = {1},
		['ID'] = {
			{'UEL0307'},
			{'UAL0307'},
			{'URL0306'},
			{'XSL0307'},
		},
		['Text'] = { 
		    ['title'] = 'Remote Field Mobile Shield',
			['description'] = 'Purchase a filed mobile shield or stealth',
			['tips'] = '',
		},
	},
    ['AA'] = {
	    ['Ability'] = {1},
		['ID'] = {
			{'UEL0205'},
			{'UAL0205'},
			{'URL0205'},
			{'XSL0205'},
		},
		['Text'] = { 
		    ['title'] = 'Remote Field Mobile AA',
			['description'] = 'Purchase a filed mobile AA unit',
			['tips'] = '',
		},
	},
    ['Eng'] = {
	    ['T1'] = {
		    ['Ability'] = {1},
			['ID'] = {
			    {'UEL0105'},
				{'UAL0105'},
				{'URL0105'},
				{'XSL0105'},
			},
			['Text'] = { 
			    ['title'] = 'Remote Field Mobile AA',
				['description'] = 'Purchase a filed mobile AA unit',
				['tips'] = '',
			},
		},
	},
}
local EngUnits = {
    ['T1'] = {
	    ['Ability'] = {1},
		['ID'] = {
		    {'UEL0105'},
			{'UAL0105'},
			{'URL0105'},
			{'XSL0105'},
		},
		['Text'] = { 
		    ['title'] = 'T1 Engineer',
			['description'] = 'Purchase one T1 engineer',
			['tips'] = '',
		},
	},
    ['T2'] = {
	    ['Ability'] = {2},
		['ID'] = {
		    {'UEL0208'},
			{'UAL0208'},
			{'URL0208'},
			{'XSL0208'},
		},
		['Text'] = { 
		    ['title'] = 'T2 Engineer',
			['description'] = 'Purchase one T2 engineer',
			['tips'] = '',
		},
	},
    ['T3'] = {
	    ['Ability'] = {3},
		['ID'] = {
		    {'UEL0309'},
			{'UAL0309'},
			{'URL0309'},
			{'XSL0309'},
		},
		['Text'] = { 
		    ['title'] = 'T3 Engineer',
			['description'] = 'Purchase one T3 engineer',
			['tips'] = '',
		},
	},
    ['Sub'] = {
	    ['Ability'] = {9},
		['ID'] = {
		    {'UEL0301'},
			{'UAL0301'},
			{'URL0301'},
			{'XSL0301'},
		},
		['Text'] = { 
		    ['title'] = 'Sub-Commander',
			['description'] = 'Purchase one T3 Support Armored Commander',
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
    --field buttons
    ForkThread(function()
	    for i, key in ipairs(FieldButtons) do
			CreateFieldButton(leftBG, rightBG, i, key, intAbility)
        end
	end)
	CreateFieldRegen(leftBG, rightBG, intAbility)
	CreateReinforcements(leftBG, rightBG, intAbility)
	CreateMarkUnitButton(leftBG, rightBG, intAbility)

    --engineer buttons
    ForkThread(function()
	    for i, key in ipairs(EngButtons) do
			CreateEngButton(rightBG, i, key, intAbility)
        end
	end)
	
	--blueprints from acu killed
	ForkThread(function()
	    --Task tips
		local tipsBG = CreateTaskTips(rightBG)
	    if table.getn(factionIcon) > 0 then CreateTask(tipsBG) end
	end)
end

function CreateFieldButton(leftBG, rightBG, index, key, intAbility)
    local icon = UIUtil.UIFile('/icons/units/default_icon.dds')
	local currentFaction = GetArmiesTable().armiesTable[GetFocusArmy()].faction + 1
	icon = UIUtil.UIFile('/icons/units/'..FieldUnits[key]['ID'][currentFaction][1]..'_icon.dds')
	local button = Button(
	    leftBG, 
	    icon, 
		icon, 
		icon, 
		icon
	)
	
	LayoutHelpers.AtCenterIn(button, leftBG)
	local topdist = (5+(50*index - 50))*scale
	button.Top:Set(function() return leftBG.Top() + topdist end)
	button.Width:Set(40*scale)
	button.Height:Set(40*scale)
	button.Depth:Set(leftBG.Depth() + 1)

	button.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
			CreateABDialog(button, rightBG, FieldUnits[key]['Ability'][1], FieldUnits[key]['Text']['title'], FieldUnits[key]['Text']['description'], FieldUnits[key]['Text']['tips'])
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    button.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	button.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < FieldUnits[key]['Ability'][1] then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			local unitID = FieldUnits[key]['ID'][currentFaction][1]
			FieldSupportHandler(unitID)
			AbilitySpent = AbilitySpent + FieldUnits[key]['Ability'][1]
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
end

function CreateFieldRegen(leftBG, rightBG, intAbility)
    regenButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/seraphim-enhancements/anrf_btn_up.dds'), 
		UIUtil.UIFile('/game/seraphim-enhancements/anrf_btn_down.dds'), 
		UIUtil.UIFile('/game/seraphim-enhancements/anrf_btn_over.dds'), 
		UIUtil.UIFile('/game/seraphim-enhancements/anrf_btn_sel.dds')
	)
	
	LayoutHelpers.AtCenterIn(regenButton, leftBG)
	regenButton.Top:Set(function() return leftBG.Top() + 150*scale end)
	regenButton.Width:Set(48*scale)
	regenButton.Height:Set(48*scale)
	regenButton.Depth:Set(leftBG.Depth() + 1)
	
	local title = 'Remote Field Repair Assitant'
	local description = 'Install repair module for units in 25 range'
	local tips = ''
	regenButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(regenButton, rightBG, RegenAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    regenButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	regenButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < RegenAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			local range = 25
			ForkThread(function()
				FieldRegen(range)
			end)
			AbilitySpent = AbilitySpent + RegenAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreateReinforcements(leftBG, rightBG, intAbility)
    if reinforcementsThread == true then
	    local skin = UIUtil.UIFile('/mods/Research FAF/textures/ui/common/panel/uef_ico.png')
	    reinforcementsButton = Button(leftBG, skin, skin, skin, skin)
	else
	    reinforcementsButton = Button(
	        leftBG, 
	        UIUtil.UIFile('/mods/Research FAF/textures/ui/common/panel/uef2_ico.png'), 
		    UIUtil.UIFile('/mods/Research FAF/textures/ui/common/panel/uef_ico.png'), 
		    UIUtil.UIFile('/mods/Research FAF/textures/ui/common/panel/uef_ico.png'), 
		    UIUtil.UIFile('/mods/Research FAF/textures/ui/common/panel/uef_ico.png')
	    )
	end
	
	LayoutHelpers.AtCenterIn(reinforcementsButton, leftBG)
	reinforcementsButton.Top:Set(function() return leftBG.Top() + 200*scale end)
	reinforcementsButton.Width:Set(48*scale)
	reinforcementsButton.Height:Set(48*scale)
	reinforcementsButton.Depth:Set(leftBG.Depth() + 1)
	
	local title = 'Reinforcements'
	local description = 'Call for reinforcements in 5 mins'
	local tips = ''
	reinforcementsButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(reinforcementsButton, rightBG, ReinforcementsAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    reinforcementsButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	reinforcementsButton.OnClick = function()
	    if reinforcementsThread == true then
		    --do nothing
		else
		    local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		    if currentAbilities < ReinforcementsAbility then
				import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		    else
				import('/mods/Research FAF/lua/ui/Reinforcement.lua').CreateUI()
				PlayVoice(sysEnable)
				AbilitySpent = AbilitySpent + ReinforcementsAbility
				NotifyAllPanels(AbilitySpent)
				local leftAbilities = AbilityCollected + intAbility - AbilitySpent
				reinforcementsThread = true
				currentAbilities = leftAbilities
				reinforcementsButton:Destroy()
				CreateReinforcements(leftBG, rightBG, intAbility)
			end
		end
	end
end

local markBmps = {
    '/game/strategicicons/icon_objective_primary_over.dds',
	'/game/strategicicons/icon_objective_secondary_over.dds',
}

local markIndex = {
    'icon_objective_primary',
	'icon_objective_secondary',
}
function CreateMarkUnitButton(leftBG, rightBG, intAbility)
	local markUnit = BitmapCombo(leftBG, markBmps, 1, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	LayoutHelpers.AtLeftTopIn(markUnit, leftBG, 2, 2)
	markUnit.Top:Set(function() return leftBG.Top() + 250*scale end)
	markUnit.Depth:Set(function() return leftBG.Depth() + 1 end)
	markUnit.Width:Set(48)
	markUnit.OnClick = function(self, index)
	    ForkThread(function()
		    local units = GetSelectedUnits()
			if units then
			    local unitIds = {}
				for _, unit in units do
				    table.insert(unitIds, unit:GetEntityId())
				end
				SimCallback({Func = 'MarkSelectedUnits', Args =  {id = unitIds, tag = markIndex[index]}})
				PlayVoice(sysEnable)
			end
		end)
	end
	Tooltip.AddControlTooltip(markUnit, 'Mark selected units for easy identity')
end

function CreateEngButton(rightBG, index, key, intAbility)
    local icon = UIUtil.UIFile('/icons/units/default_icon.dds')
	local currentFaction = GetArmiesTable().armiesTable[GetFocusArmy()].faction + 1
	icon = UIUtil.UIFile('/icons/units/'..EngUnits[key]['ID'][currentFaction][1]..'_icon.dds')
	local button = Button(
	    rightBG, 
	    icon, 
		icon, 
		icon, 
		icon
	)
	
	LayoutHelpers.AtCenterIn(button, rightBG)
	local topdist = (5+(50*index - 50))*scale
	button.Top:Set(function() return rightBG.Top() + topdist end)
	button.Width:Set(40*scale)
	button.Height:Set(40*scale)
	button.Depth:Set(rightBG.Depth() + 1)

	button.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
			CreateABDialog(button, rightBG, EngUnits[key]['Ability'][1], EngUnits[key]['Text']['title'], EngUnits[key]['Text']['description'], EngUnits[key]['Text']['tips'])
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    button.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	button.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < EngUnits[key]['Ability'][1] then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			local unitID = EngUnits[key]['ID'][currentFaction][1]
			FieldSupportHandler(unitID)
			AbilitySpent = AbilitySpent + EngUnits[key]['Ability'][1]
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
end

function CreateTaskTips(rightBG)
	local tipsBG = Bitmap(rightBG)
	tipsBG:SetSolidColor('ff333333')
	LayoutHelpers.AtLeftTopIn(tipsBG, rightBG, 5)
	tipsBG.Top:Set(function() return rightBG.Top() + 200*scale end)
	tipsBG.Width:Set(44*scale)
	tipsBG.Height:Set(105*scale)
	tipsBG.Depth:Set(function() return rightBG.Depth() + 2 end)
	
	tipsBG.border = Bitmap(tipsBG)
	--local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	tipsBG.border:SetSolidColor('7fffffff')
	tipsBG.border.Left:Set(function() return tipsBG.Left() - 1*scale end)
	tipsBG.border.Top:Set(function() return tipsBG.Top() - 1*scale end)
	tipsBG.border.Width:Set(function() return tipsBG.Width() + 2*scale end)
	tipsBG.border.Height:Set(function() return tipsBG.Height() + 2*scale end)
	tipsBG.border.Depth:Set(function() return tipsBG.Depth() - 1 end)
	
	local title = 'ACU Task'
	local description = 'Kill an ACU and get its blueprint'
	local tips = ''
	tipsBG.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(tipsBG, rightBG, 0, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	return tipsBG
end

function CreateTask(tipsBG)
	local taskOption = BitmapCombo(tipsBG, factionIcon, 1, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	LayoutHelpers.AtLeftTopIn(taskOption, tipsBG, 2, 2)
	taskOption.Depth:Set(function() return tipsBG.Depth() + 2 end)
	taskOption.Width:Set(40)
	taskOption.OnClick = function(self, index)
	    ForkThread(function()
		    local code = string.sub(factionIcon[index], 18, 18) --u, a, c, s
			local unitID = EngID[code]
			FieldSupportHandler(unitID)
		end)
	end
	Tooltip.AddControlTooltip(taskOption, 'Blueprint from ACU killed')
end

function NotifyAllPanels(spent) 
	import('/mods/Research FAF/lua/ui/AbilityMenu.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/EnhPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/IntelPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/SWPPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/DFPanel.lua').SpentAbility(spent)
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

function FieldRegen(range)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'PassFieldRegen', Args = {radius = range, pos = position}},true)
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