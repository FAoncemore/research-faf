local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Edit = import('/lua/maui/edit.lua').Edit
local Button = import('/lua/maui/button.lua').Button
local Group = import('/lua/maui/group.lua').Group
local IntegerSlider = import('/lua/maui/slider.lua').IntegerSlider
local Tooltip = import('/lua/ui/game/tooltip.lua')

local Prefs = import('/lua/user/prefs.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local PREF_UNIT_CAP = 'Researc_FAF_unitCap'


local dialog = false
local maxCap = 99999

GUI = {
    bg = false,
}

function Initial()
    ForkThread(function()
		ForkThread(function()
		    WaitSeconds(10)
			local savedCap = Prefs.GetFromCurrentProfile(PREF_UNIT_CAP)
			if savedCap then SimCallback({Func = 'ResearchUnitCap', Args = savedCap}) end
		end)
	    
		local controls = import('/lua/ui/game/score.lua').controls.units
		local bg = Bitmap(controls)
		bg.Width:Set(function() return controls.Width() end)
		bg.Height:Set(function() return controls.Height() end)
		LayoutHelpers.AtLeftTopIn(bg, controls)
		bg.Depth:Set(function() return controls.Depth() - 1 end)
		
		local capButton = Button(controls,bg,bg,bg,bg)
		capButton.Width:Set(function() return controls.Width() end)
		capButton.Height:Set(function() return controls.Height() end)
		LayoutHelpers.AtLeftTopIn(capButton, controls)
		capButton.Depth:Set(function() return controls.Depth() + 1 end)
		
		capButton.OnClick = function()
		    CreateUnitCapDialog(controls)
		end
	end)
end

function CreateUnitCapDialog(controls)
    -- Dialog already showing? Don't show another one
    if dialog then return end
	
	dialog = Bitmap(GetFrame(0))
    LayoutHelpers.AtCenterIn(dialog, GetFrame(0))
	dialog:SetSolidColor('ff1e1e1e')
	dialog.Width:Set(320*scale)
	dialog.Height:Set(50*scale)
	dialog.Depth:Set(GetFrame(0):GetTopmostDepth()+1)
	
    dialog.title = UIUtil.CreateText(dialog, "Unit Cap", 18, UIUtil.titleFont)
	LayoutHelpers.AtCenterIn(dialog.title, dialog)
    LayoutHelpers.AtHorizontalCenterIn(dialog.title, dialog)
	
	local sliderbg = Bitmap(dialog)
	sliderbg.Width:Set(dialog.Width())
	sliderbg.Height:Set(80*scale)
	sliderbg.Left:Set(function() return dialog.Left() end)
	sliderbg.Top:Set(function() return dialog.Bottom() end)
	sliderbg:SetSolidColor('ff333333')
	sliderbg.Depth:Set(function() return dialog.Depth() + 1 end)
	
	local sliderFrame = Bitmap(sliderbg)
	sliderFrame.Width:Set(dialog.Width()*0.8)
	sliderFrame.Height:Set(60*scale)
	LayoutHelpers.AtCenterIn(sliderFrame, sliderbg)
    LayoutHelpers.AtHorizontalCenterIn(sliderFrame, sliderbg)
	sliderFrame:SetSolidColor('ff333333')
	sliderFrame.Depth:Set(function() return sliderbg.Depth() + 1 end)
	
	local colorCode = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	sliderFrame.border = Bitmap(sliderbg)
	sliderFrame.border:SetSolidColor(colorCode)
	sliderFrame.border.Left:Set(function() return sliderFrame.Left() - 1 end)
	sliderFrame.border.Top:Set(function() return sliderFrame.Top() - 1 end)
	sliderFrame.border.Width:Set(function() return sliderFrame.Width() + 2 end)
	sliderFrame.border.Height:Set(function() return sliderFrame.Height() + 2 end)
	sliderFrame.border.Depth:Set(function() return sliderFrame.Depth() - 1 end)

	sliderbg.Text = UIUtil.CreateText(sliderFrame, "Slider : ", 16, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(sliderbg.Text, sliderFrame, 20*scale, 20*scale)
	
	local digitsbg = Bitmap(dialog)
	digitsbg.Width:Set(dialog.Width())
	digitsbg.Height:Set(80*scale)
	digitsbg.Left:Set(function() return sliderbg.Left() end)
	digitsbg.Top:Set(function() return sliderbg.Bottom() end)
	digitsbg:SetSolidColor('ff333333')
	digitsbg.Depth:Set(function() return dialog.Depth() + 1 end)
	
	local digitFrame = Bitmap(digitsbg)
	digitFrame.Width:Set(dialog.Width()*0.8)
	digitFrame.Height:Set(60*scale)
	LayoutHelpers.AtCenterIn(digitFrame, digitsbg)
    LayoutHelpers.AtHorizontalCenterIn(digitFrame, digitsbg)
	digitFrame:SetSolidColor('ff333333')
	digitFrame.Depth:Set(function() return digitsbg.Depth() + 1 end)
	
	digitFrame.border = Bitmap(digitsbg)
	digitFrame.border:SetSolidColor(colorCode)
	digitFrame.border.Left:Set(function() return digitFrame.Left() - 1 end)
	digitFrame.border.Top:Set(function() return digitFrame.Top() - 1 end)
	digitFrame.border.Width:Set(function() return digitFrame.Width() + 2 end)
	digitFrame.border.Height:Set(function() return digitFrame.Height() + 2 end)
	digitFrame.border.Depth:Set(function() return digitFrame.Depth() - 1 end)
	
	digitsbg.Text = UIUtil.CreateText(digitFrame, 'Input : ', 16, UIUtil.bodyFont)
    LayoutHelpers.AtLeftTopIn(digitsbg.Text, digitFrame, 20*scale, 20*scale)
	
	local btnBG = Bitmap(dialog)
	btnBG.Width:Set(dialog.Width())
	btnBG.Height:Set(60*scale)
	btnBG.Left:Set(function() return digitsbg.Left() end)
	btnBG.Top:Set(function() return digitsbg.Bottom() end)
	btnBG.Depth:Set(function() return dialog.Depth() + 1 end)
	btnBG:SetSolidColor('ff333333')

	--shadow
	dialog.shadow = Bitmap(dialog)
	dialog.shadow:SetSolidColor('7f1a1a1a')
	dialog.shadow.Left:Set(function() return dialog.Left() + 4 end)
	dialog.shadow.Top:Set(function() return dialog.Top() + 4 end)
	dialog.shadow.Width:Set(function() return dialog.Width() + 4 end)
	dialog.shadow.Height:Set(function() return dialog.Height() + sliderbg.Height() + digitsbg.Height() + btnBG.Height() + 4 end)
	dialog.shadow.Depth:Set(function() return dialog.Depth() - 2 end)
	
	-- OK button bg
	local buttonBG = Bitmap(btnBG)
	buttonBG:SetSolidColor('ff333333')
	buttonBG.Width:Set(40*scale)
	buttonBG.Height:Set(30*scale)
	LayoutHelpers.AtCenterIn(buttonBG, btnBG)
	LayoutHelpers.AtHorizontalCenterIn(buttonBG, btnBG)
	buttonBG.Depth:Set(function() return btnBG.Depth() + 2 end)
	
	local okButton = Button(buttonBG, buttonBG, buttonBG, buttonBG)
	okButton.Width:Set(40*scale)
	okButton.Height:Set(30*scale)
	LayoutHelpers.AtCenterIn(okButton, buttonBG)
	LayoutHelpers.AtBottomIn(okButton, buttonBG)
	okButton.Depth:Set(function() return buttonBG.Depth() + 1 end)
	
	-- OK button Border
	okButton.border = Bitmap(btnBG)
	okButton.border:SetSolidColor('000000')
	okButton.border.Left:Set(function() return okButton.Left() -1 end)
	okButton.border.Top:Set(function() return okButton.Top() -1 end)
	okButton.border.Width:Set(function() return okButton.Width() +2 end)
	okButton.border.Height:Set(function() return okButton.Height() +2 end)
	okButton.border.Depth:Set(function() return buttonBG.Depth() - 1 end)
	
	okButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
	    	okButton.border:SetSolidColor(colorCode)
		elseif event.Type == 'ButtonPress' then
		    self.OnClick()
		elseif event.Type == 'MouseExit' then
		    okButton.border:SetSolidColor('000000')
		end
	end

	okButton.label = UIUtil.CreateText(okButton, 'OK', 12, UIUtil.buttonFont)
    LayoutHelpers.AtCenterIn(okButton.label, okButton)
	okButton.label.Depth:Set(function() return okButton.Depth() + 1 end)
	
	local sliderGroup = Group(sliderFrame)
	
	local savedCap = Prefs.GetFromCurrentProfile(PREF_UNIT_CAP)
	local currentCap = tonumber(string.match(controls:GetText(), "/(%d+)")) or 500
	local unitCap = tonumber(savedCap) or currentCap
	unitCap = math.min(unitCap, maxCap)

	sliderGroup._slider = IntegerSlider(sliderGroup, false, 1, maxCap, 1, 
	    UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), 
		UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), 
		UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), 
		UIUtil.SkinnableFile('/game/resource-bars/mini-energy-bar_bmp.dds')
	)
			
	sliderGroup._slider.Top:Set(function() return sliderbg.Text.Top() end)
	sliderGroup._slider.Left:Set(function() return sliderbg.Text.Right() + 10*scale end)
	sliderGroup._slider:SetValue(unitCap)
	
	local function FlashText(textCtrl)
        textCtrl:SetColor('ffffff00') -- yellow
		ForkThread(function()
		    WaitSeconds(0.15)
			textCtrl:SetColor('ffffffff')
		end)
	end

	local inputBG = Bitmap(digitsbg)
	--inputBG.Width:Set(200*scale)
	inputBG.Height:Set(30*scale)
	inputBG.Left:Set(function() return sliderGroup._slider.Left() end)
	inputBG.Right:Set(function() return sliderGroup._slider.Right() end)
	inputBG.Top:Set(function() return digitsbg.Text.Top() - 3*scale end)
	inputBG:SetSolidColor('7f999999')
	
    local nameEdit = Edit(inputBG)
	nameEdit.Left:Set(function() return inputBG.Left() + 5*scale end)
	nameEdit.Top:Set(function() return digitsbg.Text.Top() end)
    nameEdit.Width:Set(100*scale)
    nameEdit.Height:Set(nameEdit:GetFontHeight())
	nameEdit.Depth:Set(function() return inputBG.Depth() +1 end)
    nameEdit:ShowBackground(false)
    nameEdit:AcquireFocus()
    UIUtil.SetupEditStd(nameEdit, "ff00ff00", nil, nil, nil, UIUtil.bodyFont, 16, 5) -- green color
	--SetupEditStd(control, foreColor, backColor, highlightFore, highlightBack, fontFace, fontSize, charLimit)
	nameEdit:SetText(unitCap)
	
	sliderGroup._slider.OnValueChanged = function(self, newValue)
		nameEdit:SetText(newValue)
		FlashText(sliderbg.Text)
	end
	
	nameEdit.OnEnterPressed = function(self, text)
        okButton.OnClick()
    end
	
	nameEdit.OnTextChanged = function(self, newText)
        local num = tonumber(newText)
		if num then
		    num = math.max(1, math.min(num, maxCap))
			sliderGroup._slider:SetValue(num)
		end
		
	end

	okButton.OnClick = function()
	    local cap = tonumber(nameEdit:GetText())
		if not cap then return end
		cap = math.max(1, math.min(cap, maxCap))
		
		-- Save to Prefs
		local lastSaved = Prefs.GetFromCurrentProfile(PREF_UNIT_CAP)
		if lastSaved ~= cap then
		    Prefs.SetToCurrentProfile(PREF_UNIT_CAP, cap)
			Prefs.SavePreferences()
		end
		
		-- Apply to sim
		SimCallback({Func = 'ResearchUnitCap', Args = cap})
		dialog:Destroy()
		dialog = false
	end

end