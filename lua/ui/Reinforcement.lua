local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Tooltip = import('/lua/ui/game/tooltip.lua')
local cmdMode = import('/lua/ui/game/commandmode.lua')
local Prefs = import('/lua/user/prefs.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local waitTime = 300
countdownText = false
local bg = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg
local panel = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').REwindow
ReinfActive = false

local ABcount = false
local ABTitle = false
local ABDescription = false
local TimeLeft = {waitTime}

function CreateUI()
    local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    panel:SetSolidColor(bgColor)
    panel.icon = Button(panel,nil,nil,nil,nil)
	LayoutHelpers.AtCenterIn(panel.icon, panel)
	panel.icon.Height:Set(35*scale)
    panel.icon.Width:Set(35*scale)
	panel.icon.Depth:Set(GetFrame(0):GetTopmostDepth() + 2)
    countdownText = UIUtil.CreateText(panel.icon, LOC(''), 12)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	countdownText:SetColor(fontColor)
    LayoutHelpers.AtCenterIn(countdownText, panel.icon)
    LayoutHelpers.AtHorizontalCenterIn(countdownText, panel.icon)
	UEFSquare(panel.icon)
	
	local title = 'Reinforcements'
	local desc = 'Create reinforements in nick name style'
	panel.icon.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    import('/mods/Research FAF/lua/ui/MassExtratorList.lua').KillMassDialog()
		    Initial(bg, title, desc, 'Wait for '..TimeLeft[1]..' seconds')
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	ReinfActive = panel.icon
end

function UEFSquare(pl)
	ForkThread(function()
	    for i = 1, waitTime do
		    if countdownText then
			    TimeLeft[1] = waitTime - i
				countdownText:SetText(TimeLeft[1])
			end
			repeat
			    WaitSeconds(1)
			until not SessionIsPaused() and not SessionIsGameOver()
		end
		CreateButton(pl)
	end)
end

function CreateButton(pl)
    local skin = UIUtil.UIFile('/mods/Research FAF/textures/ui/common/panel/uef_ico.png')
    local reButton = Button(pl,skin,skin,skin,skin)
	LayoutHelpers.AtCenterIn(reButton, pl)
	reButton.Depth:Set(function() return pl.Depth() + 10 end)
	reButton.Height:Set(35*scale)
    reButton.Width:Set(35*scale)
	reButton.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)	
	local reText = UIUtil.CreateText(reButton, "<LOC RE_Research_02>Ready", 10)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	reText:SetColor(fontColor)
	LayoutHelpers.AtCenterIn(reText, reButton)
	LayoutHelpers.AtHorizontalCenterIn(reText, reButton)
	
	#text flashing colors to remind
	ForkThread(function()
	    while reButton do
		    reText:SetColor('Red')
			WaitSeconds(.5)
			reText:SetColor('Yellow')
			WaitSeconds(.5)
		end
	end)
	
	#voice to remind
	--[{i Fletcher}]: I\'ve got a force of land units ready to go, Commander. Give me a target, and I\'ll hit it hard.'
	local sound = Sound({Bank = 'XGG', Cue = 'XGG_Fletcher_GP1_04073'})
    PlayVoice(sound)
	
	reButton.HandleEvent = function(self, event) 
	    if event.Type == 'MouseEnter' then
		    --do nothing
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    reButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    --do nothing
		end
	end
	
	reButton.OnClick = function()
	    #gatling bots
	    local ID = {'DEL0204'}
		ForkThread(function()
			CallForReinforcementSupport(ID)
		end)
		UEFSquare(pl)
		reButton:Destroy()
		pl:SetTexture('/mods/Research FAF/textures/ui/common/panel/uef2_ico.png')
	end
end

--special thanks to CDRMV, the author of Commander Survival Kit
function CallForReinforcementSupport(ID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'PassReinforcementData', Args = {id = ID, pos = position}},true)
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

GUI = {
    ABcount = false,
}

function Initial(bg, title, desc, tips)
    if GUI.ABcount == false then
	    GUI.ABcount = CreateABDialog(bg, title, desc, tips)
    end
end

function CreateABDialog(bg, title, desc, tips)
	
    local ABcount = Bitmap(bg)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    ABcount:SetSolidColor(bgColor)
	ABcount.Width:Set(90*scale)
	ABcount.Height:Set(40*scale)
	ABcount.Left:Set(function() return bg.Right() end)
	if (GetFrame(0)).Right() - bg.Right() < 310*scale then
	    ABcount.Left:Set(function() return bg.Left() - 310*scale end)
	end
	ABcount.Top:Set(function() return panel.Top() end)
	
    ABcount.icon = Bitmap(ABcount)
    LayoutHelpers.AtCenterIn(ABcount.icon, ABcount)
    ABcount.icon:SetTexture(UIUtil.UIFile('/textures/ui/common/icons/units/DEL0204_icon.dds'))
    ABcount.icon.Height:Set(30*scale)
    ABcount.icon.Width:Set(30*scale)
	
    ABTitle = Bitmap(ABcount)
    ABTitle:SetSolidColor('cc333333')
	ABTitle.Width:Set(300*scale)
	ABTitle.Height:Set(40*scale)
	ABTitle.Left:Set(function() return ABcount.Left() end)
	ABTitle.Top:Set(function() return ABcount.Bottom() end)

    ABTitle.title= UIUtil.CreateText(ABTitle, title, 16, UIUtil.titleFont)
    LayoutHelpers.AtCenterIn(ABTitle.title, ABTitle)
	
    ABDescription = Bitmap(ABcount)
    ABDescription:SetSolidColor('99333333')
	ABDescription.Width:Set(300*scale)
	ABDescription.Height:Set(105*scale)
	ABDescription.Left:Set(function() return ABTitle.Left() end)
	ABDescription.Top:Set(function() return ABTitle.Bottom() end)
	
	local desc = UIUtil.CreateText(ABDescription, desc, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(desc, ABDescription, 10, 10)
	local tips = UIUtil.CreateText(ABDescription, tips, 12, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(tips, ABDescription, 10, 35)
	
	return ABcount
end

function KillABDialog()
    if GUI.ABcount then 
	    GUI.ABcount:Destroy()
		GUI.ABcount = false
    end
end