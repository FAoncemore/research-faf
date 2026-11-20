--*****************************************************************************
--* File: lua/modules/ui/game/chat.lua
--* Author: Chris Blackwell
--* Summary: In game chat ui
--*
--* Copyright ?:005 Gas Powered Games, Inc.  All rights reserved.
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

local bg = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg

local upWindow = false
local mWindow = false
local dWindow = false
local RGBWidth = 20
local RGBHeight = 10

function CreateRGBDialog(REwindow)
    upWindow = Bitmap(REwindow)
	upWindow:SetSolidColor('green')
	upWindow.Width:Set(RGBWidth*scale)
	upWindow.Height:Set(RGBHeight*scale)
	LayoutHelpers.RightOf(upWindow, REwindow, 4*scale)
	upWindow.Depth:Set(function() return bg.Depth() + 1 end)

	local upButton = Button(upWindow,upWindow,upWindow,upWindow,upWindow)
	LayoutHelpers.AtCenterIn(upButton, upWindow)
	upButton.Width:Set(RGBWidth*scale)
	upButton.Height:Set(RGBHeight*scale)
	upButton.Depth:Set(function() return upWindow.Depth() + 10 end)
	
	local title = 'Check Mass Extrator'
	local description = 'Click to check mass extrator tier and qty'
	local tips = ''
	upButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(upButton, upWindow, 0, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
			import('/mods/Research FAF/lua/ui/MassExtratorList.lua').Initial(upButton)
			KillABDialog()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
    mWindow = Bitmap(REwindow)
	mWindow:SetSolidColor('red')
	mWindow.Width:Set(RGBWidth*scale)
	mWindow.Height:Set(RGBHeight*scale)
	LayoutHelpers.Below(mWindow, upWindow, 2.5*scale)
	mWindow.Depth:Set(function() return bg.Depth() + 1 end)
	
	mButton = Button(mWindow,mWindow,mWindow,mWindow,mWindow)
	LayoutHelpers.AtCenterIn(mButton, mWindow)
	mButton.Width:Set(RGBWidth*scale)
	mButton.Height:Set(RGBHeight*scale)
	mButton.Depth:Set(function() return mWindow.Depth() + 10 end)
	Tooltip.AddButtonTooltip(mButton, '')
	
	local title = 'Check Nuke Qty'
	local description = 'Click to check enemy nuke qty'
	local tips = ''
	mButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(mButton, mWindow, 0, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
			import('/mods/Research FAF/lua/ui/MassExtratorList.lua').KillMassDialog()
		elseif event.Type == 'ButtonPress' then
			SimCallback({Func = 'CountEnemyNukesNum'})
			import('/mods/Research FAF/lua/ui/NukeDialog.lua').Initial(mButton)
			KillABDialog()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
			import('/mods/Research FAF/lua/ui/NukeDialog.lua').KillNukeDialog()
		end
	end
	
    dWindow = Bitmap(REwindow)
	dWindow:SetSolidColor('blue')
	dWindow.Width:Set(RGBWidth*scale)
	dWindow.Height:Set(RGBHeight*scale)
	LayoutHelpers.Below(dWindow, mWindow, 2.5*scale)
	dWindow.Depth:Set(function() return bg.Depth() + 1 end)
	
	local dButton = Button(dWindow,dWindow,dWindow,dWindow,dWindow)
	LayoutHelpers.AtCenterIn(dButton, dWindow)
	dButton.Width:Set(RGBWidth*scale)
	dButton.Height:Set(RGBHeight*scale)
	dButton.Depth:Set(function() return dWindow.Depth() + 10 end)
	Tooltip.AddButtonTooltip(dButton, '(Selected Units) Click Random Move')
	
	dButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
	    	import('/mods/Research FAF/lua/ui/MassExtratorList.lua').KillMassDialog()
			Initial(dButton)
		elseif event.Type == 'ButtonPress' then
		    dButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillRandomMoveDialog()
		end
	end
	
	dButton.OnClick = function()
	    local units = GetSelectedUnits()
        if units then
            local unitIds = {}
            for _, unit in units do
                table.insert(unitIds, unit:GetEntityId())
            end
            SimCallback({Func = 'SelectedRandomMove', Args = {units = unitIds}})
			PlayVoice(Sound{Bank = 'XGG', Cue = 'XGG_Computer_CV01_04735'}, true)
        end
	end
end


GUI = {
    ranMovedialogText = false,
}

function Initial(before)
    if GUI.ranMovedialogText == false then
	    GUI.ranMovedialogText = CreateRandomMoveDialog(before)
    end
end

function CreateRandomMoveDialog(before)
	
    local ranMovedialogText = Bitmap(before)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    ranMovedialogText:SetSolidColor(bgColor)
	ranMovedialogText.Width:Set(200*scale)
	ranMovedialogText.Height:Set(40*scale)
	ranMovedialogText.Left:Set(function() return bg.Right() end)
	if (GetFrame(0)).Right() - bg.Right() < 210*scale then
	    ranMovedialogText.Left:Set(function() return bg.Left() - 210*scale end)
	end
	ranMovedialogText.Top:Set(function() return before.Top() end)
    ranMovedialogText.lable = UIUtil.CreateText(ranMovedialogText, "Random Move", 16, UIUtil.titleFont)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	ranMovedialogText.lable:SetColor(fontColor)
    LayoutHelpers.AtCenterIn(ranMovedialogText.lable, ranMovedialogText)
	
    ranMovedialog = Bitmap(ranMovedialogText)
    ranMovedialog:SetSolidColor('99333333')
	ranMovedialog.Width:Set(function() return ranMovedialogText.Width() end)
	ranMovedialog.Height:Set(40*scale)
	ranMovedialog.Left:Set(function() return ranMovedialogText.Left() end)
	ranMovedialog.Top:Set(function() return ranMovedialogText.Bottom() end)
    ranMovedialog.desc = UIUtil.CreateText(ranMovedialog, 'Select units & click the button', 12, UIUtil.bodyFont)
    LayoutHelpers.AtCenterIn(ranMovedialog.desc, ranMovedialog)
	
	return ranMovedialogText
end

function KillRandomMoveDialog()
    if GUI.ranMovedialogText then 
	    GUI.ranMovedialogText:Destroy()
		GUI.ranMovedialogText = false
    end
end

function CreateABDialog(curBtn, bg, AB, title, description, tips)
	import('/mods/Research FAF/lua/ui/TipsDialogs.lua').Initial(curBtn, bg, AB, title, description, tips)
end

function KillABDialog()
    import('/mods/Research FAF/lua/ui/TipsDialogs.lua').KillABDialog()
end