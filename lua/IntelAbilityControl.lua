local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ObjectiveArrow = import('/lua/objectiveArrow.lua').ObjectiveArrow
local TauntManager = import('/lua/TauntManager.lua')

#base drones
BaseHelperToggle = function()
    ForkThread(function() 
	    CreateBaseHelper()
	end)
end
	
#base drones
CreateBaseHelper = function()
    local aiBrain = ArmyBrains[GetFocusArmy()]
	local posX, posZ = aiBrain:GetRealStartLocation()
	aiBrain:CreateUnitNearSpot('URA0008', posX, posZ)
	SetIgnoreArmyUnitCap(GetFocusArmy(), true)
	local num = 0
	while num < 4 do
	    WaitSeconds(1)
		aiBrain:CreateUnitNearSpot('BASEHELPER', posX + num, posZ)
		num = num + 1
	end
	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
end
	
#map size vision entity, if remove fog of war, and then create a map size viz, and turn on fog of war, the viz will be also delected.
CreateMapSizeViz = function(data)
    local mapSizeX, mapSizeZ = GetMapSize()
	ForkThread(function() 
	    VizCountDownThread(data)
	end)
	local spec = {
	    X = mapSizeX/2,
		Z = mapSizeZ/2,
		#visible area size is equal to map size
		Radius = math.sqrt(math.pow(mapSizeX, 2) + math.pow(mapSizeZ, 2))/2,
		LifeTime = (data),
		Omni = true,
		Radar = false,
		Vision = true,
		Army = GetFocusArmy(),
	}
	Satellite = import('/lua/sim/VizMarker.lua').VizMarker(spec)
	Satellite:EnableIntel('Vision')
	Satellite:EnableIntel('Omni')
	#take energy will keep omni, radar on
	Satellite:SetEnergyMaintenanceConsumptionOverride(10)
	Satellite:SetConsumptionActive(true)
end
	
#viz count down
VizCountDownThread = function(data)
    for i = data, 0, -1 do
	    Sync.NotifyVizOff = i
		WaitSeconds(1)
	end
end

#check enemy nuke total qty
AnalyzeEnemyNukes = function()
    local aiBrain = ArmyBrains[GetFocusArmy()]
	local startX, startZ = aiBrain:GetArmyStartPos()
	local pos = {startX, 0, startZ}
	local range = math.floor(math.max(GetMapSize())*math.sqrt(2))
	local enemyNukes = aiBrain:GetUnitsAroundPoint(categories.NUKE * categories.STRUCTURE, pos, range, 'Enemy')
	local detectedNukes = {}
	local num = 0
	if enemyNukes and table.getn(enemyNukes) > 0 then
	    for k, v in enemyNukes do
		    local blip = v:GetBlip(aiBrain:GetArmyIndex())
			if blip then
			    table.insert(detectedNukes, v)
				local army = ArmyBrains[GetFocusArmy()]:GetArmyIndex()
				local Entity = import('/lua/sim/Entity.lua').Entity
				local curpos = v:GetPosition()
				local curpingSpec = {Owner = army, Location = curpos}
				local curping = Entity(curpingSpec)
				Warp(curping, Vector(curpos[1], curpos[2], curpos[3]))
				#this seems weird, the ping seems belong to the enemy but not the human brain
				curping:SetVizToFocusPlayer('Always')
				curping:SetVizToEnemies('Always')
				curping:SetVizToAllies('Always')
				curping:SetVizToNeutrals('Always')
				curping:SetMesh('/meshes/game/ping_attack_marker')
				local curpingThread = ForkThread(NukePingMesh, curping)
				ForkThread(function() 
				    WaitSeconds(10)
					KillThread(curpingThread)
					curping:Destroy()
				end)
			end
		end
	    num = table.getn(detectedNukes)
	end

	Sync.EnemyNukesQty = num
end

#curping animating
NukePingMesh = function(entity)
    local time = 0
    local ascending = true
    while entity do
        local orien = entity:GetOrientation()
        entity:SetScale(MATH_Lerp(math.sin(time), -.5, 0.5, .3, .5))
        time = time + .3
        WaitSeconds(.001)
    end
end

#check enemy game ender qty
AnalyzeEnemyGameEnders = function()
    local aiBrain = ArmyBrains[GetFocusArmy()]
	local startX, startZ = aiBrain:GetArmyStartPos()
	local pos = {startX, 0, startZ}
	local range = math.floor(math.max(GetMapSize())*math.sqrt(2))
	
	ForkThread(function()
	    local mavor = aiBrain:GetUnitsAroundPoint(categories.ueb2401, pos, range, 'Enemy')
		local detectedMavor = {}
		local mavorNum = 0
		if mavor and table.getn(mavor) > 0 then
		    for k, v in mavor do
			    local blip = v:GetBlip(aiBrain:GetArmyIndex())
				if blip then
				    table.insert(detectedMavor, v)
					local army = ArmyBrains[GetFocusArmy()]:GetArmyIndex()
					local Entity = import('/lua/sim/Entity.lua').Entity
					local curpos = v:GetPosition()
					local curpingSpec = {Owner = army, Location = curpos}
					local curping = Entity(curpingSpec)
					Warp(curping, Vector(curpos[1], curpos[2], curpos[3]))
					#this seems weird, the ping seems belong to the enemy but not the human brain
					curping:SetVizToFocusPlayer('Always')
					curping:SetVizToEnemies('Always')
					curping:SetVizToAllies('Always')
					curping:SetVizToNeutrals('Always')
					curping:SetMesh('/meshes/game/ping_attack_marker')
					local curpingThread = ForkThread(NukePingMesh, curping)
					ForkThread(function() 
					    WaitSeconds(10)
						KillThread(curpingThread)
						curping:Destroy()
					end)
					Sync.MavorPos = v:GetPosition()
				end
			end
			mavorNum = table.getn(detectedMavor)
		end
		Sync.EnemyMavorQty = mavorNum
	end)
	
	ForkThread(function()
	    local paragon = aiBrain:GetUnitsAroundPoint(categories.xab1401, pos, range, 'Enemy')
		local detectedParagon = {}
		local paragonNum = 0
		if paragon and table.getn(paragon) > 0 then
		    for k, v in paragon do
			    local blip = v:GetBlip(aiBrain:GetArmyIndex())
				if blip then
				    table.insert(detectedParagon, v)
					local army = ArmyBrains[GetFocusArmy()]:GetArmyIndex()
					local Entity = import('/lua/sim/Entity.lua').Entity
					local curpos = v:GetPosition()
					local curpingSpec = {Owner = army, Location = curpos}
					local curping = Entity(curpingSpec)
					Warp(curping, Vector(curpos[1], curpos[2], curpos[3]))
					#this seems weird, the ping seems belong to the enemy but not the human brain
					curping:SetVizToFocusPlayer('Always')
					curping:SetVizToEnemies('Always')
					curping:SetVizToAllies('Always')
					curping:SetVizToNeutrals('Always')
					curping:SetMesh('/meshes/game/ping_attack_marker')
					local curpingThread = ForkThread(NukePingMesh, curping)
					ForkThread(function() 
					    WaitSeconds(10)
						KillThread(curpingThread)
						curping:Destroy()
					end)
					Sync.ParagonPos = v:GetPosition()
				end
			end
			paragonNum = table.getn(detectedParagon)
		end
		Sync.EnemyParagonQty = paragonNum
	end)
	
	ForkThread(function()
	    local salvation = aiBrain:GetUnitsAroundPoint(categories.xab2307, pos, range, 'Enemy')
		local detectedSalvation = {}
		local salvationNum = 0
		if salvation and table.getn(salvation) > 0 then
		    for k, v in salvation do
			    local blip = v:GetBlip(aiBrain:GetArmyIndex())
				if blip then
				    table.insert(detectedSalvation, v)
					local army = ArmyBrains[GetFocusArmy()]:GetArmyIndex()
					local Entity = import('/lua/sim/Entity.lua').Entity
					local curpos = v:GetPosition()
					local curpingSpec = {Owner = army, Location = curpos}
					local curping = Entity(curpingSpec)
					Warp(curping, Vector(curpos[1], curpos[2], curpos[3]))
					#this seems weird, the ping seems belong to the enemy but not the human brain
					curping:SetVizToFocusPlayer('Always')
					curping:SetVizToEnemies('Always')
					curping:SetVizToAllies('Always')
					curping:SetVizToNeutrals('Always')
					curping:SetMesh('/meshes/game/ping_attack_marker')
					local curpingThread = ForkThread(NukePingMesh, curping)
					ForkThread(function() 
					    WaitSeconds(10)
						KillThread(curpingThread)
						curping:Destroy()
					end)
					Sync.SalvationPos = v:GetPosition()
				end
			end
			salvationNum = table.getn(detectedSalvation)
		end
		Sync.EnemySalvationQty = salvationNum
	end)
	
	ForkThread(function()
	    local scathis = aiBrain:GetUnitsAroundPoint(categories.url0401, pos, range, 'Enemy')
		local detectedScathis = {}
		local scathisNum = 0
		if scathis and table.getn(scathis) > 0 then
		    for k, v in scathis do
			    local blip = v:GetBlip(aiBrain:GetArmyIndex())
				if blip then
				    table.insert(detectedScathis, v)
					local army = ArmyBrains[GetFocusArmy()]:GetArmyIndex()
					local Entity = import('/lua/sim/Entity.lua').Entity
					local curpos = v:GetPosition()
					local curpingSpec = {Owner = army, Location = curpos}
					local curping = Entity(curpingSpec)
					Warp(curping, Vector(curpos[1], curpos[2], curpos[3]))
					#this seems weird, the ping seems belong to the enemy but not the human brain
					curping:SetVizToFocusPlayer('Always')
					curping:SetVizToEnemies('Always')
					curping:SetVizToAllies('Always')
					curping:SetVizToNeutrals('Always')
					curping:SetMesh('/meshes/game/ping_attack_marker')
					local curpingThread = ForkThread(NukePingMesh, curping)
					ForkThread(function() 
					    WaitSeconds(10)
						KillThread(curpingThread)
						curping:Destroy()
					end)
					Sync.ScathisPos = v:GetPosition()
				end
			end
			scathisNum = table.getn(detectedScathis)
		end
		Sync.EnemyScathisQty = scathisNum
	end)
	
	ForkThread(function()
	    local yolonaoss = aiBrain:GetUnitsAroundPoint(categories.xsb2401, pos, range, 'Enemy')
		local detectedYO = {}
		local YONum = 0
		if yolonaoss and table.getn(yolonaoss) > 0 then
		    for k, v in yolonaoss do
			    local blip = v:GetBlip(aiBrain:GetArmyIndex())
				if blip then
				    table.insert(detectedYO, v)
					local army = ArmyBrains[GetFocusArmy()]:GetArmyIndex()
					local Entity = import('/lua/sim/Entity.lua').Entity
					local curpos = v:GetPosition()
					local curpingSpec = {Owner = army, Location = curpos}
					local curping = Entity(curpingSpec)
					Warp(curping, Vector(curpos[1], curpos[2], curpos[3]))
					#this seems weird, the ping seems belong to the enemy but not the human brain
					curping:SetVizToFocusPlayer('Always')
					curping:SetVizToEnemies('Always')
					curping:SetVizToAllies('Always')
					curping:SetVizToNeutrals('Always')
					curping:SetMesh('/meshes/game/ping_attack_marker')
					local curpingThread = ForkThread(NukePingMesh, curping)
					ForkThread(function() 
					    WaitSeconds(10)
						KillThread(curpingThread)
						curping:Destroy()
					end)
					Sync.YolonaossPos = v:GetPosition()
				end
			end
			YONum = table.getn(detectedYO)
		end
		Sync.EnemyYOQty = YONum
	end)
	
end

#random move for selected units
RandomMove = function(data)
    for _, unitId in data.units do
	    local unit = GetEntityById(unitId)
		local maxRange = 5
		IssueClearCommands({unit})
		local x,y,z = unpack(unit:GetPosition())
		for i = 1, 100 do
		    IssueMove({unit}, {x + Random(-maxRange, maxRange), y, z + Random(-maxRange, maxRange)})
		end
    end
end

local CategoryWatch = categories.EXPERIMENTAL
local catWatch = {
    ['1'] = categories.EXPERIMENTAL,
	['2'] = categories.NUKE,
	['3'] = categories.COMMAND,
	['4'] = categories.SUBCOMMANDER,
}

local dist = 25
function SetDecalSize(size)
    dist = size
end

local watchThread = false
local decal = false
local watchToggle = true
function AreaWatchToggle(data)
    if data == 'On' then 
	    watchToggle = true
	elseif data == 'Off' then
	    watchToggle = false
		if watchThread then KillThread(watchThread) end
		if decal then decal:Destroy() end
	end
end

function CreateDetectAreas(data)
    if data.key and watchToggle == true then
	    CategoryWatch = catWatch[data.key] or categories.EXPERIMENTAL -- default
		local x = data.pos[1] - dist
		local x1 = data.pos[1] + dist
		local z = data.pos[3] - dist
		local z1 = data.pos[3] + dist
		
		Scenario.Areas['UnitsInArea'] = {
		    ['rectangle'] = RECTANGLE( x, z, x1, z1 ),
		}
		
		local rect = ScenarioUtils.AreaToRect( 'UnitsInArea' )
		local w = rect.x1 - rect.x0
		local h = rect.y1 - rect.y0
		local x = rect.x0 + ( w / 2.0 )
		local z = rect.y0 + ( h / 2.0 )
		
		if decal then decal:Destroy() end
		if watchThread then KillThread(watchThread) end
		
		decal = CreateObjectiveDecal(x, z, w, h)

		local army = ArmyBrains[GetFocusArmy()]:GetArmyIndex()
		watchThread = ForkThread(function()
		    while true do
			    local units = GetUnitsInRect(rect)
				if units then
				    for k,unit in units do
					    --if not unit:IsDead() and not unit:IsBeingBuilt() then
						    if IsEnemy(army, unit:GetArmy()) then
							    if EntityCategoryContains(CategoryWatch, unit) then
								    if not unit.Marked then
									    unit.Marked = true
										ObjectiveArrow { Size = 0.3, AttachTo = unit }
										local bpID = unit:GetBlueprint().BlueprintId
										local pos = unit:GetPosition()
										Sync.AreaDetect = {bpID, pos}
									end
								end
							end
						--end
					end
				end
				WaitTicks(10)
			end
		end)
	end
end

local decalTime = 10
function SetDecalLifeTime(sec)
    decalTime = sec
end

function CreateObjectiveDecal(x, z, w, h)
    local objectiveDecal = '/env/utility/decals/objective_debug_albedo.dds'
	local DecalLOD = 4000
	local army = GetFocusArmy()
    return CreateDecal(Vector(x,0,z), 0, objectiveDecal, '', 'Water Albedo', w, h, DecalLOD, decalTime, army, 0)
end