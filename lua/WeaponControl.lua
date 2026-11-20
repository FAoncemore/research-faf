-- enable weapon by menu click
SelectWeapon = function(data)
    for _, id in data.id do
        local unit = GetEntityById(id)
        if unit then
            for i = 1, 7 do
                unit:SetWeaponEnabledByLabel(
                    'Wep' .. i,
                    i == data.weapon
                )
            end
        end
    end
end
