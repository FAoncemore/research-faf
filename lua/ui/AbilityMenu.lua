--*****************************************************************************
--* File: lua/modules/ui/game/chat.lua
--* Author: Chris Blackwell
--* Summary: In game chat ui
--*
--* Copyright © :005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************
local Window = import('/lua/maui/window.lua').Window
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local Prefs = import('/lua/user/prefs.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox

#initial abilities for a new game
###########################
local InitialAbility = import('/mods/Research FAF/lua/ui/InitialData.lua').InitialAbility
local AbilityGenerated = 0
local AbilityCollected = 0
local AbilitySpent = 0
AbilityStorage = 0
###########################

abilityButton = false
abilityButtonCountTable = {1}
local AbilityGeneratedRatio = 0
local AbilityKillsRatio = 0
DFwindow = false
REwindow = false

local KilledCollected = 0

function ResearchLabHandle(generated)
	ForkThread(function()
		AbilityGenerated = generated + AbilityGenerated
	end)
end 

function CollectedAbility(Collected)
	AbilityCollected = Collected + AbilityGenerated
	KilledCollected = Collected
end

function SpentAbility(Spent)
	AbilitySpent = Spent
end

function ResearchLabProgress(ratio)
	AbilityGeneratedRatio = ratio
end 

function ResearchKillsProgress(ratio)
	AbilityKillsRatio = ratio
end 

GUI = {
    bg = false,
	abBG = false,
	abilityText = 3,
	CloseBtn = false,
	ResBtn = false,
	ConfBtn = false,
}

function Initial()
    if GUI.bg then end
	GUI.bg = CreateABWindow()
end

function ShowMenu()
    if GUI.bg:IsHidden() then 
	    GUI.bg:Show()
		local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
		GUI.abBG:SetSolidColor(bgColor)
		GUI.CloseBtn:Hide()
		GUI.ResBtn:Hide()
		--GUI.ConfBtn:Hide()
	elseif not GUI.bg:IsHidden() then 
	    GUI.bg:Hide() 
	end
end 

function CreateABWindow()
	local location = {
	    Top = function() return GetFrame(0).Top() + 70*scale end,
        Left = function() return GetFrame(0).Left() + 15*scale end,
        Right = function() return GetFrame(0).Left() + 165*scale end,
        Bottom = function() return GetFrame(0).Top() + 135*scale end
	}
    local windowTextures = {
        borderColor = 'ffffffff',
    }
    local bg = Window(GetFrame(0), '       ', nil, nil, true, true, nil, '', nil, windowTextures, location)
    bg.Depth:Set(1)

    bg.ResetPositionBtn = Button(bg,
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_up.dds'),
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_down.dds'),
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_over.dds'),
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_dis.dds'))
	--bg._configBtn:Hide()
	LayoutHelpers.AtCenterIn(bg.ResetPositionBtn, bg._configBtn) 
    bg.ResetPositionBtn.Depth:Set(function() return bg.Depth() + 10 end)
    bg.ResetPositionBtn.OnClick = function(self, modifiers) 
        for index, position in location do
            local i = index
            local pos = position
            bg[i]:Set(pos)
        end
		bg:SaveWindowLocation()
    end
	
    bg._closeBtn.OnClick = function(self, modifiers) 
	    if GUI.bg then GUI.bg:Hide() end
    end
	
	
	GUI.CloseBtn = bg._closeBtn
	GUI.ResBtn = bg.ResetPositionBtn
	GUI.ConfBtn = bg._configBtn
 
	bg.ResetPositionBtn:OnClick()
	
    GUI.abBG = Bitmap(bg)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	GUI.abBG:SetSolidColor(bgColor)
	GUI.abBG.Width:Set(35*scale)
	GUI.abBG.Height:Set(35*scale)
	LayoutHelpers.AtLeftTopIn(GUI.abBG, bg, 0, 25)
	GUI.abBG.Depth:Set(function() return bg.Depth() + 1 end)
	bg._title.Left:Set(function() return GUI.abBG.Left() end)
	bg.ResetPositionBtn:Hide()
	bg._closeBtn:Hide()
	
    bg._configBtn.OnClick = function(self, modifiers) 
		import('/mods/Research FAF/lua/ui/Configulation.lua').Initial()
    end
	
	local help = UIUtil.CreateText(bg._title, LOC('Help'), 12)
	LayoutHelpers.LeftOf(help, bg._title)
	help.Left:Set(function() return GUI.abBG.Left() end)
	
	local title = 'How to Use'
	bg._title.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
	    	import('/mods/Research FAF/lua/ui/MassExtratorList.lua').KillMassDialog()
			import('/mods/Research FAF/lua/ui/HelpDialog.lua').Initial(GUI.bg, bg._title, title)
		elseif event.Type == 'MouseExit' then
		    import('/mods/Research FAF/lua/ui/HelpDialog.lua').KillHelpDialog()
		end
	end

	ForkThread(function()
	    CreateABButton(GUI.abBG)
	end)
	
	ForkThread(function()
		WaitSeconds(5)
		#hide multifunction
		import('/lua/ui/game/multifunction.lua').ToggleMFDPanel()
		#hide tab
		import('/lua/ui/game/tabs.lua').controls.parent:Hide()
	end)
	
    return bg
end

function CreateABButton(abBG)
	abilityButton = Button(abBG,nil,nil,nil,nil)
	abilityButton.Width:Set(35*scale)
	abilityButton.Height:Set(35*scale)
	LayoutHelpers.AtCenterIn(abilityButton, abBG)
	abilityButton.Depth:Set(function() return GUI.bg.Depth() + 10 end)

    DFwindow = Bitmap(GUI.bg)
	DFwindow:SetSolidColor('1acccccc')
	DFwindow.Width:Set(35*scale)
	DFwindow.Height:Set(35*scale)
	LayoutHelpers.RightOf(DFwindow, abBG, 3.5)
	DFwindow.Depth:Set(function() return GUI.bg.Depth() + 1 end)
	
    REwindow = Bitmap(GUI.bg)
	REwindow:SetSolidColor('1acccccc')
	REwindow.Width:Set(35*scale)
	REwindow.Height:Set(35*scale)
	LayoutHelpers.RightOf(REwindow, DFwindow, 3.5)
	REwindow.Depth:Set(function() return GUI.bg.Depth() + 1 end)
	
	ForkThread(function()
		import('/mods/Research FAF/lua/ui/RGBDialog.lua').CreateRGBDialog(REwindow)
	end)
	
	local fontSize = import('/mods/Research FAF/lua/ui/InitialData.lua').fontSize
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
    GUI.abilityText = UIUtil.CreateText(abilityButton, LOC(InitialAbility), fontSize)
	GUI.abilityText:SetColor(fontColor)
    LayoutHelpers.AtCenterIn(GUI.abilityText, abilityButton)
	LayoutHelpers.AtVerticalCenterIn(GUI.abilityText, abilityButton)
	ForkThread(function()
		while abilityButton do
		    UpdateAbilityScore()
			WaitSeconds(0.5)
		end
	end)
	
	local title = 'Research Points'
	local remarks = ', research Points from:'
	local desc = ', (killed mass value, 1 point per 10K, red bar)'
	local tips = ', (research Lab, 1 point per 150s, green bar)'
	
	abilityButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    import('/mods/Research FAF/lua/ui/MassExtratorList.lua').KillMassDialog()
		    local leftAbilities = InitialAbility + AbilityCollected - AbilitySpent
			local totalCollected = AbilityGenerated + KilledCollected
			import('/mods/Research FAF/lua/ui/ABBtnDialog.lua').Initial(GUI.bg, abilityButton, leftAbilities, title, 'Total collected: '..totalCollected..', total spent: '..AbilitySpent..remarks, KilledCollected..desc, AbilityGenerated..tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    abilityButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    import('/mods/Research FAF/lua/ui/ABBtnDialog.lua').KillABDialog()
		end
	end
	
	abilityButton.OnClick = function()
	    local num = table.getn(abilityButtonCountTable)
		local mod = math.mod(num, 2)
		if mod == 0 then
		    local closeBtn = import('/mods/Research FAF/lua/ui/AbilityTabs.lua').closeBtn
			closeBtn:OnClick()
		else
		    local leftAbilities = InitialAbility + AbilityCollected - AbilitySpent
			import('/mods/Research FAF/lua/ui/AbilityTabs.lua').Initial(abBG, leftAbilities)
			num = num + 1
			table.insert(abilityButtonCountTable, num)
		end
	end

	CreateStatusBars(abBG)
end

function CreateStatusBars(abBG)
    abilityButton.generateBar = StatusBar(abBG, 0, 1, false, false,
        nil,
        UIUtil.SkinnableFile('/game/avatar/health-bar-green.dds'),
        true, "avatar RO Health Status Bar")
    abilityButton.generateBar.Left:Set(function() return abBG.Left()  end)
    abilityButton.generateBar.Right:Set(function() return abBG.Right()  end)
    abilityButton.generateBar.Top:Set(function() return abBG.Bottom() -5*scale end)
	abilityButton.generateBar.Bottom:Set(function() return abBG.Bottom() -8*scale end)
    abilityButton.generateBar.Height:Set(function() return  abilityButton.generateBar.Bottom() -  abilityButton.generateBar.Top() end)
    abilityButton.generateBar.Width:Set(function() return abBG.Width() end)
    abilityButton.generateBar:DisableHitTest(true)
	ForkThread(function()
		while abilityButton do
		    UpdateGenBar(abilityButton.generateBar)
			WaitSeconds(1)
		end
	end)
	
    abilityButton.killsBar = StatusBar(abBG, 0, 1, false, false,
        nil,
        UIUtil.SkinnableFile('/game/avatar/health-bar-red.dds'),
        true, "avatar RO Health Status Bar")
    abilityButton.killsBar.Left:Set(function() return abBG.Left()  end)
    abilityButton.killsBar.Right:Set(function() return abBG.Right()  end)
    abilityButton.killsBar.Top:Set(function() return abBG.Bottom() -2*scale end)
	abilityButton.killsBar.Bottom:Set(function() return abBG.Bottom() -5*scale end)
	abilityButton.killsBar.Height:Set(function() return  abilityButton.killsBar.Bottom() -  abilityButton.killsBar.Top() end)
    abilityButton.killsBar.Width:Set(function() return abBG.Width() end)
    abilityButton.killsBar:DisableHitTest(true)
	ForkThread(function()
		while abilityButton do
		    UpdateKillsBar(abilityButton.killsBar)
			WaitSeconds(1)
		end
	end)
end

function UpdateAbilityScore()
    local leftAbilities = InitialAbility + AbilityCollected - AbilitySpent
	AbilityStorage = leftAbilities
	local abilityScore = leftAbilities
	#max show 99, more than it still can be spent
	if leftAbilities > 99 then
	    abilityScore = 99
	end
	GUI.abilityText:SetText(abilityScore)
end

function UpdateGenBar(gen)
	gen:SetRange(0, 1)
	gen:SetValue(AbilityGeneratedRatio)
end

function UpdateKillsBar(kills)
	kills:SetRange(0, 1)
	kills:SetValue(AbilityKillsRatio)
end

function InsufficientAB()
    local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	ForkThread(function()
	    GUI.abilityText:SetColor('Red')
		WaitSeconds(.2)
		GUI.abilityText:SetColor(fontColor)
		WaitSeconds(.2)
		GUI.abilityText:SetColor('Red')
		WaitSeconds(.2)
		GUI.abilityText:SetColor(fontColor)
	end)
end