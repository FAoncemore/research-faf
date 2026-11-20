local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local scale = import('/lua/user/prefs.lua').GetFromCurrentProfile("options.ui_scale") or 1

local parentBG = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').GUI.bg

local MavorPosition = {}
function MavorAlertPos(pos)
	MavorPosition = pos
end 

local ParagonPosition = {}
function ParagonAlertPos(pos)
	ParagonPosition = pos
end 

local SalvationPosition = {}
function SalvationAlertPos(pos)
	SalvationPosition = pos
end 

local ScathisPosition = {}
function ScathisAlertPos(pos)
	ScathisPosition = pos
end 

local YolonaossPosition = {}
function YolonaossAlertPos(pos)
	YolonaossPosition = pos
end 

GUI = {
    ABTitle = false,
}

function Initial(curBtn, bg, title, mavorCount, paragonCount, salvationCount, scathisCount, yolonaassCount)
    if GUI.ABTitle == false then
	    GUI.ABTitle = CreateABDialog(curBtn, bg, title, mavorCount, paragonCount, salvationCount, scathisCount, yolonaassCount)
    end
end

function CreateABDialog(curBtn, bg, title, mavorCount, paragonCount, salvationCount, scathisCount, yolonaassCount)

    local ABTitle = Bitmap(parentBG)
	local bgColor = import('/mods/Research FAF/lua/ui/InitialData.lua').bgColor
    ABTitle:SetSolidColor(bgColor)
	ABTitle.Width:Set(350*scale)
	ABTitle.Height:Set(40*scale)
	ABTitle.Left:Set(function() return parentBG.Right() end)
	if (GetFrame(0)).Right() - parentBG.Right() < 350*scale then
	    ABTitle.Left:Set(function() return parentBG.Left() - 350*scale end)
	end
	ABTitle.Top:Set(function() return curBtn.Top() end)

    ABTitle.text= UIUtil.CreateText(ABTitle, title, 16, UIUtil.titleFont)
	local fontColor = import('/mods/Research FAF/lua/ui/InitialData.lua').fontColor
	ABTitle.text:SetColor(fontColor)
    LayoutHelpers.AtCenterIn(ABTitle.text, ABTitle)
	
    ABDescription = Bitmap(ABTitle)
    ABDescription:SetSolidColor('99333333')
	ABDescription.Width:Set(350*scale)
	ABDescription.Height:Set(135*scale)
	ABDescription.Left:Set(function() return ABTitle.Left() end)
	ABDescription.Top:Set(function() return ABTitle.Bottom() end)

	local mavor = Bitmap(ABDescription)
    LayoutHelpers.AtLeftTopIn(mavor, ABDescription, 35, 10)
    mavor:SetTexture(UIUtil.UIFile('/icons/units/UEB2401_icon.dds'))
	mavor.Width:Set(48*scale)
	mavor.Height:Set(48*scale)
	local mCount = UIUtil.CreateText(mavor, "", 16, UIUtil.bodyFont)
	LayoutHelpers.Below(mCount, mavor, 2)
	LayoutHelpers.AtHorizontalCenterIn(mCount, mavor)
	mavor.HandleEvent = function(self, event)
	    if event.Type == 'ButtonPress' then
		    local rect = Rect(MavorPosition[1] - 20, MavorPosition[3] - 20, MavorPosition[1] + 20, MavorPosition[3] + 20)
			GetCamera("WorldCamera"):MoveToRegion( rect, 1.0 )
		end
	end
	
    local paragon = Bitmap(ABDescription)
    LayoutHelpers.RightOf(paragon, mavor, 10)
    paragon:SetTexture(UIUtil.UIFile('/icons/units/XAB1401_icon.dds'))
	paragon.Width:Set(48*scale)
	paragon.Height:Set(48*scale)
	local pCount = UIUtil.CreateText(paragon, "", 16, UIUtil.bodyFont)
	LayoutHelpers.Below(pCount, paragon, 2)
	LayoutHelpers.AtHorizontalCenterIn(pCount, paragon)
	paragon.HandleEvent = function(self, event)
	    if event.Type == 'ButtonPress' then
		    local rect = Rect(ParagonPosition[1] - 20, ParagonPosition[3] - 20, ParagonPosition[1] + 20, ParagonPosition[3] + 20)
			GetCamera("WorldCamera"):MoveToRegion( rect, 1.0 )
		end
	end
	
    local salvation = Bitmap(ABDescription)
    LayoutHelpers.RightOf(salvation, paragon, 10)
    salvation:SetTexture(UIUtil.UIFile('/icons/units/XAB2307_icon.dds'))
	salvation.Width:Set(48*scale)
	salvation.Height:Set(48*scale)
	local sCount = UIUtil.CreateText(salvation, "", 16, UIUtil.bodyFont)
	LayoutHelpers.Below(sCount, salvation, 2)
	LayoutHelpers.AtHorizontalCenterIn(sCount, salvation)
	salvation.HandleEvent = function(self, event)
	    if event.Type == 'ButtonPress' then
		    local rect = Rect(SalvationPosition[1] - 20, SalvationPosition[3] - 20, SalvationPosition[1] + 20, SalvationPosition[3] + 20)
			GetCamera("WorldCamera"):MoveToRegion( rect, 1.0 )
		end
	end
	
	
    local scathis = Bitmap(ABDescription)
    LayoutHelpers.RightOf(scathis, salvation, 10)
    scathis:SetTexture(UIUtil.UIFile('/icons/units/URL0401_icon.dds'))
	scathis.Width:Set(48*scale)
	scathis.Height:Set(48*scale)
	local scCount = UIUtil.CreateText(scathis, "", 16, UIUtil.bodyFont)
	LayoutHelpers.Below(scCount, scathis, 2)
	LayoutHelpers.AtHorizontalCenterIn(scCount, scathis)
	scathis.HandleEvent = function(self, event)
	    if event.Type == 'ButtonPress' then
		    local rect = Rect(ScathisPosition[1] - 20, ScathisPosition[3] - 20, ScathisPosition[1] + 20, ScathisPosition[3] + 20)
			GetCamera("WorldCamera"):MoveToRegion( rect, 1.0 )
		end
	end
	
    local yolonaass = Bitmap(ABDescription)
    LayoutHelpers.RightOf(yolonaass, scathis, 10)
    yolonaass:SetTexture(UIUtil.UIFile('/icons/units/XSB2401_icon.dds'))
	yolonaass.Width:Set(48*scale)
	yolonaass.Height:Set(48*scale)
	local yCount = UIUtil.CreateText(yolonaass, "", 16, UIUtil.bodyFont)
	LayoutHelpers.Below(yCount, yolonaass, 2)
	LayoutHelpers.AtHorizontalCenterIn(yCount, yolonaass)
	yolonaass.HandleEvent = function(self, event)
	    if event.Type == 'ButtonPress' then
		    local rect = Rect(YolonaossPosition[1] - 20, YolonaossPosition[3] - 20, YolonaossPosition[1] + 20, YolonaossPosition[3] + 20)
			GetCamera("WorldCamera"):MoveToRegion( rect, 1.0 )
		end
	end
	
	#update results
	ForkThread(function()
		WaitSeconds(1)
		ABTitle.text:SetText("Game Ender Detected")
		local mavorCount = import('/mods/Research FAF/lua/ui/IntelPanel.lua').mavorCounts
		mCount:SetText(mavorCount)
		local paragonCounts = import('/mods/Research FAF/lua/ui/IntelPanel.lua').paragonCounts
		pCount:SetText(paragonCounts)
		local salvationCounts = import('/mods/Research FAF/lua/ui/IntelPanel.lua').salvationCounts
		sCount:SetText(salvationCounts)
		local scathisCounts = import('/mods/Research FAF/lua/ui/IntelPanel.lua').scathisCounts
		scCount:SetText(scathisCounts)
		local yoCounts = import('/mods/Research FAF/lua/ui/IntelPanel.lua').yoCounts
		yCount:SetText(yoCounts)
	end)
	
    local closeBtn = Button(ABDescription, 
        UIUtil.UIFile('/dialogs/close_btn/close_btn_up.dds'),
        UIUtil.UIFile('/dialogs/close_btn/close_btn_over.dds'),
        UIUtil.UIFile('/dialogs/close_btn/close_btn_down.dds'),
        UIUtil.UIFile('/dialogs/close_btn/close_btn_dis.dds'),
        "UI_Opt_Yes_No", "UI_Opt_Affirm_Over")
	LayoutHelpers.AtBottomIn(closeBtn, ABDescription)
    LayoutHelpers.AtRightIn(closeBtn, ABDescription)
	closeBtn.Width:Set(24*scale)
	closeBtn.Height:Set(24*scale)
	closeBtn.Depth:Set(GetFrame(0):GetTopmostDepth() + 3)
	
    closeBtn.OnClick = function()
        KillABDialog()
    end
	
	return ABTitle
end


function KillABDialog()
    if GUI.ABTitle then 
	    GUI.ABTitle:Destroy()
		GUI.ABTitle = false
    end
end
