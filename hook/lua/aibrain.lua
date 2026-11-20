local ABSyspath = import('/mods/Research FAF/lua/AbilitySystem.lua')
local Enhpath = import('/mods/Research FAF/lua/EnhAbilityControl.lua')

local ResearchAIBrain = AIBrain
AIBrain = Class(ResearchAIBrain) {
    OnCreateHuman = function(self, planName)
    	ResearchAIBrain.OnCreateHuman(self)
		ForkThread(ABSyspath.AbilityGeneratedThread, self)
		ForkThread(ABSyspath.AbilityKillsThread, self)
		ForkThread(Enhpath.EcoStructureAddThread, self)
		ForkThread(Enhpath.BuildrateBuffThread, self)
		ForkThread(Enhpath.EcoBalanceExchange, self)
		ForkThread(Enhpath.KillReclaim, self)
		ForkThread(import('/mods/Research FAF/lua/ObjectText.lua').ObjectACU)
    end,
	
    #find out where is the acu's initial location on map
    GetRealStartLocation = function(self)
	    local posX, posZ
		if ScenarioInfo.type == 'skirmish' then
			posX, posZ = self:GetArmyStartPos()
		elseif ScenarioInfo.type == 'campaign' then
			local location = false
			repeat 
				WaitSeconds(3)
				local acu = ScenarioInfo.PlayerCDR
				if acu then
				    location = acu:GetPosition()
					posX, posZ = location[1], location[3]
				end
			until location
		end	
		return posX, posZ
    end,
} 
