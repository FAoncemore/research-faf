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

GUI = {
    Title = false,
}

function Initial(bg, parent, title)
    if GUI.Title == false then
	    GUI.Title = CreateHelpDialog(bg, parent, title)
    end
end

function CreateHelpDialog(bg, parent, title)

    local Title = Bitmap(bg)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    Title:SetSolidColor(bgColor)
	Title.Width:Set(300*scale)
	Title.Height:Set(40*scale)
	Title.Left:Set(function() return bg.Right() end)
	if (GetFrame(0)).Right() - bg.Right() < 310*scale then
	    Title.Left:Set(function() return bg.Left() - 310*scale end)
	end
	Title.Top:Set(function() return parent.Top() end)

    Title.title= UIUtil.CreateText(Title, title, 16, UIUtil.titleFont)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	Title.title:SetColor(fontColor)
    LayoutHelpers.AtCenterIn(Title.title, Title)
	
    Description = Bitmap(Title)
    Description:SetSolidColor('99333333')
	Description.Width:Set(300*scale)
	Description.Height:Set(150*scale)
	Description.Left:Set(function() return Title.Left() end)
	Description.Top:Set(function() return Title.Bottom() end)
	
	local tips = UIUtil.CreateText(Description, '* UI draggable, UI Show/Hide by CTRL+M', 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(tips, Description, 10, 10)
	
    local usage = UIUtil.CreateText(Description, '* Use points to upgrade units or support battle', 12, UIUtil.bodyFont)
    LayoutHelpers.AtLeftTopIn(usage, Description, 10, 25)
	
	local points = UIUtil.CreateText(Description, '* Points from Killed mass value & Research Lab', 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(points, Description, 10, 40)
	
	local begin = UIUtil.CreateText(Description, 'Click this button(below Help) to begin:', 14, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(begin, Description, 10, 70)
	
    local abBG = Bitmap(Title)
	abBG:SetSolidColor(bgColor)
	abBG.Width:Set(35*scale)
	abBG.Height:Set(35*scale)
	LayoutHelpers.AtLeftTopIn(abBG, Description, 10, 95)
	local abText = import('/mods/Research FAF/lua/ui/InitialData.lua').InitialAbility or '3'
	local fontSize = import('/mods/Research FAF/lua/ui/InitialData.lua').fontSize
	local abBGText = UIUtil.CreateText(Description, abText, fontSize)
	abBGText:SetColor(fontColor)
    LayoutHelpers.AtCenterIn(abBGText, abBG)
	LayoutHelpers.AtVerticalCenterIn(abBGText, abBG)
	
	return Title

end

function KillHelpDialog()
    if GUI.Title then 
	    GUI.Title:Destroy()
		GUI.Title = false
    end
end