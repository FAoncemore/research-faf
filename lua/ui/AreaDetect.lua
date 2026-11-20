local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local scale = import('/lua/user/prefs.lua').GetFromCurrentProfile("options.ui_scale") or 1

local parentBG = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg
local abButton = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').abilityButton

GUI = {
    bg = false,
}

function Initial(data)
    if GUI.bg then GUI.bg:Destroy() end
	GUI.bg = CreateAreaDetectDialog(data)
end

function CreateAreaDetectDialog(data)
    local bg = Bitmap(parentBG)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    bg:SetSolidColor('ff333333')
	bg.Width:Set(80*scale)
	bg.Height:Set(80*scale)
	bg.Left:Set(function() return parentBG.Right() end)
	bg.Top:Set(function() return abButton.Top() end)

	--shadow
	bg.shadow = Bitmap(bg)
	bg.shadow:SetSolidColor('7f1a1a1a')
	bg.shadow.Left:Set(function() return bg.Left() - 1*scale end)
	bg.shadow.Top:Set(function() return bg.Top() - 1*scale end)
	bg.shadow.Width:Set(function() return bg.Width() + 2*scale end)
	bg.shadow.Height:Set(function() return bg.Height() + 2*scale end)
	bg.shadow.Depth:Set(function() return bg.Depth() - 1 end)
	
	local icon = false
	if DiskGetFileInfo('/textures/ui/common/icons/units/'..data[1]..'_icon.dds') then
	    icon = UIUtil.UIFile('/textures/ui/common/icons/units/'..data[1]..'_icon.dds')
	else
	    icon = DiskFindFiles('/mods', data[1]..'_icon.dds')
	end
	
    local detectButton = Button(bg, icon, icon, icon, icon)
	detectButton.Width:Set(80*scale)
	detectButton.Height:Set(80*scale)
	LayoutHelpers.AtCenterIn(detectButton, bg)
	detectButton.Depth:Set(function() return bg.Depth() + 2 end)
	
	local rect = Rect(
	    data[2][1] - 20,
		data[2][3] - 20,
		data[2][1] + 20,
		data[2][3] + 20
	)
	detectButton.OnClick = function()
	    GetCamera("WorldCamera"):MoveToRegion( rect, 1.0 )
	end
	
	-- Create close button
	local closeBtn = Button(bg,
	    UIUtil.UIFile('/dialogs/menu-btns/close_btn_up.dds'),
		UIUtil.UIFile('/dialogs/menu-btns/close_btn_over.dds'),
		UIUtil.UIFile('/dialogs/menu-btns/close_btn_down.dds'),
		UIUtil.UIFile('/dialogs/menu-btns/close_btn_dis.dds'),
		"UI_Opt_Yes_No", "UI_Opt_Affirm_Over"
	)
	closeBtn.Width:Set(20 * scale)
	closeBtn.Height:Set(20 * scale)
	LayoutHelpers.RightOf(closeBtn, bg)
	closeBtn.Depth:Set(function() return bg.Depth() + 3 end)
	closeBtn.OnClick = function()
	    GUI.bg:Destroy()
	end
	
	ForkThread(function()
	    for i = 1, 10 do
		    WaitSeconds(0.1)
			bg.shadow:SetSolidColor('yellow')
			WaitSeconds(0.1)
			bg.shadow:SetSolidColor('7f1a1a1a')
		end
	end)
	
	return bg
end
