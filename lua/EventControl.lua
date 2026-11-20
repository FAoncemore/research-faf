local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local ObjectiveArrow = import('/lua/objectiveArrow.lua').ObjectiveArrow

-- common helpers
local function IsEnemyUnit(unit)
    return IsEnemy(ArmyBrains[GetFocusArmy()]:GetArmyIndex(), unit:GetArmy())
end

local function CreateArrowAndSync(unit, syncKey, text)
    if unit.arrow then return end
    unit.arrow = ObjectiveArrow { Size = 0.3, AttachTo = unit }

    Sync[syncKey] = {
        unit:GetPosition(),
        unit:GetBlueprint().BlueprintId,
        unit:GetArmy(),
        text
    }
    CreateVizAtUnit(unit)
end

-- unit detected
local unitTypes = {
    {category = categories.EXPERIMENTAL, syncKey = 'ExpDetectedEvent', text = 'Detected'},
    {category = categories.NUKE * categories.STRUCTURE, syncKey = 'NukeDetectedEvent', text = 'Detected'},
    {category = categories.ARTILLERY * categories.STRUCTURE * categories.TECH3, syncKey = 'ArtDetectedEvent', text = 'Detected'}
}

UnitDetected = function(unit)
    ForkThread(function()
        for _, unitType in ipairs(unitTypes) do
            if EntityCategoryContains(unitType.category, unit) and IsEnemyUnit(unit) then
			--if IsEnemyUnit(unit) then -- testing purpose
                CreateArrowAndSync(unit, unitType.syncKey, unitType.text)
            end
        end
    end)
end


-- unit destroyed
UnitDestroy = function(unit)
    if not IsEnemyUnit(unit) then return end

    local map = {
        [categories.EXPERIMENTAL] = 'EXPDestroy',
        [categories.NUKE * categories.STRUCTURE] = 'NukeDestroy',
        [categories.ARTILLERY * categories.STRUCTURE * (categories.TECH3 + categories.EXPERIMENTAL)] = 'ArtilleryDestroy'
    }

    for cat, syncKey in map do
        if EntityCategoryContains(cat, unit) then
            Sync[syncKey] = {
                unit:GetPosition(),
                unit:GetBlueprint().BlueprintId,
                unit:GetArmy(),
                'Destroyed'
            }
            CreateVizAtUnit(unit)
        end
    end
end

-- vision marker
CreateVizAtUnit = function(unit)
    local p = unit:GetPosition()
    VizMarker {
        X = p[1], Z = p[3],
        Radius = 20, LifeTime = 20,
        Omni = false, Radar = false, Vision = true,
        Army = GetFocusArmy(),
    }
end
