--*****************************************************************************
--* File: lua/modules/ui/game/chat.lua
--* Author: Chris Blackwell
--* Summary: In game chat ui
--*
--* Copyright ?:005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************


local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Window = import('/lua/maui/window.lua').Window
local BitmapCombo = import('/lua/ui/controls/combo.lua').BitmapCombo
local IntegerSlider = import('/lua/maui/slider.lua').IntegerSlider
local Tooltip = import('/lua/ui/game/tooltip.lua')
local Prefs = import('/lua/user/prefs.lua')

local initfontSize = import('/mods/Research FAF/lua/ui/InitialData.lua').fontSize
local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
local def_ui_color = Prefs.GetFromCurrentProfile("Research_ui_color_index") or 10
local def_font_color = Prefs.GetFromCurrentProfile("Research_font_color_index") or 16
local def_decal_size = Prefs.GetFromCurrentProfile("Research_decal_size_index") or 25
local def_decal_lifetime = Prefs.GetFromCurrentProfile("Research_decal_lifetime_index") or 10
local buttonSize = import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize

local defOptions = { 
    ui_color = def_ui_color, 
	font_color = def_font_color,
	watch_toggle = 1,
	font_size = initfontSize,
	buff_Lvl = buffLvl,
	decal_size = def_decal_size,
	decal_lifetime = def_decal_lifetime,
	event_size = buttonSize,
	}

GUI = {
    config = false,
}

function Initial()
    if not GUI.config then
	    local def_ui_color = Prefs.GetFromCurrentProfile("Research_ui_color_index") or 10
		local def_font_color = Prefs.GetFromCurrentProfile("Research_font_color_index") or 16
		local initfontSize = import('/mods/Research FAF/lua/ui/InitialData.lua').fontSize
		local buffLvl = import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl
		local def_decal_size = Prefs.GetFromCurrentProfile("Research_decal_size_index") or 25
		local def_decal_lifetime = Prefs.GetFromCurrentProfile("Research_decal_lifetime_index") or 10
		local buttonSize = import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize
		
		defOptions = { 
		    ui_color = def_ui_color, 
			font_color = def_font_color,
			watch_toggle = 1,
			font_size = initfontSize,
			buff_Lvl = buffLvl,
			decal_size = def_decal_size,
			decal_lifetime = def_decal_lifetime,
			event_size = buttonSize,
		}
	    GUI.config = CreateConfigWindow()
    end
end

local uiColors = {
        "FFe80a0a", -- (01) Cybran red
        "ff901427", -- (02) dark red
        "FFFF873E", -- (03) Nomads orange
        "ffb76518", -- (04) new brown
        "ffa79602", -- (05) Sera golden
        "fffafa00", -- (06) new yellow
        "ff9fd802", -- (07) Order Green
        "ff40bf40", -- (08) mid green
        "ff2e8b57", -- (09) new green
        "FF2F4F4F", -- (10) olive (dark green)
        "ff436eee", -- (11) new blue1
        "FF2929e1", -- (12) UEF blue
        "FF5F01A7", -- (13) dark purple
        "ff9161ff", -- (14) purple
        "ff66ffcc", -- (15) aqua
        "ffffffff", -- (16) white
		'ff000000', -- (20) black
        "ff616d7e", -- (17) grey
        "ffff88ff", -- (18) pink
        "ffff32ff", -- (19) new fuschia
    }

local ToggleOptions = {
    "On",
    "Off",
}

function CreateConfigWindow()
    local windowTextures = {
        m = UIUtil.SkinnableFile('/game/panel/panel_brd_m.dds'),
        borderColor = 'ff415055',
    }
	GUI.config = Window(GetFrame(0), 'Research Options', nil, nil, nil, true, nil, 'chat_config', nil, windowTextures)
	--function(self, parent, title, icon, pin, config, lockSize, lockPosition, prefID, defaultPosition, textureTable)
    GUI.config.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    Tooltip.AddButtonTooltip(GUI.config._closeBtn, 'chat_close')
    GUI.config.Top:Set(function() return GetFrame(0).Top() + 100 end)
    GUI.config.Width:Set(300)
    LayoutHelpers.AtHorizontalCenterIn(GUI.config, GetFrame(0))
    LayoutHelpers.ResetRight(GUI.config)
    
    GUI.config.OnClose = function(self)
        GUI.config:Destroy()
        GUI.config = false
    end
	
	local frColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	
	GUI.config.trF = Bitmap(GUI.config)
    GUI.config.trF:SetSolidColor(frColor)
    GUI.config.trF.Width:Set(50)
    GUI.config.trF.Height:Set(1)
    GUI.config.trF.Left:Set(function() return GUI.config.Left() end)
    GUI.config.trF.Bottom:Set(function() return GUI.config.Top() end)
	
	GUI.config.tlF = Bitmap(GUI.config)
    GUI.config.tlF:SetSolidColor(frColor)
    GUI.config.tlF.Width:Set(1)
    GUI.config.tlF.Height:Set(51)
    GUI.config.tlF.Right:Set(function() return GUI.config.Left() end)
    GUI.config.tlF.Top:Set(function() return GUI.config.Top() - 1 end)
	
	GUI.config.brF = Bitmap(GUI.config)
    GUI.config.brF:SetSolidColor(frColor)
    GUI.config.brF.Width:Set(1)
    GUI.config.brF.Height:Set(51)
    GUI.config.brF.Left:Set(function() return GUI.config.Right() end)
    GUI.config.brF.Bottom:Set(function() return GUI.config.Bottom() + 1 end)
	
	GUI.config.blF = Bitmap(GUI.config)
    GUI.config.blF:SetSolidColor(frColor)
    GUI.config.blF.Width:Set(50)
    GUI.config.blF.Height:Set(1)
    GUI.config.blF.Right:Set(function() return GUI.config.Right() end)
    GUI.config.blF.Top:Set(function() return GUI.config.Bottom() end)

    
    local options = {
        filters = {
			{type = 'filter', name = 'Experimental', key = '1', tooltip = 'Watch T4'},
			{type = 'filter', name = 'Nuke', key = '2', tooltip = 'Watch Nuke'},
			{type = 'filter', name = 'Commander', key = '3', tooltip = 'Watch Commander'},
			{type = 'filter', name = 'Subcommander', key = '4', tooltip = 'Watch Subcommander'},
			{type = 'toggle', name = 'Watch Toggle', key = 'watch_toggle', tooltip = 'Turn On/Off Area Watch'},
			{type = 'slider', name = 'Decal Size', key = 'decal_size', tooltip = 'Change decal size', min = 10, max = 100, inc = 1},
			{type = 'slider', name = 'Decal Life Time(s)', key = 'decal_lifetime', tooltip = 'Change decal life time, -1 forever', min = -1, max = 300, inc = 1},
		},
		winOptions = {
		    {type = 'color', name = 'UI Color', key = 'ui_color', tooltip = 'Change UI color'},
			{type = 'color', name = 'Font Color', key = 'font_color', tooltip = 'Chang font color'},
			{type = 'slider', name = 'Font Size', key = 'font_size', tooltip = 'Change font size', min = 10, max = 22, inc = 1},
			{type = 'slider', name = 'Buff Level', key = 'buff_Lvl', tooltip = 'Change buff level', min = 1, max = 10, inc = 1},
			--{type = 'splitter'},
			{type = 'slider', name = 'Event Size', key = 'event_size', tooltip = 'Change Event Alert Icon Size', min = 20, max = 100, inc = 1},
        },
    }
        
    local optionGroup = Group(GUI.config:GetClientGroup())
    LayoutHelpers.FillParent(optionGroup, GUI.config:GetClientGroup())
    optionGroup.options = {}
	
	local filterChecks = {}

    local function CreateSplitter()
        local splitter = Bitmap(optionGroup)
        splitter:SetSolidColor('ff000000')
        splitter.Left:Set(optionGroup.Left)
        splitter.Right:Set(optionGroup.Right)
        splitter.Height:Set(2)
        return splitter
    end
    
    local function CreateEntry(data)
        local group = Group(optionGroup)
		if data.type == 'filter' then
            group.name = UIUtil.CreateText(group, data.name, 14, "Arial")
            group.check = UIUtil.CreateCheckboxStd(group, '/dialogs/check-box_btn/radio')
            LayoutHelpers.AtLeftTopIn(group.check, group)
            LayoutHelpers.RightOf(group.name, group.check)
            LayoutHelpers.AtVerticalCenterIn(group.name, group.check)
            group.check.key = data.key
			table.insert(filterChecks, group.check)
            group.Height:Set(group.check.Height)
            group.Width:Set(function() return group.check.Width() + group.name.Width() end)
			group.check.OnCheck = function(self, checked)
			    if checked then
				    -- Uncheck all other checkboxes
					for _, cb in filterChecks do
					    if cb ~= self then
						    cb:SetCheck(false, true)
							Prefs.SetToCurrentProfile("Research_watch_key_"..cb.key, false)
						end
					end
					-- Save selected one
					Prefs.SetToCurrentProfile("Research_watch_key_"..self.key, true)
					-- Call your function
					import('/mods/Research FAF/lua/ui/IntelPanel.lua').SetupWatchCat(self.key)
				else
				    -- Prevent unchecking active one
					self:SetCheck(true, true)
				end
			end
        elseif data.type == 'color' then
            group.name = UIUtil.CreateText(group, data.name, 14, "Arial")
            local defValue = defOptions[data.key] or 1
            group.color = BitmapCombo(group, uiColors, defValue, true, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
            LayoutHelpers.AtLeftTopIn(group.color, group)
            LayoutHelpers.RightOf(group.name, group.color, 5)
            LayoutHelpers.AtVerticalCenterIn(group.name, group.color)
            group.color.Width:Set(55)
            group.color.key = data.key
            group.Height:Set(group.color.Height)
            group.Width:Set(group.color.Width)
            group.color.OnClick = function(self, index)
				ForkThread(function()
				    if self.key == 'ui_color' then
					    import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor = uiColors[index]
						Prefs.SetToCurrentProfile("Research_ui_color", uiColors[index])
						Prefs.SetToCurrentProfile("Research_ui_color_index", index)
						import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.abBG:SetSolidColor(uiColors[index])
						GUI.config.trF:SetSolidColor(uiColors[index])
						GUI.config.tlF:SetSolidColor(uiColors[index])
						GUI.config.brF:SetSolidColor(uiColors[index])
						GUI.config.blF:SetSolidColor(uiColors[index])
						if not import('/mods/Research FAF/lua/ui/Reinforcement.lua').ReinfActive == false then 
						    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').REwindow:SetSolidColor(uiColors[index])
						end
						if not import('/mods/Research FAF/lua/ui/FPSHero.lua').DFActive == false then 
						    import('/mods/Research FAF/lua/ui/AbilityMenu.lua').DFwindow:SetSolidColor(uiColors[index])
						end
					elseif self.key == 'font_color' then
					    import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor = uiColors[index]
						Prefs.SetToCurrentProfile("Research_font_color", uiColors[index])
						Prefs.SetToCurrentProfile("Research_font_color_index", index)
						import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.abilityText:SetColor(uiColors[index])
						if not import('/mods/Research FAF/lua/ui/Reinforcement.lua').countdownText == false then 
						    import('/mods/Research FAF/lua/ui/Reinforcement.lua').countdownText:SetColor(uiColors[index]) 
						end
					end
				end)
            end
		elseif data.type == 'toggle' then
            group.name = UIUtil.CreateText(group, data.name, 14, "Arial")
            local defValue = defOptions[data.key] or 1
			local Combo = import('/lua/ui/controls/combo.lua').Combo
			group.mode = Combo(group, 14, 10, nil, nil, "UI_Tab_Click_01", "UI_Tab_Rollover_01")
            LayoutHelpers.AtLeftTopIn(group.mode, group)
            LayoutHelpers.RightOf(group.name, group.mode, 5)
            LayoutHelpers.AtVerticalCenterIn(group.name, group.mode)
            group.mode.Width:Set(55)
            group.mode.key = data.key
            group.Height:Set(group.mode.Height)
            group.Width:Set(group.mode.Width)
			group.mode:AddItems(ToggleOptions, 1)
			group.mode.OnClick = function(self, index, text, skipUpdate) 
				SimCallback({Func = 'AreaWatchToggle', Args = text})
			end
        elseif data.type == 'slider' then
            group.name = UIUtil.CreateText(group, data.name, 14, "Arial")
            LayoutHelpers.AtLeftTopIn(group.name, group)
            group.slider = IntegerSlider(group, false, 
                data.min, data.max, 
                data.inc, UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), 
                UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), 
                UIUtil.SkinnableFile('/dialogs/options-02/slider-back_bmp.dds')
			)
            LayoutHelpers.Below(group.slider, group.name)
            group.slider.key = data.key
            group.Height:Set(function() return group.name.Height() + group.slider.Height() end)
            group.value = UIUtil.CreateText(group, '', 14, "Arial")
            LayoutHelpers.RightOf(group.value, group.slider)
            group.slider.OnValueChanged = function(self, newValue)
                group.value:SetText(string.format('%3d', newValue))
				if self.key == 'font_size' then 
				    import('/mods/Research FAF/lua/ui/InitialData.lua').fontSize = newValue
					Prefs.SetToCurrentProfile("Research_font_size", newValue)
					import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.abilityText:SetFont(UIUtil.titleFont, newValue)
				elseif self.key == 'buff_Lvl' then 
				    import('/mods/Research FAF/lua/ui/InitialData.lua').buffLvl = newValue
					Prefs.SetToCurrentProfile("Research_buff_Lvl", newValue)
				elseif self.key == 'decal_size' then 
				    SimCallback({Func = 'SetDecalSize', Args = newValue})
					Prefs.SetToCurrentProfile("Research_decal_size_index", newValue)
				elseif self.key == 'decal_lifetime' then 
				    SimCallback({Func = 'SetDecalLifeTime', Args = newValue})
					Prefs.SetToCurrentProfile("Research_decal_lifetime_index", newValue)
				elseif self.key == 'event_size' then 
				    import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize = newValue
					import('/mods/Research FAF/lua/ui/EventTab.lua').RestoreBG()
					Prefs.SetToCurrentProfile("Research_event_size", newValue)
				end
				
            end
            local defValue = defOptions[data.key] or 1
            group.slider:SetValue(defValue)
            group.Width:Set(200)
        elseif data.type == 'splitter' then
            group.split = CreateSplitter()
            LayoutHelpers.AtTopIn(group.split, group)
            group.Width:Set(group.split.Width)
            group.Height:Set(group.split.Height)
        end
        if data.type != 'splitter' then
            Tooltip.AddControlTooltip(group, data.tooltip)
        end

        return group
    end

    local splitter = CreateSplitter()
    LayoutHelpers.AtLeftTopIn(splitter, optionGroup, 0, 5)

    local filterTitle = UIUtil.CreateText(optionGroup, 'Area Watch Filters', 14, "Arial Bold")
	LayoutHelpers.Below(filterTitle, splitter, 5)
	Tooltip.AddControlTooltip(filterTitle, 'Select unit type to watch')
	
	local index = 1
    for i, v in options.filters do
        optionGroup.options[index] = CreateEntry(v)
        optionGroup.options[index].Left:Set(filterTitle.Left)
        optionGroup.options[index].Right:Set(optionGroup.Right)
        if index == 1 then
            LayoutHelpers.Below(optionGroup.options[index], filterTitle, 5)
			optionGroup.options[index].Right:Set(function() return filterTitle.Left() + (optionGroup.Width() / 2) end)
        elseif v.type == 'slider' then
		    LayoutHelpers.Below(optionGroup.options[index], optionGroup.options[index-1], 4)
            LayoutHelpers.AtHorizontalCenterIn(optionGroup.options[index], optionGroup)
		else
			optionGroup.options[index].Right:Set(function() return filterTitle.Left() + (optionGroup.Width() / 2) end)
			if math.mod(index, 2) == 1 then
                LayoutHelpers.Below(optionGroup.options[index], optionGroup.options[index-2], 2)
            else
                LayoutHelpers.RightOf(optionGroup.options[index], optionGroup.options[index-1])
            end
        end
        index = index + 1
    end
	
	local splitIndex = index
    local splitter = CreateSplitter()
    splitter.Top:Set(function() return optionGroup.options[splitIndex-1].Bottom() + 5 end)
	
    local WindowTitle = UIUtil.CreateText(optionGroup, 'UI Setting', 14, "Arial Bold")
    LayoutHelpers.Below(WindowTitle, splitter, 5)
    WindowTitle.Left:Set(filterTitle.Left)
    Tooltip.AddControlTooltip(WindowTitle, 'Setup UI')

    local firstOption = true
    local optionIndex = 1
    for i, v in options.winOptions do
        optionGroup.options[index] = CreateEntry(v)
        optionGroup.options[index].Data = v
        if firstOption then
            LayoutHelpers.Below(optionGroup.options[index], WindowTitle, 5)
            optionGroup.options[index].Right:Set(function() return WindowTitle.Left() + (optionGroup.Width() / 2) end)
            firstOption = false
        elseif v.type == 'color' then
            optionGroup.options[index].Right:Set(function() return WindowTitle.Left() + (optionGroup.Width() / 2) end)
            if math.mod(optionIndex, 2) == 1 then
                LayoutHelpers.Below(optionGroup.options[index], optionGroup.options[index-2], 2)
            else
                LayoutHelpers.RightOf(optionGroup.options[index], optionGroup.options[index-1])
            end
        else
            LayoutHelpers.Below(optionGroup.options[index], optionGroup.options[index-1], 4)
            LayoutHelpers.AtHorizontalCenterIn(optionGroup.options[index], optionGroup)
        end
        optionIndex = optionIndex + 1
        index = index + 1
    end

	local restored = false
	for _, cb in filterChecks do
	    if Prefs.GetFromCurrentProfile("Research_watch_key_"..cb.key) then
		    cb:SetCheck(true)
			restored = true
			import('/mods/Research FAF/lua/ui/IntelPanel.lua').SetupWatchCat(cb.key)
			break
		end
	end
	
	-- fallback default if nothing stored
	if not restored and filterChecks[1] then
	    filterChecks[1]:SetCheck(true)
		import('/mods/Research FAF/lua/ui/IntelPanel.lua').SetupWatchCat(filterChecks[1].key)
	end
    
    GUI.config.Bottom:Set(function() return optionGroup.options[index-1].Bottom() + 10 end)
	
	return GUI.config
end
