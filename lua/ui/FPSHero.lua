local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Tooltip = import('/lua/ui/game/tooltip.lua')
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Prefs = import('/lua/user/prefs.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local health = 1
local wep = 1
local healthText = false
local bg = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg
local panel = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').DFwindow
DFActive = false

local iconsTable = {	
	{'/textures/ui/common/icons/units/UEL0001_icon.dds'},
	{'/textures/ui/common/icons/units/xeb2306_icon.dds'},
	{'/textures/ui/common/icons/units/UEB2304_icon.dds'},
	{'/textures/ui/common/icons/units/xel0305_icon.dds'},
	{'/textures/ui/common/icons/units/URB2302_icon.dds'},
	{'/textures/ui/common/icons/units/xea0002_icon.dds'},
	{'/textures/ui/common/icons/units/UEB2109_icon.dds'}
}

function ShowHealth(data)
	health = data
end

function CreateUI()
	panel.icon = Button(
	    panel, 
		UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'), 
		UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'), 
		UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'), 
		UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds')
	)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	panel:SetSolidColor(bgColor)
	LayoutHelpers.AtCenterIn(panel.icon, panel)
    panel.icon.Height:Set(30*scale)
    panel.icon.Width:Set(30*scale)
	panel.icon.Depth:Set(function() return panel.Depth() + 10 end)
	
	local title = 'Defender'
	local remarks = 'Monitor for:'
	local desc = 'Defender current weapons and health.'
	local tips = 'Click to locate Defender'
	panel.icon.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    import('/mods/Research FAF/lua/ui/MassExtratorList.lua').KillMassDialog()
		    Initial(bg, title, remarks, desc, tips)
			panel.icon:SetTexture(UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'))
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    panel.icon.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	panel.icon.OnClick = function()
		ConExecute('UI_SelectByCategory +goto FPSFAHERO')
	end

    panel.healthbar = StatusBar(panel, 0, 1, false, false,
        UIUtil.SkinnableFile('/game/avatar/health-bar-back_bmp.dds'),
        UIUtil.SkinnableFile('/game/avatar/health-bar-green.dds'),
        true, "avatar RO Health Status Bar")
    panel.healthbar.Left:Set(function() return panel.Left()  end)
    panel.healthbar.Right:Set(function() return panel.Right()  end)
    panel.healthbar.Bottom:Set(function() return panel.Bottom() - 6*scale end)
    panel.healthbar.Top:Set(function() return panel.healthbar.Bottom() +6*scale end)
    panel.healthbar.Height:Set(function() return panel.healthbar.Bottom() - panel.healthbar.Top() end)
    panel.healthbar.Width:Set(function() return panel.healthbar.Right() - panel.healthbar.Left() end)
    panel.healthbar:DisableHitTest(true)
	panel.healthbar.Depth:Set(function() return panel.icon.Depth() + 1 end)
	
	ForkThread(function()
		while panel do
		    UpdateHealth(panel.healthbar)
			WaitSeconds(1)
		end
	end)
	
	ForkThread(function()
		while panel do
			panel.icon:SetTexture(iconsTable[wep])
			WaitSeconds(2)
		end
	end)
	DFActive = panel.icon

end


function UpdateHealth(hb)
	local tempPrevHealth = 1
	local tempHealth = health
	hb:SetRange(0, 1)
	hb:SetValue(tempHealth)
	if tempPrevHealth != tempHealth then
	    SetHealthbarColor(hb, health)
	end
end

function SetHealthbarColor(control, value)
    if value > .75 then
        control._bar:SetTexture(UIUtil.SkinnableFile('/game/avatar/health-bar-green.dds'))
    elseif value > .25 then
        control._bar:SetTexture(UIUtil.SkinnableFile('/game/avatar/health-bar-yellow.dds'))
    elseif value > 0 then
        control._bar:SetTexture(UIUtil.SkinnableFile('/game/avatar/health-bar-red.dds'))
    end
end

function WeapIcons(weapon)
    wep = weapon
	panel.icon:SetTexture(iconsTable[wep])
end

function DestroyPanel()
    panel:SetSolidColor('1acccccc')
    if panel.icon or panel.healthbar then 
        panel.icon:Destroy()
        panel.icon = false
        panel.healthbar:Destroy()
        panel.healthbar = false
    end
end

GUI = {
    ABcount = false,
}

function Initial(bg, title, remarks, desc, tips)
    if GUI.ABcount == false then
	    GUI.ABcount = CreateABDialog(bg, title, remarks, desc, tips)
    end
end

function CreateABDialog(bg, title, remarks, desc, tips)

    local ABcount = Bitmap(bg)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    ABcount:SetSolidColor(bgColor)
	ABcount.Width:Set(90*scale)
	ABcount.Height:Set(40*scale)
	ABcount.Left:Set(function() return bg.Right() end)
	ABcount.Top:Set(function() return panel.Top() end)
	
    ABcount.icon = Bitmap(ABcount)
    LayoutHelpers.AtCenterIn(ABcount.icon, ABcount)
    ABcount.icon:SetTexture(UIUtil.UIFile('/textures/ui/common/icons/units/UEL0001_icon.dds'))
    ABcount.icon.Height:Set(30*scale)
    ABcount.icon.Width:Set(30*scale)
	
    ABTitle = Bitmap(ABcount)
    ABTitle:SetSolidColor('cc333333')
	ABTitle.Width:Set(300*scale)
	ABTitle.Height:Set(40*scale)
	ABTitle.Left:Set(function() return ABcount.Left() end)
	if (GetFrame(0)).Right() - bg.Right() < 310*scale then
	    ABcount.Left:Set(function() return bg.Left() - 310*scale end)
	end
	ABTitle.Top:Set(function() return ABcount.Bottom() end)

    ABTitle.title= UIUtil.CreateText(ABTitle, title, 16, UIUtil.titleFont)
    LayoutHelpers.AtCenterIn(ABTitle.title, ABTitle)
	
    ABDescription = Bitmap(ABcount)
    ABDescription:SetSolidColor('99333333')
	ABDescription.Width:Set(300*scale)
	ABDescription.Height:Set(105*scale)
	ABDescription.Left:Set(function() return ABTitle.Left() end)
	ABDescription.Top:Set(function() return ABTitle.Bottom() end)
	
	local remarks = UIUtil.CreateText(ABDescription, remarks, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(remarks, ABDescription, 10, 10)
	local desc = UIUtil.CreateText(ABDescription, desc, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(desc, ABDescription, 10, 35)
	local tips = UIUtil.CreateText(ABDescription, tips, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(tips, ABDescription, 10, 60)
	
	return ABcount
	
end

function KillABDialog()
    if GUI.ABcount then 
	    GUI.ABcount:Destroy()
		GUI.ABcount = false
    end
end