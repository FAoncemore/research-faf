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

local bg = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg

local MassButtons = {'T1', 'T2', 'T3'}
local MassUnits = {  
    ['T1'] = {
		['ID'] = {
		    {0, 'UEB1103'},
			{1, 'UAB1103'},
			{2, 'URB1103'},
			{3, 'XSB1103'},
		},
	},
    ['T2'] = {
		['ID'] = {
		    {0, 'UEB1202'},
			{1, 'UAB1202'},
			{2, 'URB1202'},
			{3, 'XSB1202'},
		},
	},
    ['T3'] = {
		['ID'] = {
		    {0, 'UEB1302'},
			{1, 'UAB1302'},
			{2, 'URB1302'},
			{3, 'XSB1302'},
		},
	},
}

GUI = {
    massdialogText = false,
}

function Initial(before)
    if GUI.massdialogText == false then
	    GUI.massdialogText = CreateMassDialog(before)
    end
end

function CreateMassDialog(before)
	
    local massdialogText = Bitmap(bg)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    massdialogText:SetSolidColor(bgColor)
	massdialogText.Width:Set(190*scale)
	massdialogText.Height:Set(40*scale)
	massdialogText.Left:Set(function() return bg.Right() end)
	if (GetFrame(0)).Right() - bg.Right() < 200*scale then
	    massdialogText.Left:Set(function() return bg.Left() - 200*scale end)
	end
	massdialogText.Top:Set(function() return before.Top() end)
    massdialogText.lable = UIUtil.CreateText(massdialogText, "Mass Extractors", 16, UIUtil.titleFont)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	massdialogText.lable:SetColor(fontColor)
    LayoutHelpers.AtCenterIn(massdialogText.lable, massdialogText)
	
    massdialog = Bitmap(massdialogText)
    massdialog:SetSolidColor('99333333')
	massdialog.Width:Set(function() return massdialogText.Width() end)
	massdialog.Height:Set(95*scale)
	massdialog.Left:Set(function() return massdialogText.Left()  + 0 end)
	massdialog.Top:Set(function() return massdialogText.Bottom() + 0 end)
	
	ForkThread(function()
	    for i = 1, 3 do
		    UISelectionByCategory("MASSEXTRACTION * TECH"..i, false, false, false, false)
			local extractors = GetSelectedUnits()
			local num = 0
			if extractors then
			    num = table.getn(extractors)
			end
			CreateMassButton(massdialog, i, 'T'..i, num)
		end
	end)
	
    local closeBtn = Button(massdialog, 
        UIUtil.UIFile('/dialogs/close_btn/close_btn_up.dds'),
        UIUtil.UIFile('/dialogs/close_btn/close_btn_over.dds'),
        UIUtil.UIFile('/dialogs/close_btn/close_btn_down.dds'),
        UIUtil.UIFile('/dialogs/close_btn/close_btn_dis.dds'),
        "UI_Opt_Yes_No", "UI_Opt_Affirm_Over")
	LayoutHelpers.AtBottomIn(closeBtn, massdialog)
    LayoutHelpers.AtRightIn(closeBtn, massdialog)
	closeBtn.Width:Set(24*scale)
	closeBtn.Height:Set(24*scale)
	closeBtn.Depth:Set(GetFrame(0):GetTopmostDepth() + 3)

    closeBtn.OnClick = function()
        KillMassDialog()
    end
	
	return massdialogText
end

function CreateMassButton(bg, index, key, num)
    local icon = UIUtil.UIFile('/icons/units/default_icon.dds')
	local currentFaction = GetArmiesTable().armiesTable[GetFocusArmy()].faction
	icon = UIUtil.UIFile('/icons/units/'..MassUnits[key]['ID'][currentFaction + 1][2]..'_icon.dds')
	local button = Button(
	    bg, 
	    icon, 
		icon, 
		icon, 
		icon
	)
	local leftdist = (10+(48*index - 48))*scale
	button.Left:Set(function() return bg.Left()  + leftdist end)
	button.Top:Set(function() return bg.Top() + 15*scale end)
	button.Width:Set(48*scale)
	button.Height:Set(48*scale)
	button.Depth:Set(GetFrame(0):GetTopmostDepth() + 3)
	button.description = UIUtil.CreateText(button, num, 12, UIUtil.bodyFont)
	LayoutHelpers.AtCenterIn(button.description, button)
	button.description.Top:Set(function() return button.Bottom() + 2*scale end)
    button.OnClick = function()
	    local cat = "MASSEXTRACTION * TECH"..index
        UISelectionByCategory(cat, false, false, false, false)
    end
end

function KillMassDialog()
    if GUI.massdialogText then 
	    GUI.massdialogText:Destroy()
		GUI.massdialogText = false
    end
end