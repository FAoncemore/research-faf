local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Prefs = import('/lua/user/prefs.lua')
local cmdMode = import('/lua/ui/game/commandmode.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local scale = Prefs.GetFromCurrentProfile("options.ui_scale") or 1

local PortalGateInAbility = 12
local PortalGateOutAbility = 12
local TeleportAbility = 12
local UEFBlackHoleAbility = 6
local NukeAbility = 12
local MultiNukeAbility = 99
local T4NukeAbility = 36

local AbilityGenerated = 0
local AbilityCollected = 0
local AbilitySpent = 0

local gateinButton
local gateoutButton
local teleportButton
local nukeButton
local mnukeButton
local t4nukeButton
local textnukeButton
local uefButton

local nukeButtonText = false

function ResearchLabHandle(generated)
	ForkThread(function()
		AbilityGenerated = AbilityGenerated + generated
	end)
end

function CollectedAbility(Collected)
	AbilityCollected = Collected
end

function SpentAbility(Spent)
	AbilitySpent = Spent
end

function CreateButtons(leftBG, rightBG, intAbility)
	CreatePortalGateInButton(leftBG, rightBG, intAbility)
	CreatePortalGateOutButton(leftBG, rightBG, intAbility)
	CreateTeleportButton(leftBG, rightBG, intAbility)
	
	CreateUEFBlackHoleButton(rightBG, intAbility)
	CreateNukeStrikeButton(rightBG, intAbility)
	CreateMultiNukeStrikeButton(rightBG, intAbility)
	CreateT4NukeStrikeButton(rightBG, intAbility)
	CreateTextNukeStrikeButton(rightBG, intAbility)
end

function CreatePortalGateInButton(leftBG, rightBG, intAbility)

	gateinButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/orders/load_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/load_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/load_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/load_btn_sel.dds')
	)
	
	LayoutHelpers.AtCenterIn(gateinButton, leftBG)
	gateinButton.Top:Set(function() return leftBG.Top() + 5*scale end)
	gateinButton.Width:Set(48*scale)
	gateinButton.Height:Set(48*scale)
	gateinButton.Depth:Set(leftBG.Depth() + 1)
	
	local title = 'Portal In(TX)'
	local description = 'Field gate, teleports mobile units to RX in 24 range'
	local tips = 'TX guards RX then units teleport to RX'
	gateinButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(gateinButton, rightBG, PortalGateInAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    gateinButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	gateinButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < PortalGateInAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = {'portal_transmitter'}
			ForkThread(function()
			    CreateGateInThread(ID)
			end)
			AbilitySpent = AbilitySpent + PortalGateInAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreatePortalGateOutButton(leftBG, rightBG, intAbility)

	gateoutButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/orders/unload_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/unload_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/unload_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/unload_btn_sel.dds')
	)
	
	LayoutHelpers.AtCenterIn(gateoutButton, leftBG)
	gateoutButton.Top:Set(function() return leftBG.Top() + 50*scale end)
	gateoutButton.Width:Set(48*scale)
	gateoutButton.Height:Set(48*scale)
	gateoutButton.Depth:Set(leftBG.Depth() + 1)
	
	local title = 'Portal Out(RX)'
	local description = 'Field gate, receives mobile units from TX'
	local tips = 'TX guards RX then units teleport to RX'
	gateoutButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(gateoutButton, rightBG, PortalGateOutAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    gateoutButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	gateoutButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < PortalGateOutAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = {'portal_receiver'}
			ForkThread(function()
			    CreateGateOutThread(ID)
			end)
			AbilitySpent = AbilitySpent + PortalGateOutAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreateTeleportButton(leftBG, rightBG, intAbility)

	teleportButton = Button(
	    leftBG, 
	    UIUtil.UIFile('/game/orders/teleport_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/teleport_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/teleport_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/teleport_btn_sel.dds')
	)
	
	LayoutHelpers.AtCenterIn(teleportButton, leftBG)
	teleportButton.Top:Set(function() return leftBG.Top() + 100*scale end)
	teleportButton.Width:Set(48*scale)
	teleportButton.Height:Set(48*scale)
	teleportButton.Depth:Set(leftBG.Depth() + 1)
	
	local title = 'Teleport'
	local description = 'Teleport mobile units in 20 range'
	local tips = 'Click units and then click target pos'
	teleportButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(teleportButton, rightBG, TeleportAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    teleportButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	teleportButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < TeleportAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
			ForkThread(function()
			    local startID = {'portal_transmitter'}
			    CreateTeleportStartThread(startID)
			end)
			AbilitySpent = AbilitySpent + TeleportAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreateUEFBlackHoleButton(rightBG, intAbility)
    local UEFicon = UIUtil.UIFile('/faction_icon-lg/uef_ico.dds')
	uefButton = Button(rightBG, UEFicon, UEFicon, UEFicon, UEFicon)
	
	LayoutHelpers.AtCenterIn(uefButton, rightBG)
	uefButton.Top:Set(function() return rightBG.Top() + 5*scale end)
	uefButton.Width:Set(48*scale)
	uefButton.Height:Set(48*scale)
	uefButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Black Hole'
	local description = '45 tractors in the sky, destroy mobile units quickly'
	local tips = 'Better to use above a group of land units'
	uefButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(uefButton, rightBG, UEFBlackHoleAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    uefButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	uefButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < UEFBlackHoleAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = {'XEA0004'}
			ForkThread(function()
			    CallForUEFBlackHoleStrike(ID)
			end)
			AbilitySpent = AbilitySpent + UEFBlackHoleAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreateNukeStrikeButton(rightBG, intAbility)

	nukeButton = Button(
	    rightBG, 
	    UIUtil.UIFile('/game/orders/nuke_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_sel.dds')
	)
	LayoutHelpers.AtCenterIn(nukeButton, rightBG)
	nukeButton.Top:Set(function() return rightBG.Top() + 50*scale end)
	nukeButton.Width:Set(48*scale)
	nukeButton.Height:Set(48*scale)
	nukeButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Nuke Strike'
	local description = 'Call for one nuke strike at mouse pos'
	local tips = ''
	nukeButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(nukeButton, rightBG, NukeAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    nukeButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	nukeButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < NukeAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = 'XEA0001'
			local Qty = 1
			ForkThread(function()
			    CallForNukeStrike(ID, Qty)
			end)
			AbilitySpent = AbilitySpent + NukeAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreateMultiNukeStrikeButton(rightBG, intAbility)

	mnukeButton = Button(
	    rightBG, 
	    UIUtil.UIFile('/game/orders/nuke_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_sel.dds')
	)
	LayoutHelpers.AtCenterIn(mnukeButton, rightBG)
	mnukeButton.Top:Set(function() return rightBG.Top() + 100*scale end)
	mnukeButton.Width:Set(48*scale)
	mnukeButton.Height:Set(48*scale)
	mnukeButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = '9 Nukes Strike'
	local description = 'Call for 9 nukes strike at mouse pos'
	local tips = ''
	mnukeButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(mnukeButton, rightBG, MultiNukeAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    mnukeButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	mnukeButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < MultiNukeAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = 'XEA0001'
			local Qty = 9
			ForkThread(function()
			    CallForNukeStrike(ID, Qty)
			end)
			AbilitySpent = AbilitySpent + MultiNukeAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreateT4NukeStrikeButton(rightBG, intAbility)
    local nukeIcon = UIUtil.UIFile('/icons/units/xsb2401_icon.dds')
	t4nukeButton = Button(rightBG,nukeIcon,nukeIcon,nukeIcon,nukeIcon)
	
	LayoutHelpers.AtCenterIn(t4nukeButton, rightBG)
	t4nukeButton.Top:Set(function() return rightBG.Top() + 150*scale end)
	t4nukeButton.Width:Set(48*scale)
	t4nukeButton.Height:Set(48*scale)
	t4nukeButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'T4 Nuke Strike'
	local description = 'Call for T4 nuke strike at mouse pos'
	local tips = ''
	t4nukeButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(t4nukeButton, rightBG, T4NukeAbility, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    t4nukeButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	t4nukeButton.OnClick = function()
		local currentAbilities = import('/mods/Research FAF/lua/ui/AbilityMenu.lua').AbilityStorage
		if currentAbilities < T4NukeAbility then
			import('/mods/Research FAF/lua/ui/AbilityMenu.lua').InsufficientAB()
		else
		    local ID = 'XEA0003'
			local Qty = 1
			ForkThread(function()
			    CallForNukeStrike(ID, Qty)
			end)
			AbilitySpent = AbilitySpent + T4NukeAbility
			NotifyAllPanels(AbilitySpent)
			local leftAbilities = AbilityCollected + intAbility - AbilitySpent
			currentAbilities = leftAbilities
		end
	end
	
end

function CreateTextNukeStrikeButton(rightBG, intAbility)
	textnukeButton = Button(
	    rightBG, 
	    UIUtil.UIFile('/game/orders/nuke_btn_up.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_down.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_over.dds'), 
		UIUtil.UIFile('/game/orders/nuke_btn_sel.dds')
	)
	LayoutHelpers.AtCenterIn(textnukeButton, rightBG)
	textnukeButton.Top:Set(function() return rightBG.Top() + 200*scale end)
	textnukeButton.Width:Set(48*scale)
	textnukeButton.Height:Set(48*scale)
	textnukeButton.Depth:Set(rightBG.Depth() + 1)
	
	local title = 'Text Nuke'
	local description = 'Nuke in customized text formation'
	local tips = ''
	textnukeButton.HandleEvent = function(self, event)
	    if event.Type == 'MouseEnter' then
		    CreateABDialog(textnukeButton, rightBG, 0, title, description, tips)
			PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Opt_Mini_Button_Over'}))
		elseif event.Type == 'ButtonPress' then
		    textnukeButton.OnClick()
		elseif event.Type == 'MouseExit' then
		    KillABDialog()
		end
	end
	
	textnukeButton.OnClick = function()
		import('/mods/Research FAF/lua/ui/InputText.lua').CreateTextDialog()
	end
end

function NotifyAllPanels(spent) 
	import('/mods/Research FAF/lua/ui/AbilityMenu.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/EnhPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/IntelPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/FieldPanel.lua').SpentAbility(spent)
	import('/mods/Research FAF/lua/ui/DFPanel.lua').SpentAbility(spent)
end

--special thanks to CDRMV, the author of Commander Survival Kit
function CreateGateInThread(ID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'PassGateInData', Args = {id = ID, pos = position}},true)
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CreateGateOutThread(ID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'PassGateOutData', Args = {id = ID, pos = position}},true)
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CreateTeleportStartThread(startID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			endThread = ForkThread(function()
			    local endID = {'portal_receiver'}
				CreateTeleportEndThread(position, endID)
			end)
            startID = nil			
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CreateTeleportEndThread(posStart, endID)
	local modeData = {
		cursor = 'RULEUCC_Teleport',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local posEnd = GetMouseWorldPos()
			SimCallback({Func = 'PassUnitstoTeleportData', Args = {startPos = posStart, endPos = posEnd, id = endID}},true)
			KillThread(endThread)
			endThread = nil
			endID = nil	
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CallForUEFBlackHoleStrike(ID)
	local modeData = {
		cursor = 'MESSAGE',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'PassUEFBlackHoleStrikeData', Args = {id = ID, pos = position}},true)
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CallForNukeStrike(ID, qty)
	local modeData = {
		cursor = 'RULEUCC_Nuke',
		pingType = 'marker',
	}
	cmdMode.StartCommandMode("ping", modeData)
	function EndBehavior(mode, data)
		if mode == 'ping' and not data.isCancel then
			local position = GetMouseWorldPos()
			SimCallback({Func = 'PassNukeStrikeData', Args = {id = ID, pos = position, num = qty}},true)
			ID = nil
		end
	end
	cmdMode.AddEndBehavior(EndBehavior)
end

function CreateABDialog(curBtn, bg, AB, title, description, tips)
    import('/mods/Research FAF/lua/ui/TipsDialogs.lua').Initial(curBtn, bg, AB, title, description, tips)
end

function KillABDialog()
    import('/mods/Research FAF/lua/ui/TipsDialogs.lua').KillABDialog()
end