local Prefs = import('/lua/user/prefs.lua')

#active default wep
local WepActive = import('/mods/Research FAF/lua/ui/DFPanel.lua').WepActiveTable

function WeaponAvailable(active)
    if active then
	    table.insert(WepActive, active)
    end
end

function ChangeWeapon(num)
    local hero = GetHero()
	for k, v in WepActive do
	    if num == v then
            SimCallback({Func = 'SelWep', Args = {weapon = num, id = hero}})
	        import('/mods/Research FAF/lua/ui/FPSHero.lua').WeapIcons(num)
		end
	end
end

function GetHero()
	UISelectionByCategory("FPSFAHERO", false, false, false, false)
	local hero = GetSelectedUnits()
	SelectUnits(hero)
	
	local idTable = {}
	if hero then
		for k, v in hero do
			local entityId = v:GetEntityId()
			table.insert(idTable, entityId)
		end
	end
	return idTable
end
