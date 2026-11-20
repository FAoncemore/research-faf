local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local scale = import('/lua/user/prefs.lua').GetFromCurrentProfile("options.ui_scale") or 1

local parentBG = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg

GUI = {
    ABcount = false,
}

function Initial(curBtn, bg, AB, title, description, tips)
    if GUI.ABcount == false then
	    GUI.ABcount = CreateABDialog(curBtn, bg, AB, title, description, tips)
    end
end

function CreateABDialog(curBtn, bg, AB, title, description, tips)
    local ABcount = Bitmap(bg)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    ABcount:SetSolidColor(bgColor)
	ABcount.Width:Set(90*scale)
	ABcount.Height:Set(40*scale)
	ABcount.Left:Set(function() return parentBG.Right() end)
	if (GetFrame(0)).Right() - parentBG.Right() < 310*scale then
	    ABcount.Left:Set(function() return parentBG.Left() - 310*scale end)
	end
	ABcount.Top:Set(function() return curBtn.Top() end)
	
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
    ABTitle:SetSolidColor('E6333333')
	ABTitle.Width:Set(300*scale)
	ABTitle.Height:Set(40*scale)
	ABTitle.Left:Set(function() return ABcount.Left() end)
	ABTitle.Top:Set(function() return ABcount.Bottom() end)

    ABTitle.text= UIUtil.CreateText(ABTitle, title, 16, UIUtil.titleFont)
    LayoutHelpers.AtCenterIn(ABTitle.text, ABTitle)
	
    local ABDescription = Bitmap(ABcount)
    ABDescription:SetSolidColor('99333333')
	ABDescription.Width:Set(300*scale)
	ABDescription.Height:Set(85*scale)
	ABDescription.Left:Set(function() return ABTitle.Left() end)
	ABDescription.Top:Set(function() return ABTitle.Bottom() end)
	
	local desc = UIUtil.CreateText(ABDescription, description, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(desc, ABDescription, 10, 10)
	local remarks = UIUtil.CreateText(ABDescription, tips, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(remarks, ABDescription, 10, 35)
	
	return ABcount
end

function KillABDialog()
    if GUI.ABcount then 
	    GUI.ABcount:Destroy()
		GUI.ABcount = false
    end
end