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

local nukeCounts = 0
local bg = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg

GUI = {
    nukedialogText = false,
}

function Initial(before)
    if GUI.nukedialogText == false then
	    GUI.nukedialogText = CreateNukeDialog(before)
    end
end

function EnemyNukesCounts(nuke)
	nukeCounts = nuke
end

function CreateNukeDialog(before)
    local nukedialogText = Bitmap(before)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    nukedialogText:SetSolidColor(bgColor)
	nukedialogText.Width:Set(200*scale)
	nukedialogText.Height:Set(40*scale)
	nukedialogText.Left:Set(function() return bg.Right()end)
	if (GetFrame(0)).Right() - bg.Right() < 210*scale then
	    nukedialogText.Left:Set(function() return bg.Left() - 210*scale end)
	end
	nukedialogText.Top:Set(function() return before.Top() end)
    nukedialogText.lable = UIUtil.CreateText(nukedialogText, "Checking Nukes...", 16, UIUtil.titleFont)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	nukedialogText.lable:SetColor(fontColor)
	LayoutHelpers.AtCenterIn(nukedialogText.lable, nukedialogText)
	
    nukedialog = Bitmap(nukedialogText)
    nukedialog:SetSolidColor('99333333')
	nukedialog.Width:Set(function() return nukedialogText.Width() end)
	nukedialog.Height:Set(40*scale)
	nukedialog.Left:Set(function() return nukedialogText.Left()  + 0 end)
	nukedialog.Top:Set(function() return nukedialogText.Bottom() + 0 end)
    nukedialog.result = UIUtil.CreateText(nukedialog, "Wait for 1s", 16, UIUtil.bodyFont)
	LayoutHelpers.AtCenterIn(nukedialog.result, nukedialog)
	
	ForkThread(function()
		WaitSeconds(1)
		nukedialogText.lable:SetText("Nukes Detected")
		nukedialog.result:SetText(nukeCounts)
	end)
	
	return nukedialogText
end

function KillNukeDialog()
    if GUI.nukedialogText then
	    GUI.nukedialogText:Destroy()
		GUI.nukedialogText = false
    end
end