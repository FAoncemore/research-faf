-- Abilities from research labs
AbilityGeneratedThread = function(brain)
    local ratio = 150
    local count = 0

    while true do
        local labs = brain:GetListOfUnits(categories.RESEARCHLAB, true)
        local numLabs = table.getn(labs)
        if numLabs > 0 then
            count = count + numLabs / ratio

            if count >= 1 then
                Sync.ResearchLabsCount = math.floor(count)
                count = count - math.floor(count)
            end

            Sync.ResearchLabsRatio = count
        end
        WaitSeconds(1)
    end
end

-- Abilities counts from kills
AbilityKillsThread = function(brain)
    local threshold = 10000
    local oldKills = brain:GetArmyStat("Enemies_MassValue_Destroyed", 0.0).Value

    while true do
        local newKills = brain:GetArmyStat("Enemies_MassValue_Destroyed", 0.0).Value
        local progress = (newKills - oldKills) / threshold
        local collected = newKills / threshold

        if newKills - oldKills >= threshold then
            oldKills = newKills
        end

        Sync.ResearchUpdatedAbilityCount = math.floor(collected)
        Sync.ResearchUpdatedKillsProgress = progress

        WaitSeconds(1)
    end
end

