local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local cmdMode = import('/lua/ui/game/commandmode.lua')
local Edit = import('/lua/maui/edit.lua').Edit
local Button = import('/lua/maui/button.lua').Button
local Prefs = import('/lua/user/prefs.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local dialog = false
local userInputText = false

function CreateTextDialog()
    if dialog then return end
	
	dialog = Bitmap(GetFrame(0))
    LayoutHelpers.AtCenterIn(dialog, GetFrame(0))
	dialog:SetSolidColor('ff333333')
	dialog.Width:Set(500*scale)
	dialog.Height:Set(500*scale)
	dialog.Depth:Set(GetFrame(0):GetTopmostDepth()+1)

	--shadow
	dialog.shadow = Bitmap(dialog)
	dialog.shadow:SetSolidColor('7f1a1a1a')
	dialog.shadow.Left:Set(function() return dialog.Left() + 4*scale end)
	dialog.shadow.Top:Set(function() return dialog.Top() + 4*scale end)
	dialog.shadow.Width:Set(function() return dialog.Width() + 4*scale end)
	dialog.shadow.Height:Set(function() return dialog.Height() + 4*scale end)
	dialog.shadow.Depth:Set(function() return dialog.Depth() - 2 end)
	
	--title
	local titleBG = Bitmap(dialog)
	titleBG.Width:Set(function() return dialog.Width() end)
	titleBG.Height:Set(60*scale)
	LayoutHelpers.AtLeftTopIn(titleBG, dialog)
	titleBG:SetSolidColor('ff000000')
	titleBG.Depth:Set(function() return dialog.Depth() + 1 end)
	
	local armiesInfo = GetArmiesTable()
	local focusArmy = armiesInfo.focusArmy
	local playerName = armiesInfo.armiesTable[focusArmy].nickname
    titleBG.title = UIUtil.CreateText(titleBG, playerName.." Text Nuke", 18, UIUtil.titleFont)
	LayoutHelpers.AtCenterIn(titleBG.title, titleBG)
    LayoutHelpers.AtHorizontalCenterIn(titleBG.title, titleBG)
	
	--tips
	local tipsBG = Bitmap(dialog)
	tipsBG.Width:Set(function() return dialog.Width() end)
	tipsBG.Height:Set(60*scale)
	LayoutHelpers.Below(tipsBG, titleBG)
	tipsBG.Depth:Set(function() return dialog.Depth() + 1 end)
	
    tipsBG.desc = UIUtil.CreateText(tipsBG, "Enter text below to nuke in customized text formation (A-Z, 0-9)", 15, UIUtil.bodyFont)
	LayoutHelpers.AtCenterIn(tipsBG.desc, tipsBG)
    LayoutHelpers.AtHorizontalCenterIn(tipsBG.desc, tipsBG)

	--input
	local inputBG = Bitmap(dialog)
	inputBG.Width:Set(function() return dialog.Width() end)
	inputBG.Height:Set(60*scale)
	LayoutHelpers.Below(inputBG, tipsBG)
	inputBG.Depth:Set(function() return dialog.Depth() + 1 end)
	
	local textBG = Bitmap(inputBG)
	textBG.Width:Set(function() return inputBG.Width() * 0.8 end)
	textBG.Height:Set(function() return inputBG.Height() * 0.9 end)
	LayoutHelpers.AtCenterIn(textBG, inputBG)
	LayoutHelpers.AtHorizontalCenterIn(textBG, inputBG)
	textBG:SetSolidColor('ff333333')
	textBG.Depth:Set(function() return inputBG.Depth() + 2 end)

    local colorCode = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
	textBG.border = Bitmap(textBG)
	textBG.border:SetSolidColor(colorCode)
	textBG.border.Left:Set(function() return textBG.Left() - 1*scale end)
	textBG.border.Top:Set(function() return textBG.Top() - 1*scale end)
	textBG.border.Width:Set(function() return textBG.Width() + 2*scale end)
	textBG.border.Height:Set(function() return textBG.Height() + 2*scale end)
	textBG.border.Depth:Set(function() return textBG.Depth() - 1 end)
    
    local nameEdit = Edit(textBG)
    nameEdit.Width:Set(function() return textBG.Width()*0.9 end)
    nameEdit.Height:Set(nameEdit:GetFontHeight())
	LayoutHelpers.AtCenterIn(nameEdit, textBG)
    LayoutHelpers.AtHorizontalCenterIn(nameEdit, textBG)
    nameEdit:ShowBackground(false)
    nameEdit:AcquireFocus()
    UIUtil.SetupEditStd(nameEdit, colorCode, nil, nil, nil, UIUtil.bodyFont, 18, 33)
	
	--space bg
	local spBG = Bitmap(dialog)
	spBG.Width:Set(function() return dialog.Width() end)
	spBG.Height:Set(60*scale)
	LayoutHelpers.Below(spBG, inputBG)
	spBG.Depth:Set(function() return dialog.Depth() + 1 end)
	
	--button bg
	local btnBG = Bitmap(spBG)
	btnBG.Width:Set(function() return textBG.border.Width() end)
	btnBG.Height:Set(50*scale)
	LayoutHelpers.Below(btnBG, textBG.border, 10*scale)
	btnBG.Depth:Set(function() return spBG.Depth() + 1 end)
	
	dialog.Height:Set(function() return titleBG.Height() + tipsBG.Height() + inputBG.Height() + spBG.Height() end)
	dialog.shadow.Height:Set(function() return dialog.Height() + 4*scale end)
	
	-- Cancel button bg
	local cancelBG = Bitmap(btnBG)
	cancelBG:SetSolidColor('ff333333')
	cancelBG.Width:Set(60*scale)
	cancelBG.Height:Set(30*scale)
	LayoutHelpers.AtRightTopIn(cancelBG, btnBG)
	cancelBG.Depth:Set(function() return btnBG.Depth() + 2 end)
	
	local cancelButton = Button(cancelBG, cancelBG, cancelBG, cancelBG)
	cancelButton.Width:Set(60*scale)
	cancelButton.Height:Set(function() return cancelBG.Height () end)
	LayoutHelpers.AtCenterIn(cancelButton, cancelBG)
	LayoutHelpers.AtHorizontalCenterIn(cancelButton, cancelBG)
	cancelButton.Depth:Set(function() return cancelBG.Depth() + 1 end)
	
	cancelButton.label = UIUtil.CreateText(cancelButton, 'Cancel', 12, UIUtil.buttonFont)
    LayoutHelpers.AtCenterIn(cancelButton.label, cancelButton)
	cancelButton.label.Depth:Set(function() return cancelButton.Depth() + 1 end)
	
	-- Cancel button Border
	cancelButton.border = Bitmap(cancelBG)
	cancelButton.border:SetSolidColor('000000')
	cancelButton.border.Left:Set(function() return cancelButton.Left() -1*scale end)
	cancelButton.border.Top:Set(function() return cancelButton.Top() -1*scale end)
	cancelButton.border.Width:Set(function() return cancelButton.Width() +2*scale end)
	cancelButton.border.Height:Set(function() return cancelButton.Height() +2*scale end)
	cancelButton.border.Depth:Set(function() return cancelBG.Depth() - 1 end)
	
	-- OK button bg
	local okBG = Bitmap(btnBG)
	okBG:SetSolidColor('ff333333')
	okBG.Width:Set(60*scale)
	okBG.Height:Set(30*scale)
	LayoutHelpers.LeftOf(okBG, cancelButton, 10*scale, 0)
	okBG.Depth:Set(function() return btnBG.Depth() + 2 end)
	
	local okButton = Button(okBG, okBG, okBG, okBG)
	okButton.Width:Set(60*scale)
	okButton.Height:Set(function() return okBG.Height () end)
	LayoutHelpers.AtCenterIn(okButton, okBG)
	LayoutHelpers.AtHorizontalCenterIn(okButton, okBG)
	okButton.Depth:Set(function() return okBG.Depth() + 1 end)
	
	okButton.label = UIUtil.CreateText(okButton, 'OK', 12, UIUtil.buttonFont)
    LayoutHelpers.AtCenterIn(okButton.label, okButton)
	okButton.label.Depth:Set(function() return okButton.Depth() + 1 end)
	
	-- OK button Border
	okButton.border = Bitmap(okBG)
	okButton.border:SetSolidColor('000000')
	okButton.border.Left:Set(function() return okButton.Left() -1*scale end)
	okButton.border.Top:Set(function() return okButton.Top() -1*scale end)
	okButton.border.Width:Set(function() return okButton.Width() +2*scale end)
	okButton.border.Height:Set(function() return okButton.Height() +2*scale end)
	okButton.border.Depth:Set(function() return okBG.Depth() - 1 end)
	
	okButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
	    	okButton.border:SetSolidColor(colorCode)
		elseif event.Type == 'ButtonPress' then
		    self.OnClick()
		elseif event.Type == 'MouseExit' then
		    okButton.border:SetSolidColor('000000')
		end
	end

    okButton.OnClick = function(self, modifiers)
        userInputText = nameEdit:GetText()
		local id = 'XEA0001'
		ForkThread(function()
			SendNukeData(id)
		end)
        dialog:Destroy()
        dialog = false
    end
	
	cancelButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
	    	cancelButton.border:SetSolidColor(colorCode)
		elseif event.Type == 'ButtonPress' then
		    self.OnClick()
		elseif event.Type == 'MouseExit' then
		    cancelButton.border:SetSolidColor('000000')
		end
	end
	
	cancelButton.OnClick = function(self, modifiers)
        dialog:Destroy()
        dialog = false
    end

end

function SendNukeData(ID)
	local modeData = {
		cursor = 'RULEUCC_Nuke',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'PassTextNukeStrikeData', Args = {id = ID, pos = position, text = userInputText}},true)
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end