local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function ObjectACU()
	for k,v in ArmyBrains do
	    if IsEnemy( GetFocusArmy(), v:GetArmyIndex() ) then
		    local acu = v:GetListOfUnits(categories.COMMAND, false)
			if acu then
			    local index = acu[1]:GetAIBrain():GetFactionIndex()
				local myIndex = ArmyBrains[GetFocusArmy()]:GetFactionIndex()
				if myIndex != index then 
				    local acuObj = Objectives.Kill(
					    'primary',
						'incomplete',
						'Blueprint',
						'Kill enemy ACU',
						{
						    MarkUnits = true,
							FlashVisible = false,
							Units = acu
						}
					)
					
					acuObj:AddResultCallback(
					    function()
						    Sync.SetAvailableEng = index
						end
					)
				end
			end
		end
	end
end
