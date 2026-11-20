local Prefs = import('/lua/user/prefs.lua')
do
	local ResearchUI = CreateUI
	function CreateUI(isReplay)
		ResearchUI(isReplay)
		import('/mods/Research FAF/lua/ui/AbilityMenu.lua').Initial()
		--click the unit cap digi, enter unit cap to the dialog, increase unit cap
		import('/mods/Research FAF/lua/ui/ChangeUnitCap.lua').Initial()
		--import('/mods/Research FAF/lua/ui/EventTab.lua').InitEventUI()
		local FPSKeys = {
			['Ctrl-M'] = {action =  'UI_Lua import("/mods/Research FAF/lua/ui/AbilityMenu.lua").ShowMenu()'},
			['Ctrl-T'] = {action =  'UI_TrackUnit FieldAreaMonitor',  category = 'camera', order = 9},
			['Alt-I'] = {action =  'UI_Lua import("/mods/Research FAF/lua/ui/ShowUnitShieldValue.lua").GetUnitsShieldValue()'}, --show selected units shield value
		}
		IN_AddKeyMapTable(FPSKeys)
	end
end
