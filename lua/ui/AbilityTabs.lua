--*****************************************************************************
--* Drawer Menu Version
--*****************************************************************************

local Window = import('/lua/maui/window.lua').Window
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local Prefs = import('/lua/user/prefs.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local abilityButtonCountTable = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').abilityButtonCountTable

local optionsOrder = {
    "buff","intel","field","superweapon","defender"
}

local options = {
    buff = { title = "E", tips = "Enhancements", id = 'Enh' },
    intel = { title = "I", tips = "Intel", id = 'Intel' },
    field = { title = "F", tips = "Field Supports", id = 'Field' },
    superweapon = { title = "W", tips = "Weapons", id = 'SWP' },
    defender = { title = "D", tips = "Defender", id = 'DF' },
}

GUI = {
    dialogTop = false,
}

closeBtn = false -- parent calls this, keep it here

local dialogLeft = false
local dialogRight = false
local currentTab = false

local drawerOpen = false
local drawerWidth = 50 -- correct width so panels get next to tab menu

local buttonSize = 25

local currentTab = nil  -- The tab that's currently active
local currentTabBG = nil  -- The highlight/border for the active tab

-----------------------------------------------------------
-- TAB BUTTON
-----------------------------------------------------------

local function CreateTabButton(tabData, parent, prev)

    local tabButton = Button(
        parent,
        UIUtil.UIFile('/game/mfd_bmp/mfd_glow_bmp.dds'),
        UIUtil.UIFile('/game/mfd_bmp/mfd_glow_bmp.dds'),
        UIUtil.UIFile('/game/mfd_bmp/mfd_glow_bmp.dds'),
        UIUtil.UIFile('/game/mfd_bmp/mfd_glow_bmp.dds')
    )

    tabButton.Width:Set(buttonSize * scale)
    tabButton.Height:Set(buttonSize * scale)
    tabButton.label = UIUtil.CreateText(tabButton, tabData.title, 16 * scale, UIUtil.titleFont)
	tabButton.label.Depth:Set(function() return dialogTop.Depth() + 3 end)
    LayoutHelpers.AtCenterIn(tabButton.label, tabButton)
    Tooltip.AddButtonTooltip(tabButton, tabData.tips)
	
    if prev then
        LayoutHelpers.Below(tabButton, prev, 2)
    else
        LayoutHelpers.AtLeftTopIn(tabButton, parent)
    end

    tabButton.tabData = tabData

    return tabButton
end


-----------------------------------------------------------
-- DRAWER ANIMATION
-----------------------------------------------------------

local function SlideDrawer(open)

    if not dialogLeft then return end

    local anchor = dialogTop.Right()

    local start
    local target

    if open then
        start = 0
        target = drawerWidth
        dialogLeft:Show()
        dialogRight:Show()
    else
        start = drawerWidth
        target = 0
    end

    local t = 0

    dialogLeft:SetNeedsFrameUpdate(true)

    dialogLeft.OnFrame = function(self, delta)

        t = t + delta * 6
        local p = math.min(t,1)

        local offset = start + (target-start) * p
		
		dialogLeft.Left:Set(function()
		    return dialogTop.Right() + offset - dialogLeft.Width()
		end)
		
		dialogRight.Left:Set(function()
		    return dialogTop.Right() + offset
		end)

        if p >= 1 then
            self:SetNeedsFrameUpdate(false)

            if not open then
                dialogLeft:Hide()
                dialogRight:Hide()
            end
        end
    end
end


-----------------------------------------------------------
-- CREATE PANELS
-----------------------------------------------------------

local function CreateDrawerPanels(parent)

    local colorCode = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	
    dialogLeft = Bitmap(parent)
    dialogLeft:SetSolidColor('ff333333')
    dialogLeft.Width:Set(54 * scale)
    dialogLeft.Height:Set(370 * scale)
    dialogLeft.Left:Set(function() return parent.Right() - 1 end)
    dialogLeft.Top:Set(function() return parent.Top() end)
	dialogLeft.Depth:Set(function() return parent.Depth() - 1 end)
	
	local colorCode  = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	dialogLeft.border = Bitmap(dialogLeft)
	dialogLeft.border:SetSolidColor(colorCode)
	dialogLeft.border.Left:Set(function() return dialogLeft.Left() - 1 end)
	dialogLeft.border.Top:Set(function() return dialogLeft.Top() - 1 end)
	dialogLeft.border.Width:Set(function() return dialogLeft.Width() + 1 end)
	dialogLeft.border.Height:Set(function() return dialogLeft.Height() + 2 end)
	dialogLeft.border.Depth:Set(function() return dialogLeft.Depth() - 1 end)

    dialogRight = Bitmap(dialogLeft)
    dialogRight:SetSolidColor('ff333333')
    dialogRight.Width:Set(54 * scale)
    dialogRight.Height:Set(370 * scale)
    dialogRight.Left:Set(function() return dialogLeft.Right() end)
    dialogRight.Top:Set(function() return dialogLeft.Top() end)
	dialogRight.Depth:Set(function() return parent.Depth() + 2 end)
	
	local colorCode  = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	dialogRight.border = Bitmap(dialogRight)
	dialogRight.border:SetSolidColor(colorCode)
	dialogRight.border.Left:Set(function() return dialogRight.Left() end)
	dialogRight.border.Top:Set(function() return dialogRight.Top() - 1 end)
	dialogRight.border.Width:Set(function() return dialogRight.Width() + 1 end)
	dialogRight.border.Height:Set(function() return dialogRight.Height() + 2 end)
	dialogRight.border.Depth:Set(function() return dialogRight.Depth() - 1 end)

    dialogLeft:Hide()
    dialogRight:Hide()
	
	-- Create close button
	closeBtn = Button(dialogRight,
	    UIUtil.UIFile('/dialogs/menu-btns/close_btn_up.dds'),
		UIUtil.UIFile('/dialogs/menu-btns/close_btn_over.dds'),
		UIUtil.UIFile('/dialogs/menu-btns/close_btn_down.dds'),
		UIUtil.UIFile('/dialogs/menu-btns/close_btn_dis.dds'),
		"UI_Opt_Yes_No", "UI_Opt_Affirm_Over"
    )
	
	closeBtn.Width:Set(20 * scale)
	closeBtn.Height:Set(20 * scale)
	LayoutHelpers.AtBottomIn(closeBtn, dialogRight)
	LayoutHelpers.AtRightIn(closeBtn, dialogRight)
	closeBtn.Depth:Set(GetFrame(0):GetTopmostDepth() + 30)
	Tooltip.AddButtonTooltip(closeBtn, 'Close Tabs')
	closeBtn.OnClick = function()
	    local num = table.getn(abilityButtonCountTable)
		num = num + 1
		table.insert(abilityButtonCountTable, num)
		KillTabDialog()
		import('/mods/Research FAF/lua/ui/MassExtratorList.lua').KillMassDialog()
		import('/mods/Research FAF/lua/ui/FieldInfo.lua').KillABDialog()
	end
end


-----------------------------------------------------------
-- LOAD TAB CONTENT
-----------------------------------------------------------

local function LoadTab(tabData, intAbility)

    if dialogLeft then dialogLeft:Destroy() end
    if dialogRight then dialogRight:Destroy() end

    CreateDrawerPanels(dialogTop)
    import('/mods/Research FAF/lua/ui/' .. tabData.id .. 'Panel.lua').CreateButtons(dialogLeft, dialogRight, intAbility)
end

-----------------------------------------------------------
-- TAB CLICK
-----------------------------------------------------------

local function TabClick(self, intAbility)
    local tabData = self.tabData

    -- If the same tab is clicked again, close the drawer and remove the highlight
    if drawerOpen and currentTab == self then
        -- Remove the highlight from the current tab
        if currentTabBG then
            currentTabBG:Destroy()  -- Remove the border
            currentTabBG = nil
        end

        -- Close the drawer
        SlideDrawer(false)
        drawerOpen = false
        currentTab = false
        return
    end

    -- Hide and destroy the old panels immediately
    if dialogLeft then
        dialogLeft:Hide()  -- Hide the old panel
        dialogRight:Hide()
        dialogLeft:Destroy()  -- Destroy the old panel after hiding
        dialogRight:Destroy()
    end

    -- Create the new panels and load tab content
    CreateDrawerPanels(dialogTop)  -- Creates new dialogLeft / dialogRight
    LoadTab(tabData, intAbility)

    -- Create a border (highlight) for the current tab
    if currentTabBG then
        currentTabBG:Destroy()  -- Remove the previous tab's highlight
        currentTabBG = nil
    end

	currentTabBG = Bitmap(self)
	currentTabBG:SetSolidColor('ff333333')
	currentTabBG.Height:Set(buttonSize * scale)
	currentTabBG.Width:Set(buttonSize * scale + 1)
	LayoutHelpers.AtLeftTopIn(currentTabBG, self)
	currentTabBG.Depth:Set(function() return dialogTop.Depth() + 2 end)
		
	local currentTabBGBorder = Bitmap(currentTabBG)
	local colorCode  = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	currentTabBGBorder:SetSolidColor(colorCode)
	currentTabBGBorder.Left:Set(function() return currentTabBG.Left() -1 end)
	currentTabBGBorder.Top:Set(function() return currentTabBG.Top() -1 end)
	currentTabBGBorder.Width:Set(function() return currentTabBG.Width() end)
	currentTabBGBorder.Height:Set(buttonSize * scale + 2)
	currentTabBGBorder.Depth:Set(function() return currentTabBG.Depth() - 1 end)
	
    -- Slide the new panel out
    SlideDrawer(true)

    -- Set the drawer to open and set the current tab
    drawerOpen = true
    currentTab = self
end

-----------------------------------------------------------
-- CREATE MAIN UI
-----------------------------------------------------------

function CreateDialog(parentBG, intAbility)

    dialogTop = Bitmap(parentBG)

    dialogTop.Width:Set(30 * scale)
    dialogTop.Height:Set(150 * scale)

    dialogTop.Left:Set(function() return parentBG.Left() end)
    dialogTop.Top:Set(function() return parentBG.Bottom() + 4 end)
	dialogTop.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
	

    local prev = false
	local firstTab = false

    for _, key in optionsOrder do

        local tab = CreateTabButton(options[key], dialogTop, prev)

        tab.OnClick = function(self)
            TabClick(self, intAbility)
        end
		
		if not firstTab then
		    firstTab = tab
		end
		

        prev = tab

    end
	-- Open the first tab automatically
	if firstTab then
	    TabClick(firstTab, intAbility)
	end

    return dialogTop

end


-----------------------------------------------------------
-- INIT
-----------------------------------------------------------

function Initial(parentBG, intAbility)

    if not GUI.dialogTop then
        GUI.dialogTop = CreateDialog(parentBG, intAbility)
    end

end


-----------------------------------------------------------
-- DESTROY
-----------------------------------------------------------

function KillTabDialog()

    if GUI.dialogTop then
        GUI.dialogTop:Destroy()
        GUI.dialogTop = false
    end

    if dialogLeft then
        dialogLeft:Destroy()
        dialogLeft = false
    end

    if dialogRight then
        dialogRight:Destroy()
        dialogRight = false
    end

end