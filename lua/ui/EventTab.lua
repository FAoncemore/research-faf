local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Prefs = import('/lua/user/prefs.lua')

local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1
local parentBG = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg

local buttonSize = import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize
local btnSpacing = 3
local maxEvents = 10

local eventButtons = {}
local eventStart = 1
local eventBG
local eventCameraActive = false

function Initial(toggle)
    eventCameraActive = toggle
	if eventCameraActive == true then
	    if eventBG then eventBG:Show() end
	elseif eventCameraActive == false then
	    if eventBG then eventBG:Hide() end
	end
end

local iconCache = {}

function GetUnitIcon(unitId)
    if iconCache[unitId] then
        return iconCache[unitId]
    end

    -- Check vanilla & mods path first
    local iconPath = UIUtil.UIFile('/icons/units/' .. unitId .. '_icon.dds', true)

    -- If the icon was found, cache and return it
    if iconPath then
        iconCache[unitId] = iconPath
    else
        -- No icon found, return a default icon
        iconCache[unitId] = UIUtil.UIFile('/textures/ui/common/icons/units/default_icon.dds')
        WARN("Icon not found for unit: " .. unitId)
    end

    return iconCache[unitId]
end

-- Initialize parent bar
function InitEventUI()
    if eventBG then return end
    eventBG = Bitmap(parentBG)
	local buttonSize = import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize
    eventBG.Width:Set(buttonSize*maxEvents*scale + btnSpacing*(maxEvents-1)*scale)
    eventBG.Height:Set(buttonSize*scale)
	eventBG:SetSolidColor('1acccccc')
    LayoutHelpers.AtTopIn(eventBG, GetFrame(0), 5)
    LayoutHelpers.AtHorizontalCenterIn(eventBG, GetFrame(0))
	eventBG.Depth:Set(function() return GetFrame(0).Depth() + 2 end)
	
	if eventCameraActive == false then
	    --store events, but hide the UI
		if eventBG then eventBG:Hide() end
	end
end

-- Add a new event
function EventAlertId(data)
	InitEventUI()
	AddEventButtonOptimized(data)
	RelayoutButtonsOptimized()
end

-- Add a button with fade-out support
function AddEventButtonOptimized(data)
    local buttonSize = import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize
    local icon = false
	icon = GetUnitIcon(data[2])

    local btn = Button(eventBG, icon, icon, icon, icon)
    btn.Width:Set(buttonSize*scale)
    btn.Height:Set(buttonSize*scale)
    LayoutHelpers.AtVerticalCenterIn(btn, eventBG)
    btn.Depth:Set(function() return eventBG.Depth() + 10 end)

	-- Adding hover effect (glow) on the icon
	local iconGlow = Bitmap(btn)
	iconGlow.Width:Set(btn.Width())
	iconGlow.Height:Set(btn.Height())
	iconGlow:SetSolidColor('yellow')  -- Adjust glow color
	iconGlow:SetAlpha(0)  -- Initially invisible
	LayoutHelpers.AtLeftIn(iconGlow, btn)
	LayoutHelpers.AtVerticalCenterIn(iconGlow, btn)
	
	iconGlow.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    iconGlow:SetAlpha(0.5)  -- Show glow on hover
		elseif event.Type == 'MouseExit' then
		    iconGlow:SetAlpha(0)  -- Hide glow when the mouse is out
		end
	end

    -- Background colored by army
    local btnBG = Bitmap(btn)
    local armyColor = GetArmiesTable().armiesTable[data[3]].color or 'FF004142' -- observer
    btnBG:SetSolidColor(armyColor)
    btnBG.Width:Set(btn.Width())
    btnBG.Height:Set(btn.Height())
    LayoutHelpers.AtLeftTopIn(btnBG, btn)
    btnBG.Depth:Set(function() return btn.Depth() - 1 end)

    -- Event title text
    --local eventTitle = Bitmap(btnBG)
    --eventTitle.Width:Set(function() return btnBG.Width() end)
    --eventTitle.Height:Set(20)
    --eventTitle.Left:Set(function() return btnBG.Left() end)
    --eventTitle.Top:Set(function() return btnBG.Bottom() end)
    --eventTitle.Depth:Set(0)
    --eventTitle:SetSolidColor('E6333333')
    --eventTitle.text= UIUtil.CreateText(eventTitle, '', 12, UIUtil.bodyFont)
    --LayoutHelpers.AtCenterIn(eventTitle.text, eventTitle)
    if data[4] == 'Destroyed' then
		--eventTitle.text:SetText(data[4])
        --eventTitle.text:SetColor('White')
		--btn.text = eventTitle.text
        btn.isDestroyedEvent = true  -- mark for vertical bounce
        btn.bounceDir = -1           -- start moving up
        btn.bounceAmount = 0
        btn.bounceTime = 0           -- track elapsed time for decay
		btn.bounceDuration = 2.2
    end

    -- Click camera region
    local rect = Rect(
        data[1][1] - 20,
        data[1][3] - 20,
        data[1][1] + 20,
        data[1][3] + 20
    )
    btn.OnClick = function()
        GetCamera("WorldCamera"):MoveToRegion(rect, 1.0)
    end
	
	#not in drag buid mode, if we are in drag build, we cannot turn On/Off the minimap, otherwise the sudden appearing/disappearing of minimap will cause building in error.
	#['01'] = 'LeftMouse'
	#key down means holding a key, button press/mouse click means pressing the button once and then release it

	btn.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    if not IsKeyDown('1') then 
			    import('/mods/Research FAF/lua/ui/EventReminder.lua').CreatEventCam(btn, data[1], {data[2]}, armyColor, data[4])
				PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
			end
		elseif event.Type == 'ButtonPress' then
		    btn.OnClick()
		elseif event.Type == 'MouseExit' then
			if not IsKeyDown('1') then 
			    import('/mods/Research FAF/lua/ui/EventReminder.lua').KillEventMonitor()
			end
		end
	end

    -- Spawn outside right
    btn.Left:Set(eventBG.Right() + buttonSize)
    btn:SetAlpha(1)
    btn.targetX = btn.Left()
    btn:SetNeedsFrameUpdate(true)
	
	-- Initialize fade-in effect
	btn:SetAlpha(0)  -- start as invisible
	btn.fadeInTime = 0  -- track the fade-in progress
	btn.fadeInDuration = 1.0  -- time in seconds to fade in


    -- OnFrame handles sliding + fade
	btn.OnFrame = function(self, delta)
	
        -- Fade-in logic
		if self.fadeInTime < self.fadeInDuration then
		    local alpha = self.fadeInTime / self.fadeInDuration
			self.fadeInTime = self.fadeInTime + delta
			self:SetAlpha(math.min(1, alpha))
		end
	
	    local cur = self.Left()
		local speed = 300 * delta
		
		-- Slide towards target
		if math.abs(self.targetX - cur) < speed then
		    self.Left:Set(self.targetX)
		elseif self.targetX > cur then 
		    self.Left:Set(cur + speed)
		else
		    self.Left:Set(cur - speed)
		end
		
		local alpha = self:GetAlpha()
		-- Fade-out with sharper squish
		if self.fading then
            alpha = math.max(0, alpha - delta * 3)  -- faster fade
			self:SetAlpha(alpha)
			
			-- Sharper squish: width shrinks more, height stretches more
			local squash = 0.6 + 0.4 * alpha      -- from 1.0 -> 0.6
			local stretch = 1.0 + 0.4 * (1 - alpha) -- from 1.0 -> 1.4
			self.Width:Set(buttonSize*scale*squash)
			self.Height:Set(buttonSize*scale*stretch)
			
			if alpha <= 0 then
			    self:Destroy()
			end
		elseif alpha < 1 then
		    -- Fade-in
			alpha = math.min(1, alpha + delta * 3)
			self:SetAlpha(alpha)
		else
            -- Restore normal size after fade-in
			self.Width:Set(buttonSize*scale)
			self.Height:Set(buttonSize*scale)
		end
		
		-- Vertical bounce for Destroyed events (unchanged)
		if self.isDestroyedEvent then
		    self.bounceTime = self.bounceTime + delta
			local t = self.bounceTime / self.bounceDuration
			if t >= 1 then
			    self.Top:Set(eventBG.Top())
				self.Left:Set(self.targetX)
				self.isDestroyedEvent = false
				--btn.text:Destroy()
				btnBG:SetSolidColor(armyColor)
			else
			    local impact = math.sin(t * math.pi)  -- big jump
				local settle = math.sin(t * math.pi * 4)  -- small bounces
				local decay = (1 - t)
				local offset = (impact * 18 + settle * 6) * decay
				self.Top:Set(eventBG.Top() + offset)
				
				-- Apply the pop effect: scaling during bounc
				local scaleFactor = 1 + 0.15 * (1 - decay)  -- 1 -> 1.15 scaling
				self.Width:Set(buttonSize * scaleFactor * scale)
				self.Height:Set(buttonSize * scaleFactor * scale)

				local flash = math.sin(t * 10) * 0.5 + 0.5  -- quick pulse
				btnBG:SetSolidColor(string.format('FF%02X%02X00', 255, 255 * flash))
			end
		end
	end
	
    table.insert(eventButtons, btn)

    -- If too many, fade out oldest
    local total = table.getn(eventButtons)
    if (total - eventStart + 1) > maxEvents then
        local old = eventButtons[eventStart]
        if old then
            old.fading = true -- triggers fade-out
        end
        eventStart = eventStart + 1
    end
end

-- Slide all visible buttons
function RelayoutButtonsOptimized()
    local buttonSize = import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize
	local startX = eventBG.Left()
    local spacing = buttonSize*scale + btnSpacing
    local total = table.getn(eventButtons)
    local visibleCount = math.min(maxEvents, total - eventStart + 1)

    for i = 0, visibleCount-1 do
        local btn = eventButtons[eventStart + i]
        btn.targetX = startX + i * spacing
    end
end

function RestoreBG()
    if eventBG then 
	    local buttonSize = import('/mods/Research FAF/lua/ui/InitialData.lua').eventSize
		eventBG.Width:Set(buttonSize*maxEvents*scale + btnSpacing*(maxEvents-1)*scale)
		eventBG.Height:Set(buttonSize*scale)
	end
end