--*****************************************************************************
--* File: lua/modules/ui/game/chat.lua
--* Author: Chris Blackwell
--* Summary: In game chat ui
--*
--* Copyright ?:005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local scale = import('/lua/user/prefs.lua').GetFromCurrentProfile("options.ui_scale") or 1
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local Window = import('/lua/maui/window.lua').Window

GUI = {
    bg = false,
}

local zoom = 15
local hpr = { -3.1415901184082, 1.58, 0 }

local ResetPositionOnce = false

function CreatAreaMonitor(MonitorPos, id)
    if id then
	    if GUI.bg then 
			GetCamera('FieldAreaMonitor'):SnapTo(MonitorPos, hpr, zoom)
		else
		    GUI.bg = CreateWindow(MonitorPos)
		end
	end
end

function CreateWindow(MonitorPos)
    local location = {Left = 350*scale, Top = 2*scale, Bottom = 252*scale, Right = 650*scale}
    local windowTextures = {
    	tl = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_ul.dds'),
		tr = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_ur.dds'),
		#tm = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_um.dds'),
		ml = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_vert_l.dds'),
		mr = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_vert_r.dds'),
		bl = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_ll.dds'),
		#bm = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_lm.dds'),
		br = UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_lr.dds'),
        borderColor = 'ffffffff',
    }
	local bg = Window(GetFrame(0), nil, nil, false, false, false, false, '', location, windowTextures)
	bg.Depth:Set(0)
	bg:SetMinimumResize(150*scale, 150*scale)

    bg.ResetPositionBtn = Button(bg,
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_up.dds'),
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_down.dds'),
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_over.dds'),
        UIUtil.SkinnableFile('/game/menu-btns/default_btn_dis.dds')
	)
	bg._closeBtn:Hide()
	LayoutHelpers.LeftOf(bg.ResetPositionBtn, bg._configBtn) 
    bg.ResetPositionBtn.Depth:Set(function() return bg.Depth() + 10 end)
    bg.ResetPositionBtn.OnClick = function(self, modifiers) 
        for index, position in location do
            local i = index
            local pos = position
            bg[i]:Set(pos)
        end
		#bg:SaveWindowLocation()
    end
	if ResetPositionOnce == false then
	    bg.ResetPositionBtn:OnClick()
		ResetPositionOnce = true
	end
	bg:SaveWindowLocation()

	local aMonitor = import('/lua/ui/controls/worldview.lua').WorldView(bg, 'FieldAreaMonitor', 2, true, 'WorldCamera')    -- depth value is above minimap
	aMonitor:SetRenderPass(UIUtil.UIRP_UnderWorld)
	LayoutHelpers.FillParent(aMonitor, bg)
    aMonitor.Depth:Set(bg.Depth()+5)
    aMonitor:SetNeedsFrameUpdate(true)
	
	#lock input no lick to move to region
	#aMonitor:LockInput()

	GetCamera('FieldAreaMonitor'):SnapTo(MonitorPos, hpr, zoom)
	
    local closeBtn = Button(bg, 
        UIUtil.UIFile('/dialogs/menu-btns/close_btn_up.dds'),
        UIUtil.UIFile('/dialogs/menu-btns/close_btn_over.dds'),
        UIUtil.UIFile('/dialogs/menu-btns/close_btn_down.dds'),
        UIUtil.UIFile('/dialogs/menu-btns/close_btn_dis.dds'),
        "UI_Opt_Yes_No", "UI_Opt_Affirm_Over")
	LayoutHelpers.AtTopIn(closeBtn, bg)
    LayoutHelpers.AtRightIn(closeBtn, bg)
	closeBtn.Width:Set(20*scale)
	closeBtn.Height:Set(20*scale)
	closeBtn.Depth:Set(aMonitor.Depth() + 1)
	
    closeBtn.OnClick = function()
	    if GUI.bg then 
		    GUI.bg:Destroy()
			GUI.bg = false
		end
    end
	
	return bg
end