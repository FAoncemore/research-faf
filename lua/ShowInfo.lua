-- get selected shield Value
GetUnitShieldValue = function(data)
	local unit = GetEntityById(data)
	if not unit.MyShield then return end
	local shield = unit.MyShield:GetHealth() or 0
	Sync.UnitShieldValue = math.floor(shield)
end

