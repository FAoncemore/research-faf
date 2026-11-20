local UIUtil = import('/lua/ui/uiutil.lua')

function GetUnitsShieldValue()
	ForkThread(function()
	    local unit = GetSelectedUnits() or {}
		local unitID = unit[1]:GetEntityId()
		SimCallback({Func = 'ShowUnitShield', Args = unitID})
		--ShowShield(unitID)
	end)
end

function ShowShield(value)
    UIUtil.QuickDialog(GetFrame(0), 'Shield HP: '..value, '<LOC _Ok>', nil, 
	    nil,  nil,
		nil, nil,
		true, {worldCover = false, enterButton = 1, escapeButton = 1}
	)
end