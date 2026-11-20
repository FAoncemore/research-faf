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
    ABcount = false,
}

function Initial(bg, parent, AB, title, remarks, desc, tips)
    if GUI.ABcount == false then
	    GUI.ABcount = CreateABBtnDialog(bg, parent, AB, title, remarks, desc, tips)
    end
end

function CreateABBtnDialog(bg, parent, AB, title, remarks, desc, tips)

    local ABcount = Bitmap(bg)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	ABcount:SetSolidColor(bgColor)
	ABcount.Width:Set(150*scale)
	ABcount.Height:Set(40*scale)
	ABcount.Left:Set(function() return bg.Right() end)
	if (GetFrame(0)).Right() - bg.Right() < 410*scale then
	    ABcount.Left:Set(function() return bg.Left() - 410*scale end)
	end
	ABcount.Top:Set(function() return parent.Top() end)
	
    ABcount.icon = Bitmap(ABcount)
    LayoutHelpers.AtLeftTopIn(ABcount.icon, ABcount, 10*scale, 5*scale)
    ABcount.icon:SetTexture(UIUtil.UIFile('/mods/Research FAF/Research_icon.png'))
    ABcount.icon.Height:Set(25*scale)
    ABcount.icon.Width:Set(25*scale)
	
    ABcount.ab = UIUtil.CreateText(ABcount, AB, 24, UIUtil.titleFont)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	ABcount.ab:SetColor(fontColor)
    LayoutHelpers.RightOf(ABcount.ab, ABcount.icon, 10*scale)
	
    local ABTitle = Bitmap(ABcount)
    ABTitle:SetSolidColor('cc333333')
	ABTitle.Width:Set(400*scale)
	ABTitle.Height:Set(40*scale)
	ABTitle.Left:Set(function() return ABcount.Left() end)
	ABTitle.Top:Set(function() return ABcount.Bottom() end)

    ABTitle.title= UIUtil.CreateText(ABTitle, title, 16, UIUtil.titleFont)
    LayoutHelpers.AtCenterIn(ABTitle.title, ABTitle)
	
    local ABDescription = Bitmap(ABcount)
    ABDescription:SetSolidColor('99333333')
	ABDescription.Width:Set(400*scale)
	ABDescription.Height:Set(105*scale)
	ABDescription.Left:Set(function() return ABTitle.Left() end)
	ABDescription.Top:Set(function() return ABTitle.Bottom() end)
	
	local remarks = UIUtil.CreateText(ABDescription, remarks, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(remarks, ABDescription, 10, 10)
	
    local descicon = Bitmap(ABcount)
    LayoutHelpers.AtLeftTopIn(descicon, ABDescription, 20, 35)
    descicon:SetTexture(UIUtil.UIFile('/game/unit_view_icons/mass.dds'))
	local description = UIUtil.CreateText(descicon, desc, 12, UIUtil.bodyFont)
	LayoutHelpers.RightOf(description, descicon, 2)
	
    local tipsicon = Bitmap(ABcount)
    LayoutHelpers.AtLeftTopIn(tipsicon, ABDescription, 20, 60)
    tipsicon:SetTexture(UIUtil.UIFile('/mods/Research FAF/Textures/ui/common/icons/units/ResearchLab_icon.dds'))
	tipsicon.Width:Set(20*scale)
	tipsicon.Height:Set(20*scale)
	local tip = UIUtil.CreateText(tipsicon, tips, 12, UIUtil.bodyFont)
	LayoutHelpers.RightOf(tip, tipsicon, 2)
	
	return ABcount

end

function KillABDialog()
    if GUI.ABcount then 
	    GUI.ABcount:Destroy()
		GUI.ABcount = false
    end
end