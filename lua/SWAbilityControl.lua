--letter A-Z
local LETTERS = {
    -- A-Z
    ['A'] = {
        {0,0,1,0,0},
        {0,1,0,1,0},
        {1,1,1,1,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
    },
    ['B'] = {
        {1,1,1,1,0},
        {1,0,0,0,1},
        {1,1,1,1,0},
        {1,0,0,0,1},
        {1,1,1,1,0},
    },
    ['C'] = {
        {0,1,1,1,0},
        {1,0,0,0,0},
        {1,0,0,0,0},
        {1,0,0,0,0},
        {0,1,1,1,0},
    },
    ['D'] = {
        {1,1,1,1,0},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,1,1,1,0},
    },
    ['E'] = {
        {1,1,1,1,1},
        {1,0,0,0,0},
        {1,1,1,1,0},
        {1,0,0,0,0},
        {1,1,1,1,1},
    },
    ['F'] = {
        {1,1,1,1,1},
        {1,0,0,0,0},
        {1,1,1,1,0},
        {1,0,0,0,0},
        {1,0,0,0,0},
    },
    ['G'] = {
        {0,1,1,1,0},
        {1,0,0,0,0},
        {1,1,1,1,0},
        {1,0,0,0,1},
        {0,1,1,1,0},
    },
    ['H'] = {
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,1,1,1,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
    },
    ['I'] = {
        {0,1,1,1,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {0,1,1,1,0},
    },
    ['J'] = {
        {1,1,1,1,1},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {1,0,1,0,0},
        {0,1,1,0,0},
    },
    ['K'] = {
        {1,0,0,0,1},
        {1,0,0,1,0},
        {1,0,1,0,0},
        {1,0,0,1,0},
        {1,0,0,0,1},
    },
    ['L'] = {
        {1,0,0,0,0},
        {1,0,0,0,0},
        {1,0,0,0,0},
        {1,0,0,0,0},
        {1,1,1,1,1},
    },
    ['M'] = {
        {1,0,0,0,1},
        {1,1,0,1,1},
        {1,0,1,0,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
    },
    ['N'] = {
        {1,0,0,0,1},
        {1,1,0,0,1},
        {1,0,1,0,1},
        {1,0,0,1,1},
        {1,0,0,0,1},
    },
    ['O'] = {
        {0,1,1,1,0},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {0,1,1,1,0},
    },
    ['P'] = {
        {1,1,1,1,0},
        {1,0,0,0,1},
        {1,1,1,1,0},
        {1,0,0,0,0},
        {1,0,0,0,0},
    },
    ['Q'] = {
        {0,1,1,1,0},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,1,0,1},
        {0,1,1,1,1},
    },
    ['R'] = {
        {1,1,1,1,0},
        {1,0,0,0,1},
        {1,1,1,1,0},
        {1,0,0,1,0},
        {1,0,0,0,1},
    },
    ['S'] = {
        {0,1,1,1,0},
        {1,0,0,0,0},
        {0,1,1,1,0},
        {0,0,0,0,1},
        {0,1,1,1,0},
    },
    ['T'] = {
        {1,1,1,1,1},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
    },
    ['U'] = {
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {0,1,1,1,0},
    },
    ['V'] = {
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {0,1,0,1,0},
        {0,0,1,0,0},
    },
    ['W'] = {
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,1,0,1},
        {1,1,0,1,1},
        {1,0,0,0,1},
    },
    ['X'] = {
        {1,0,0,0,1},
        {0,1,0,1,0},
        {0,0,1,0,0},
        {0,1,0,1,0},
        {1,0,0,0,1},
    },
    ['Y'] = {
        {1,0,0,0,1},
        {1,0,0,0,1},
        {0,1,0,1,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
    },
    ['Z'] = {
        {1,1,1,1,1},
        {0,0,0,1,0},
        {0,0,1,0,0},
        {0,1,0,0,0},
        {1,1,1,1,1},
    },

    -- 0-9 (Digit Bitmaps)
    ['0'] = {
        {0,1,1,1,0},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,0,0,0,1},
        {0,1,1,1,0},
    },
    ['1'] = {
        {0,0,1,0,0},
        {0,1,1,0,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
        {0,0,1,0,0},
    },
    ['2'] = {
        {0,1,1,1,0},
        {1,0,0,0,1},
        {0,0,0,1,0},
        {0,0,1,0,0},
        {1,1,1,1,1},
    },
    ['3'] = {
        {0,1,1,1,0},
        {0,0,0,0,1},
        {0,0,1,1,0},
        {0,0,0,0,1},
        {0,1,1,1,0},
    },
    ['4'] = {
        {1,0,0,0,1},
        {1,0,0,0,1},
        {1,1,1,1,1},
        {0,0,0,0,1},
        {0,0,0,0,1},
    },
    ['5'] = {
        {1,1,1,1,1},
        {1,0,0,0,0},
        {1,1,1,1,0},
        {0,0,0,0,1},
        {1,1,1,1,0},
    },
    ['6'] = {
        {0,1,1,1,0},
        {1,0,0,0,0},
        {1,1,1,1,0},
        {1,0,0,0,1},
        {0,1,1,1,0},
    },
    ['7'] = {
        {1,1,1,1,1},
        {0,0,0,0,1},
        {0,0,0,1,0},
        {0,0,1,0,0},
        {0,1,0,0,0},
    },
    ['8'] = {
        {0,1,1,1,0},
        {1,0,0,0,1},
        {0,1,1,1,0},
        {1,0,0,0,1},
        {0,1,1,1,0},
    },
    ['9'] = {
        {0,1,1,1,0},
        {1,0,0,0,1},
        {0,1,1,1,1},
        {0,0,0,0,1},
        {0,1,1,1,0},
    },
    [' '] = { -- space
        {0,0,0,0,0},
        {0,0,0,0,0},
        {0,0,0,0,0},
        {0,0,0,0,0},
        {0,0,0,0,0},
    }
}

#gate in
CreateGateInUnit = function(data)
    SetIgnoreArmyUnitCap(GetFocusArmy(), true)
    for k, v in data.id do
	    CreateUnit(v, GetFocusArmy(), data.pos[1], data.pos[2], data.pos[3], 0,0,0,0, 'Land')
	end
	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
end
	
#gate out
CreateGateOutUnit = function(data)
    SetIgnoreArmyUnitCap(GetFocusArmy(), true)
    for k, v in data.id do
	    CreateUnit(v, GetFocusArmy(), data.pos[1], data.pos[2], data.pos[3], 0,0,0,0, 'Land')
	end
	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
end
	
#teleport start
TeleportUnitsInRange = function(data)
    SetIgnoreArmyUnitCap(GetFocusArmy(), true)
    local range = 20
	local units = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint(ArmyBrains[GetFocusArmy()], categories.MOBILE, data.startPos, range)
	for k, v in units do
	    Warp(v, data.endPos)
		v:PlayTeleportInEffects()
	end
	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
end
			
#nuke current location
CreateNukeStrike = function(data)
    #keep 160 so SMD can shoot it down single shoot (SMD max range 90)?
	local ele = 160
	SetIgnoreArmyUnitCap(GetFocusArmy(), true)

	    for i = 1, data.num do
		    local x = data.pos[1]+Random(-5, 5)
			local y = data.pos[2]+ele+Random(-20,-10)
			local z = data.pos[3]+Random(-5,5)
			local nuke = CreateUnit(data.id, GetFocusArmy(), x, y, z, 0,0,0,0, 'Air')
			nuke:SetElevation(y)
			nuke:HideBone(0, true)
			nuke:SetUnSelectable(true)
			nuke:AddCommandCap('RULEUCC_Nuke')
			nuke:GiveNukeSiloAmmo(1)
			IssueNuke({nuke}, data.pos)
			local voice = Sound {Bank = 'XGG', Cue = 'Computer_Computer_MissileLaunch_01351'}
			ArmyBrains[GetFocusArmy()]:NuclearLaunchDetected(voice)
		end

	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
end

CreateTextNukeStrike = function(data)
    local army   = GetFocusArmy()
    local pos    = data.pos
    local unitId = data.id
    local spacing = 4 -- unit spacing
    local letterSpacing = 6 -- letter spacing
	local text =  data.text
	
    SetIgnoreArmyUnitCap(army, true)
    local x0, z0 = pos[1], pos[3]
    local letterOffset = 0
    text = string.upper(text)
	local textNuke = {}
	local elevation = 160
	
    ForkThread(function()
        for l = 1, string.len(text) do
            local char = string.sub(text, l, l)
            local bitmap = LETTERS[char] or LETTERS[' ']
            local rows = table.getn(bitmap)
            local cols = table.getn(bitmap[1])

            for r = 1, rows do
                for c = 1, cols do
                    if bitmap[r][c] == 1 then
                        local x = x0 + (c - 1) * spacing + letterOffset
                        local z = z0 + (r - 1) * spacing
                        local nuke = CreateUnit(unitId, GetFocusArmy(), x, elevation, z, 0,0,0,0, 'Air')
						nuke:HideBone(0, true)
						nuke:SetUnSelectable(true)
						nuke:GiveNukeSiloAmmo(1)
						table.insert(textNuke, nuke)
                    end
                end
            end

            letterOffset = letterOffset + (cols * spacing) + letterSpacing
        end

        SetIgnoreArmyUnitCap(army, false)
		ForkThread(function()
			InitialNuke(textNuke)
		end)
    end)
end

InitialNuke = function(textNuke)
    for k, v in textNuke do
	    v:AddCommandCap('RULEUCC_Nuke')
		local pos = v:GetPosition()
		IssueNuke({v}, {pos[1], 0, pos[3]})
	end
end

#UEF logo style black holes, 45 in total, deals with enemy land units mainly
CreateUEFBlackHoleStrike = function(data)
    local armyIndex =  GetFocusArmy()
	local readyPos = data.pos
	local life = 30
	local row = 8
	local column = 8
	local adj = 2.5
	local interval = 5
	local ids = data.id
	local killUnits = {}
	SetIgnoreArmyUnitCap(GetFocusArmy(), true)
	for t, u in ids do
    	#local bp = __blueprints.xea0004
		#local sx = bp.SizeX
		#sx = 1 does matter, donot change it
		local sx = 1
		readyPos[1] = readyPos[1] - (interval*3.5)
		readyPos[3] = readyPos[3] - (sx*adj*0.5)
		local i = 0
		for r = 0, (row-1), 1 do
		    for c = 0, (column-1-i), 1 do
			    if i == 0 then
				    local id = 'C'..r..c
					if not (id == 'C02' or id == 'C05') then
					    local cbh = CreateUnitHPR(u, armyIndex, readyPos[1]+r*sx*adj+interval*c, 0, readyPos[3]-r*sx*adj, 0, 0, 0)
						cbh:HideBone(0, true)
						table.insert(killUnits, cbh)
					end
				else
				    local id = 'U'..r..c
					if not (id == 'U11' or id == 'U15' or id == 'U20' or id == 'U25') then
					    local ubh = CreateUnitHPR(u, armyIndex, readyPos[1]+r*sx*adj+interval*c, 0, readyPos[3]-r*sx*adj, 0, 0, 0)
						ubh:HideBone(0, true)
						table.insert(killUnits, ubh)
					end
					local id = 'D'..r..c
					if not (id == 'D11' or id == 'D12' or id == 'D14' or id == 'D15' or id == 'D20' or id == 'D22' or id == 'D23' or id == 'D25'or id == 'D32' or id == 'D41' or id == 'D42'or id == 'D50' or id == 'D52') then
					    local dbh = CreateUnitHPR(u, armyIndex, readyPos[1]+r*sx*adj+interval*c, 0, readyPos[3]+r*sx*adj, 0, 0, 0)
						dbh:HideBone(0, true)
						table.insert(killUnits, dbh)
					end
				end
			end
			i = i + 1
		end
	end
	SetIgnoreArmyUnitCap(GetFocusArmy(), false)
	#black holes lifetime
	ForkThread(function() 
	WaitSeconds(life)
	    for k, v in killUnits do
		    v:Destroy()
		end
	end)
end
	
--create reinforcements in nick name formation
CreateReinforcementSquare = function(data)
    local army   = GetFocusArmy()
    local pos    = data.pos
    local unitId = data.id and data.id[1]
    local spacing = 4 -- unit spacing
    local letterSpacing = 6 -- letter spacing
    local delay = 0.05 -- delay between each unit spawn
	local text =  ArmyBrains[GetFocusArmy()].Nickname or 'FAF'
	local maxLength = 3 --nick name first 3 letters

    if not pos or not unitId then
        WARN('AnimatedLetterFormation: invalid data')
        return
    end

    SetIgnoreArmyUnitCap(army, true)
    local x0, z0 = pos[1], pos[3]
    local letterOffset = 0

    text = string.upper(text)

    ForkThread(function()
        --for l = 1, string.len(text) do
		for l = 1, maxLength do
            local char = string.sub(text, l, l)
            local bitmap = LETTERS[char] or LETTERS[' ']

            local rows = table.getn(bitmap)
            local cols = table.getn(bitmap[1])

            for r = 1, rows do
                for c = 1, cols do
                    if bitmap[r][c] == 1 then
                        local x = x0 + (c - 1) * spacing + letterOffset
                        local z = z0 + (r - 1) * spacing
                        local y = GetTerrainHeight(x, z)

                        local unit = CreateUnitHPR(unitId, army, x, y, z, 0, 0, 0)
                        if unit then
                            unit:PlayTeleportInEffects()
                        end

                        WaitSeconds(delay)
                    end
                end
            end

            letterOffset = letterOffset + (cols * spacing) + letterSpacing
        end

        SetIgnoreArmyUnitCap(army, false)
    end)
end
