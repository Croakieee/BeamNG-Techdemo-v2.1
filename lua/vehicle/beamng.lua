-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}


local Vehicle = {}
Vehicle.__index = Vehicle

-- creation method of the object, inits the member variables
local function newVehicle()
    local vehicle = {}
    setmetatable(vehicle, Vehicle)

    vehicle.ignoreSections = {maxIDs=true, options=true}
    vehicle.vehicle_base_path = "vehicles/"
    vehicle.userPartConfig = {}
    vehicle.slotDescriptions = {}

    vehicle.materials, vehicle.materialsMap = particles.getMaterialsParticlesTable()

    return vehicle
end

function Vehicle:compile(vehicles)
    if not self:prepare(vehicles) then
        logError("*** preparation error")
        return nil
    end

    local linksToResolve = self:prepareLinks(vehicles)
    if linksToResolve == nil then
        logError("*** link preparation error")
        return nil
    end

    if not self:assignCIDs(vehicles) then
        logError("*** numbering error")
        return nil
    end
    
    if not self:resolveLinks(vehicles, linksToResolve) then
        logError("*** link resolving error")
        return nil
    end

    if not self:postProcess(vehicles) then
        logError("*** post processing error")
        return nil
    end

    if not self:optimize(vehicles) then
        logError("*** optimization error")
        return nil
    end

    if not self:updateCollTris(vehicles) then
        logError("*** collision triangle update error")
        return nil
    end

    -- set some options from our side
    vehicles.filename = filename
    vehicles.fullFilename = fn
    vehicles.vehicleDirectory = self.vehicleDirectory
    vehicles.format = "parsed"

    return vehicles
end

function Vehicle:processTableWithSchema(vehicle, keyEntry, entry, newList)
    -- its a list, so a table for us. Verify that the first row is the header
    local header = entry[1]
    if type(header) ~= "table" then
        logError("*** Invalid table header: "..dumps(header))
        return false
    end
    if tableIsDict(header) then
        logError("*** Invalid table header, must be a list, not a dict: "..dumps(header))
        return false
    end

    local headerSize = #header
    local newListSize = 0
    local localOptions = deepcopy( vehicle.options )

    -- remove the header from the data, as we dont need it anymore
    table.remove(entry,1)
    --log("header size: "..headerSize)
    
    -- this was a correct able, record that
    vehicle.validTables[keyEntry] = true
    
    -- walk the list entries
    for rowKey, rowValue in pairs_safe(entry) do
        if type(rowValue) ~= "table" then
            logError("*** Invalid table row: "..dumps(rowValue))
            return false
        end
        if tableIsDict(rowValue) then
            -- case where options is a dict on its own, filling a whole line
            localOptions = tableMerge( localOptions, deepcopy(rowValue) )
        else
            local newID = rowKey
            --log(" *** "..tostring(rowKey).." = "..tostring(rowValue).." ["..type(rowValue).."]")

            -- allow last type to be the options always
            if #rowValue > headerSize + 1 then -- and type(rowValue[#rowValue]) ~= "table" then
                logError("*** Invalid table header, must be as long as all table cells (plus one additional options column):")
                logError("*** Table header: "..dumps(header))
                logError("*** Mismatched row: "..dumps(rowValue))
                return false
            end

            -- walk the table row
            -- replace row: reassociate the header colums as keys to the row cells
            local newRow = {}
            -- scope of row options
            newRow = deepcopy(localOptions)

            -- check if inline options are provided, merge them then
            local rvcc = 0
            for rk,rv in pairs_safe(rowValue) do
                if rvcc >= headerSize and type(rv) == 'table' and tableIsDict(rv) and #rowValue > headerSize then
                    tableMerge(newRow, rv)
                    -- remove the options
                    rowValue[rk] = nil -- remove them for now
                    header[rk] = "options" -- for fixing some code below - let it know those are the options
                    break
                end
                rvcc = rvcc  + 1
            end

            -- now care about the rest
            for rk,rv in pairs_safe(rowValue) do
                --logDebug("### "..header[rk].."//"..tostring(newRow[header[rk]]))
                -- if there is a local option named like a row key, use the option instead
                -- copy things
                newRow[header[rk]] = rv
            end
            --dump(newRow)

            if newRow.id ~= nil then
                newID = newRow.id
                newRow.name = newRow.id -- this keeps the name for debugging or alike
                newRow.id = nil
            end

            -- then look for special values
            for rk,rv in pairs_safe(newRow) do
                newRow[rk] = self:replaceSpecialValues(rv)
            end

            -- done with that row
            newList[newID] = newRow
            newListSize = newListSize + 1
        end
        ::continue::
    end

    return newListSize
end

function Vehicle:prepare(vehicles)
    if type(vehicles) ~= "table" then
        logError("*** Wrong top level vehicles type, must be table")
        return false
    end

    --log(" max table depth="..tableDepth(vehicles))
    if tableDepth(vehicles) > 3 then
        logError("*** Error: table too deep, max depth allowed: 3")
        return false
    end

    --log(" found "..tableSize(vehicles).." vehicles")
    -- walk all vehicles
    for keyVehicle, vehicle in pairs_safe(vehicles) do
        log("- Preparing vehicle: "..tostring(keyVehicle)) --.." = "..tostring(vehicle).." ["..type(vehicle).."], path: "..self.vehicleDirectory)
        -- check for nodes key
        vehicle.maxIDs = {}
        vehicle.validTables = {}
        if vehicle.nodes == nil then
            logError("*** No nodes existing! '"..keyVehicle.."'")
            return false
        end
        -- create empty options
        if vehicle.options == nil then
            vehicle.options = {}
        end
        -- walk everything and look for options
        for keyEntry, entry in pairs_safe(vehicle) do
            if type(entry) ~= "table" then
                -- seems to be a option, add it to the vehicle options
                vehicle.options[keyEntry] = entry
                vehicle[keyEntry] = nil
            end
        end

        -- then walk all (keys) / entries of that vehicle
        for keyEntry, entry in pairs_safe(vehicle) do
            -- verify key names to be proper formatted
            --[[
            if type(entry) == "table" and tableIsDict(entry) then
                log(" ** "..tostring(keyEntry).." = [DICT] #" ..tableSize(entry))
            elseif type(entry) == "table" and not tableIsDict(entry) then
                log(" ** "..tostring(keyEntry).." = [LIST] #"..tableSize(entry))
            else
                log(" ** "..tostring(keyEntry).." = "..tostring(entry).." ["..type(entry).."]")
            end
            ]]--

            if self:verifyElementName(keyEntry) == false then
                logError("*** Invalid attribute name '"..keyEntry.."'")
                return false
            end
            -- init max
            vehicle.maxIDs[keyEntry] = 0
            --log(" ** creating max val "..tostring(keyEntry).." = "..tostring(vehicle.maxIDs[keyEntry]))
            -- then walk the tables
            if type(entry) == "table" and not tableIsDict(entry) and self.ignoreSections[keyEntry] == nil and tableSize(entry) > 0 then
                if tableIsDict(entry) then
                    -- ENTRY DICTS TO BE WRITTEN
                else
                    local newList = {}
                    local newListSize = 0                    
                    newListSize = self:processTableWithSchema(vehicle, keyEntry, entry, newList)
                    vehicle[keyEntry] = newList
                    log(" - "..newListSize.." "..keyEntry)            
                end
            end
        end
        ::continue::
    end
    log("- Vehicle Preparation done.")

    return true
end

function Vehicle:assignCIDs(vehicles)
    -- walk all vehicles
    for keyVehicle, vehicle in pairs(vehicles) do
        vehicle.maxIDs = {}
        for keyEntry, entry in pairs(vehicle) do
            vehicle.maxIDs[keyEntry] = 0
            for rowKey, rowValue in pairs(entry) do
                if vehicle.validTables[keyEntry] == true then
                    rowValue.cid = vehicle.maxIDs[keyEntry]
                    vehicle.maxIDs[keyEntry] = vehicle.maxIDs[keyEntry] + 1
                end
            end
        end
    end
    log("- Vehicle numbering done.")
    return true
end

function Vehicle:verifyElementName(name)
    local match = string.match(name, "^([a-z]+[a-zA-Z0-9]+)$")
    return (match ~= nil)
end

function Vehicle:replaceSpecialValues(val)
    if type(val) == "table" then
        -- recursive replace
        for k, v in pairs(val) do
            val[k] = self:replaceSpecialValues(v)
        end
    end
    if type(val) ~= "string" then
        -- only replace strings
        return val
    end

    if val == "FLT_MAX" then
        return math.huge -- using lua instead FLT_MAX
    end
    if val == "MINUS_FLT_MAX" then
        return -math.huge --MINUS_FLT_MAX
    end

    local partsStr = ""
    if val:sub(1,6) == "flags|" then
        partsStr = val:sub(7)
    elseif val:sub(1,1) == "|" then
        partsStr = val:sub(2)
    end

    if partsStr ~= "" then
        -- flags handling
        local parts = split(partsStr, "|", 999)
        local ival = 0
        for keyPart, valuePart in pairs_safe(parts) do
            --log("### replaceSpecialValues "..tostring(keyPart).." = "..tostring(valuePart))

            -- is it a node material?
            if valuePart:sub(1,3) == "NM_" then
                ival = particles.getMaterialIDByName(self.materials, valuePart:sub(4))
                --print("replaced "..valuePart.." with "..ival)
            end

            if valuePart == "NORMAL" then
                ival = NORMALTYPE -- bit.bor(ival, NORMALTYPE)
            elseif valuePart == "HYDRO" then
                ival = BEAM_HYDRO
            elseif valuePart == "ANISOTROPIC" then
                ival = BEAM_ANISOTROPIC
            elseif valuePart == "TIRESIDE" then
                ival = BEAM_ANISOTROPIC
            elseif valuePart == "BOUNDED" then
                ival = BEAM_BOUNDED
            elseif valuePart == "PRESSURED" then
                ival = BEAM_PRESSURED
            elseif valuePart == "SUPPORT" then
                ival = BEAM_SUPPORT
            elseif valuePart == "FIXED" then
                ival = NODE_FIXED
            elseif valuePart == "NONCOLLIDABLE" then
                ival = NONCOLLIDABLE
            end

            -- the bitmask types
            if valuePart == "SIGNAL_LEFT" then
                ival = bit.bor(ival, GFX_SIGNAL_LEFT)
            elseif valuePart == "SIGNAL_RIGHT" then
                ival = bit.bor(ival, GFX_SIGNAL_RIGHT)
            elseif valuePart == "HEADLIGHT" then
                ival = bit.bor(ival, GFX_HEADLIGHT)
            elseif valuePart == "BRAKELIGHT" then
                ival = bit.bor(ival, GFX_BRAKELIGHT)
            elseif valuePart == "RUNNINGLIGHT" then
                ival = bit.bor(ival, GFX_RUNNINGLIGHT)
            elseif valuePart == "REVERSELIGHT" then
                ival = bit.bor(ival, GFX_REVERSELIGHT)
            end
        end
        if ival ~= 0 then
            --log("### replaced special flags variable '"..val.."' with value '"..tostring(ival).."'")
            return ival
        end
    end
    return val
end

function Vehicle:prepareLinks(vehicles)
    local links = {}
    local keyVehicle, vehicle, keyEntry, entry, rowKey, rowValue, tKey, tValue

    for keyVehicle, vehicle in pairs (vehicles) do
        for keyEntry, entry in pairs (vehicle) do
            if type(entry) == "table" then
                for rowKey, rowValue in pairs_safe(entry) do
                    -- Check for links of the form: "link:section":[1,2,3,4]
                    if type(rowValue) == "table" then
                        local parts = split(rowKey, ":", 2)
                        if #parts == 2 then
                            local sectionName = "nodes"
                            if parts[2] ~= "" then
                                sectionName = parts[2]
                            end

                            if vehicle[sectionName] ~= nil then
                                for tKey, tValue in ipairs(rowValue) do
                                    if vehicle[sectionName][tValue] ~= nil then
                                        table.insert(links, {
                                            rv = rowValue,
                                            kp = tKey, -- "id"
                                            kc = nil, 
                                            ot = vehicle[sectionName][tValue]
                                            } )
                                    else
                                        -- TODO: better info for the modder
                                        log("link not found: from " .. keyEntry .. "/" .. rowKey .. " to "..sectionName.."/"..tValue)
                                        entry[rowKey] = nil
                                        break
                                    end
                                end
                                entry[parts[1]..'_'..sectionName] = rowValue
                                entry[rowKey] = nil
                            end
                        else
                            for cellKey,cellValue in pairs(rowValue) do
                                --logDebug(" * key:"..tostring(cellKey).." = "..tostring(cellValue)..".")
                                local parts = split(cellKey, ":", 5)
                                if #parts == 2 then
                                    if string.match(parts[1], '%[.*%]') == nil then
                                        -- its a link
                                        -- default, resolve to nodes
                                        local sectionName = "nodes"
                                        if parts[2] ~= "" then
                                            sectionName = parts[2]
                                        end

                                        if vehicle[sectionName] ~= nil then
                                            if type(cellValue) == "table" then
                                                for tKey, tValue in ipairs(cellValue) do
                                                    if vehicle[sectionName][tValue] ~= nil then
                                                        table.insert(links, {
                                                            rv = cellValue,
                                                            kp = tKey, -- "id"
                                                            kc = nil, 
                                                            ot = vehicle[sectionName][tValue]
                                                            } )
                                                    else
                                                        -- TODO: better info for the modder
                                                        log("link not found: from " .. keyEntry .. "/" .. rowKey .. " to "..sectionName.."/"..tValue)
                                                        entry[rowKey] = nil
                                                        break
                                                    end
                                                end
                                            else
                                                 if vehicle[sectionName][cellValue] ~= nil then
                                                    table.insert(links, {
                                                        rv = rowValue,
                                                        kp = parts[1], -- "id"
                                                        kc = cellKey,  -- "id:"
                                                        ot = vehicle[sectionName][cellValue]
                                                        } )
                                                else
                                                    -- TODO: better info for the modder
                                                    log("link not found: from " .. keyEntry .. "/" .. rowKey .. " to "..sectionName.."/"..cellValue)
                                                    entry[rowKey] = nil
                                                    break
                                                end
                                            end
                                        end
                                    -- else
                                    --     local sectionName = "nodes"
                                    --     if parts[2] ~= "" then
                                    --         sectionName = parts[2]
                                    --     end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    --saveG()

    return links
end

function Vehicle:resolveLinks(vehicles, links)
    -- walk all vehicles
    for k,d in pairs(links) do
        d.rv[d.kp] = d.ot.cid
        if d.kc ~= nil then
            d.rv[d.kc] = nil
        end
    end
    
    for keyVehicle, vehicle in pairs (vehicles) do
        -- walk all sections
        for sectionName, section in pairs (vehicle) do
            if type(section) == "table" then
                -- walk all rows
                local newSection = {}
                for rowKey, rowValue in pairs_safe(section) do
                    if vehicle.validTables[sectionName] == true and rowValue.cid then
                        newSection[rowValue.cid] = rowValue
                    else
                        newSection[rowKey] = rowValue
                    end
                end
                vehicle[sectionName] = newSection
            end
        end
    end
    return true
end

function Vehicle:resolveGroupLinks(vehicle)
    local linksResolved = 0
    local optional = false
    -- walk all sections
    for keyEntry, entry in pairs(vehicle) do
        -- walk all vehicle sections
        if type(entry) == "table" then
            for rowKey, rowValue in pairs(entry) do
                if type(rowValue) == "table" then
                    -- walk all cells
                    local journal = {}
                    for cellKey, groupvals in pairs(rowValue) do
                        if string.sub(cellKey,1,1) == '[' then
                            local groupname
                            local sectioname
                            groupname, sectioname = string.match(cellKey, '%[(.*)%]:(.*)')
                            if groupname and groupvals ~= nil then
                                if sectioname == '' then sectioname = "nodes" end
                                if type(groupvals) == 'string' then
                                    groupvals = {groupvals}
                                end
                                local cids = {}
                                local groupindex = {}
                                -- Create groupvals index
                                for _, gvalname in pairs(groupvals) do
                                    groupindex[gvalname] = 1
                                end
                                -- walk all specified groups
                                for key, val in pairs(vehicle[sectioname]) do
                                    if val[groupname] ~= nil then
                                        -- little fix for one group, gets transformed into a list
                                        if type(val[groupname]) == 'string' then
                                            val[groupname] = {val[groupname]}
                                        end
                                        for _, gvalname in pairs(val[groupname]) do
                                            if groupindex[gvalname] ~= nil then
                                                table.insert(cids, val.cid)
                                                break
                                            end
                                        end
                                    end
                                end
                                journal['_'..groupname..'_'..sectioname] = cids
                            end
                        end
                    end
                    -- play journal
                    for key, val in pairs(journal) do
                        rowValue[key] = val
                    end
                end
            end
        end
    end
    return true
end

function Vehicle:addRotator(vehicle, wheelKey, wheel)
    wheel.frictionCoef = wheel.frictionCoef or 1

    local nodes = {}
    if wheel._group_nodes ~= nil then
        arrayConcat(nodes, wheel._group_nodes)
    end

    if wheel._rotatorGroup_nodes ~= nil then
        arrayConcat(nodes, _rotatorGroup_nodes)
    end    

    if next(nodes) ~= nil then
        wheel.nodes = nodes
    end
end

function Vehicle:addWheel(vehicle, wheelKey, wheel)
    --log("wheel vehicle:")
    --dump(wheel)
    local node1   = vehicle.nodes[wheel.node1]
    local node2   = vehicle.nodes[wheel.node2]
    local nodeArm = vehicle.nodes[wheel.nodeArm]

    if node1 == nil or node2 == nil then
        logError("invalid wheel")
        return
    end
    --[[
    log("wheel N1")
    dump(node1)
    log("wheel N2")
    dump(node2)
    log("wheel NArm")
    dump(nodeArm)

    log(">>>>")
    dump(vehicle)
    log("<<<<")
    ]]--

    local nodebase = vehicle.maxIDs.nodes

    if wheel.radius == nil then wheel.radius = 0.5 end    
    if wheel.numRays == nil then wheel.numRays = 10 end    

    -- add collision to the wheels nodes ;)
    wheel.collision = true

    -- TODO: fix mass
    wheel.mass = nil

    -- fix it like this
    local node1_pos = tableToFloat3(node1.pos)
    local node2_pos = tableToFloat3(node2.pos)

    --log("n1 = " .. tostring(node1_pos) .. " , n2 = " .. tostring(node2_pos))

    local width = node1_pos:distance(node2_pos)
    --log("wheel width: "..width)

    -- swap nodes?
    if node1_pos.z > node2_pos.z then
        log("swapping wheel nodes ...")
        node1, node2 = node2, node1
    end

    -- calculate axis
    local axis = node2_pos - node1_pos
    axis:normalize()

    local midpoint = (node2_pos + node1_pos) * float3(0.5, 0.5, 0.5)
    if wheel.wheelOffset ~= nil then
        local offset = wheelOffset
        midpoint = midpoint + axis * float3(offset, offset, offset)
    end

    --log("wheel axis:" .. tostring(axis))


    local rayVec = axis:getPerpendicularVector() * float3(wheel.radius, wheel.radius, wheel.radius)
    --log("rayVector: " .. tostring(rayVec))

    local rayRot = Quaternion( (-360 / (wheel.numRays* 2)) , axis);
    --log("rayRot: " .. tostring(rayRot))

    if wheel.tireWidth ~= nil then
        local halfWidth = 0.5 * wheel.tireWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    -- add nodes first
    local wheelNodes = {}
    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)
        table.insert(wheelNodes, n)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)
        table.insert(wheelNodes, n)
    end

    -- then add the beams
    --local wheelBeams = {}
    local b = 0

    local sideOptions = deepcopy(wheel)
    sideOptions.beamSpring   = sideOptions.wheelSideBeamSpring
    sideOptions.beamDamp     = sideOptions.wheelSideBeamDamp
    sideOptions.beamDeform   = sideOptions.wheelSideBeamDeform
    sideOptions.beamStrength = sideOptions.wheelSideBeamStrength

    local reinforcementOptions = deepcopy(wheel)
    reinforcementOptions.beamSpring   = reinforcementOptions.wheelReinforcementBeamSpring
    reinforcementOptions.beamDamp     = reinforcementOptions.wheelReinforcementBeamDamp
    reinforcementOptions.beamDeform   = reinforcementOptions.wheelReinforcementBeamDeform
    reinforcementOptions.beamStrength = reinforcementOptions.wheelReinforcementBeamStrength
    reinforcementOptions.springExpansion = reinforcementOptions.wheelReinforcementBeamSpringExpansion
    reinforcementOptions.dampExpansion   = reinforcementOptions.wheelReinforcementBeamDampExpansion

    local treadOptions = deepcopy(wheel)
    treadOptions.beamSpring      = treadOptions.wheelTreadBeamSpring
    treadOptions.beamDamp        = treadOptions.wheelTreadBeamDamp
    treadOptions.beamDeform      = treadOptions.wheelTreadBeamDeform
    treadOptions.beamStrength    = treadOptions.wheelTreadBeamStrength
    treadOptions.springExpansion = treadOptions.wheelTreadBeamSpringExpansion
    treadOptions.dampExpansion   = treadOptions.wheelTreadBeamDampExpansion

    local peripheryOptions     = deepcopy(treadOptions)
    if peripheryOptions.wheelPeripheryBeamSpring ~=nil then peripheryOptions.beamSpring = peripheryOptions.wheelPeripheryBeamSpring end
    if peripheryOptions.wheelPeripheryBeamDamp ~= nil then peripheryOptions.beamDamp = peripheryOptions.wheelPeripheryBeamDamp end
    if peripheryOptions.wheelPeripheryBeamDeform ~= nil then peripheryOptions.beamDeform = peripheryOptions.wheelPeripheryBeamDeform end
    if peripheryOptions.wheelPeripheryBeamStrength ~= nil then peripheryOptions.beamStrength = peripheryOptions.wheelPeripheryBeamStrength end

    --dump(wheel)
    -- the rest
    for i = 0, wheel.numRays - 1, 1 do
        local intirenode = nodebase + 2*i
        local outtirenode = intirenode + 1
        local nextintirenode = nodebase + 2*((i+1)%wheel.numRays)
        local nextouttirenode = nextintirenode + 1
        -- sides
        b = self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, intirenode,  BEAM_ANISOTROPIC, sideOptions)
        --table.insert(wheelBeams, b.cid)
        b = self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, outtirenode, BEAM_ANISOTROPIC, sideOptions)
        --table.insert(wheelBeams, b.cid)

        -- reinforcement (X) beams
        b = self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, intirenode,   BEAM_ANISOTROPIC,    reinforcementOptions)
        --table.insert(wheelBeams, b.cid)
        b = self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, outtirenode, BEAM_ANISOTROPIC,    reinforcementOptions)
        --table.insert(wheelBeams, b.cid)

        -- tread
        b = self:addBeamWithOptions(vehicle, 'wheels', intirenode, outtirenode,  BEAM_ANISOTROPIC, treadOptions)
        --table.insert(wheelBeams, b.cid)
        -- Periphery beam
        b = self:addBeamWithOptions(vehicle, 'wheels', intirenode, nextintirenode, NORMALTYPE, peripheryOptions)
        --table.insert(wheelBeams, b.cid)
        -- Periphery beam
        b = self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouttirenode, NORMALTYPE, peripheryOptions)
        --table.insert(wheelBeams, b.cid)
        b = self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextintirenode, BEAM_ANISOTROPIC, treadOptions)
        --table.insert(wheelBeams, b.cid)
    end

    -- record the wheel nodes
    wheel.nodes = wheelNodes
    -- record the wheel beams
    -- vehicle.wheels[wheelKey].beams = wheelBeams
end

function Vehicle:addMonoHubWheel(vehicle, wheelKey, wheel)
    --log("wheel vehicle:")
    --dump(wheel)
    local node1   = vehicle.nodes[wheel.node1]
    local node2   = vehicle.nodes[wheel.node2]
    local nodeArm = vehicle.nodes[wheel.nodeArm]

    if node1 == nil or node2 == nil then
        logError("invalid monohub wheel")
        return
    end

    if wheel.radius == nil then    wheel.radius = 0.5 end
    if wheel.hubRadius == nil then wheel.hubRadius = 0.65 * wheel.radius end
    if wheel.numRays == nil then wheel.numRays = 10 end        

    local nodebase = vehicle.maxIDs.nodes

    -- add collision to the wheels nodes ;)
    wheel.collision = true

    -- TODO: fix mass
    wheel.mass = nil

    -- fix it like this
    local node1_pos = tableToFloat3(node1.pos)
    local node2_pos = tableToFloat3(node2.pos)

    --log("n1 = " .. tostring(node1_pos) .. " , n2 = " .. tostring(node2_pos))

    local width = node1_pos:distance(node2_pos)
    --log("monohub wheel width: "..width)

    -- swap nodes?
    if node1_pos.z > node2_pos.z then
        log("swapping monohub wheel nodes ...")
        node1, node2 = node2, node1
    end

    -- calculate axis
    local axis = node2_pos - node1_pos
    axis:normalize()

    local midpoint = (node2_pos + node1_pos) * float3(0.5, 0.5, 0.5)
    if wheel.wheelOffset ~= nil then
        local offset = wheel.wheelOffset
        midpoint = midpoint + axis * float3(offset, offset, offset)
    end

    --log("wheel axis:" .. tostring(axis))

    local rayVec = axis:getPerpendicularVector() * float3(wheel.radius, wheel.radius, wheel.radius)
    --log("rayVector: " .. tostring(rayVec))

    local rayRot = Quaternion( (-360 / (wheel.numRays* 2)) , axis);
    --log("rayRot: " .. tostring(rayRot))

    if wheel.tireWidth ~= nil then
        local halfWidth = 0.5 * wheel.tireWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    -- add nodes first
    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)
    end

    -- then add the beams

    local sideOptions = deepcopy(wheel)
    sideOptions.beamSpring   = sideOptions.wheelSideBeamSpring
    sideOptions.beamDamp     = sideOptions.wheelSideBeamDamp
    sideOptions.beamDeform   = sideOptions.wheelSideBeamDeform
    sideOptions.beamStrength = sideOptions.wheelSideBeamStrength

    local treadOptions = deepcopy(wheel)
    treadOptions.beamSpring      = treadOptions.wheelTreadBeamSpring
    treadOptions.beamDamp        = treadOptions.wheelTreadBeamDamp
    treadOptions.beamDeform      = treadOptions.wheelTreadBeamDeform
    treadOptions.beamStrength    = treadOptions.wheelTreadBeamStrength
    treadOptions.springExpansion = treadOptions.wheelTreadBeamSpringExpansion
    treadOptions.dampExpansion   = treadOptions.wheelTreadBeamDampExpansion

    local peripheryOptions     = deepcopy(treadOptions)
    if peripheryOptions.wheelPeripheryBeamSpring ~=nil then peripheryOptions.beamSpring = peripheryOptions.wheelPeripheryBeamSpring end
    if peripheryOptions.wheelPeripheryBeamDamp ~= nil then peripheryOptions.beamDamp = peripheryOptions.wheelPeripheryBeamDamp end
    if peripheryOptions.wheelPeripheryBeamDeform ~= nil then peripheryOptions.beamDeform = peripheryOptions.wheelPeripheryBeamDeform end
    if peripheryOptions.wheelPeripheryBeamStrength ~= nil then peripheryOptions.beamStrength = peripheryOptions.wheelPeripheryBeamStrength end

    local hubOptions = deepcopy(wheel)
    if hubOptions.hubNodeWeight ~= nil then hubOptions.nodeWeight = hubOptions.hubNodeWeight end
    if hubOptions.hubCollision ~= nil then hubOptions.collision = hubOptions.hubCollision end
    if hubOptions.hubNodeMaterial ~= nil then hubOptions.nodeMaterial = hubOptions.hubNodeMaterial end
    if hubOptions.hubFrictionCoef ~= nil then hubOptions.frictionCoef = hubOptions.hubFrictionCoef end

    local supportOptions = deepcopy(hubOptions)
    supportOptions.beamPrecompression = (0.75 * wheel.hubRadius / wheel.radius) + 0.25

    for i = 0, wheel.numRays - 1, 1 do
        local intirenode = nodebase + 2*i
        local outtirenode = intirenode + 1
        local nextintirenode = nodebase + 2*((i+1)%wheel.numRays)
        local nextouttirenode = nextintirenode + 1
        -- Sides
        self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, intirenode,  BEAM_ANISOTROPIC, sideOptions)
        self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, outtirenode, BEAM_ANISOTROPIC, sideOptions)
        -- Tire tread
        self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outtirenode,    BEAM_ANISOTROPIC, treadOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextintirenode, BEAM_ANISOTROPIC, treadOptions)
        -- Periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', intirenode,  nextintirenode,  NORMALTYPE, peripheryOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouttirenode, NORMALTYPE, peripheryOptions)
        -- Support beams
        self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, intirenode,  BEAM_SUPPORT, supportOptions)
        self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, outtirenode, BEAM_SUPPORT, supportOptions)
    end

    -- monoHub
    local rayVec = axis:getPerpendicularVector() * float3(wheel.hubRadius, wheel.hubRadius, wheel.hubRadius)

    -- initial rotation
    local tmpRot = Quaternion( -360 / (wheel.numRays * 4) , axis);
    rayVec = tmpRot:multiply(rayVec)
    -- all hub node rotation
    rayRot = Quaternion( -360 / (wheel.numRays) , axis);
    --log("rayVector: " .. tostring(rayVec))

    -- add monoHub nodes
    local hubNodes = {}
    local n = 0
    local hubnodebase = vehicle.maxIDs.nodes

    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        local rayPoint = midpoint + rayVec
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        rayVec = rayRot:multiply(rayVec)
        table.insert(hubNodes, n)
    end

    if hubOptions.hubBeamSpring ~= nil then hubOptions.beamSpring = hubOptions.hubBeamSpring end
    if hubOptions.hubBeamDamp ~= nil then hubOptions.beamDamp = hubOptions.hubBeamDamp end
    if hubOptions.hubBeamDeform ~= nil then hubOptions.beamDeform = hubOptions.hubBeamDeform end
    if hubOptions.hubBeamStrength ~=nil then hubOptions.beamStrength = hubOptions.hubBeamStrength end

    -- hub-tire beams options
    local reinforcementOptions = deepcopy(wheel)
    reinforcementOptions.beamSpring   = reinforcementOptions.wheelReinforcementBeamSpring
    reinforcementOptions.beamDamp     = reinforcementOptions.wheelReinforcementBeamDamp
    reinforcementOptions.beamDeform   = reinforcementOptions.wheelReinforcementBeamDeform
    reinforcementOptions.beamStrength = reinforcementOptions.wheelReinforcementBeamStrength
    reinforcementOptions.springExpansion = reinforcementOptions.wheelReinforcementBeamSpringExpansion
    reinforcementOptions.dampExpansion   = reinforcementOptions.wheelReinforcementBeamDampExpansion

    for i = 0, wheel.numRays - 1, 1 do
        local hubnode = hubnodebase + i
        local nexthubnode = hubnodebase + ((i+1)%wheel.numRays)
        local intirenode = nodebase + 2*i
        local outtirenode = intirenode + 1
        local nextintirenode = nodebase + 2*((i+1)%wheel.numRays)
        -- hub-axis beams
        self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, hubnode, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, hubnode, NORMALTYPE, hubOptions)
        -- hub periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', hubnode, nexthubnode, NORMALTYPE, hubOptions)

        -- hub-tire beams
        self:addBeamWithOptions(vehicle, 'wheels', hubnode, intirenode,  BEAM_ANISOTROPIC, reinforcementOptions)
        self:addBeamWithOptions(vehicle, 'wheels', hubnode, outtirenode, BEAM_ANISOTROPIC, reinforcementOptions)
        self:addBeamWithOptions(vehicle, 'wheels', hubnode, nextintirenode,  BEAM_ANISOTROPIC, reinforcementOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nexthubnode, BEAM_ANISOTROPIC, reinforcementOptions)

    end

    wheel.nodes = hubNodes
end

function Vehicle:addHubWheelTSV(vehicle, wheelKey, wheel)
    local node1   = vehicle.nodes[wheel.node1]
    local node2   = vehicle.nodes[wheel.node2]
    local nodeArm = vehicle.nodes[wheel.nodeArm]

    if node1 == nil or node2 == nil then
        logError("invalid hubWheel")
        return
    end

    local nodebase = vehicle.maxIDs.nodes

    if wheel.radius == nil then    wheel.radius = 0.5 end
    if wheel.hubRadius == nil then wheel.hubRadius = 0.65 * wheel.radius end
    if wheel.numRays == nil then wheel.numRays = 10 end

    -- add collision to the wheels nodes ;)
    wheel.collision = true

    -- fix it like this
    local node1_pos = tableToFloat3(node1.pos)
    local node2_pos = tableToFloat3(node2.pos)

    local width = node1_pos:distance(node2_pos)

    -- swap nodes?
    if node1_pos.z > node2_pos.z then
        log("swapping hubWheel nodes ...")
        node1, node2 = node2, node1
    end

    -- calculate axis
    local axis = node2_pos - node1_pos
    axis:normalize()

    local midpoint = (node2_pos + node1_pos) * float3(0.5, 0.5, 0.5)
    if wheel.wheelOffset ~= nil then
        local offset = wheel.wheelOffset
        midpoint = midpoint + axis * float3(offset, offset, offset)
    end

    if wheel.tireWidth ~= nil then
        local halfWidth = 0.5 * wheel.tireWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    local rayVec = axis:getPerpendicularVector() * float3(wheel.radius, wheel.radius, wheel.radius)
    local rayRot = Quaternion( (-360 / (wheel.numRays* 2)) , axis);

    -- add nodes first
    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)
    end

    -- add Hub nodes
    local hubNodes = {}
    local n = 0
    local hubnodebase = vehicle.maxIDs.nodes

    local hubOptions = deepcopy(wheel)
    if hubOptions.hubBeamSpring ~= nil then hubOptions.beamSpring = hubOptions.hubBeamSpring end
    if hubOptions.hubBeamDamp ~= nil then hubOptions.beamDamp = hubOptions.hubBeamDamp end
    if hubOptions.hubBeamDeform ~= nil then hubOptions.beamDeform = hubOptions.hubBeamDeform end
    if hubOptions.hubBeamStrength ~=nil then hubOptions.beamStrength = hubOptions.hubBeamStrength end
    if hubOptions.hubNodeWeight ~= nil then hubOptions.nodeWeight = hubOptions.hubNodeWeight end
    if hubOptions.hubCollision ~= nil then hubOptions.collision = hubOptions.hubCollision end
    if hubOptions.hubNodeMaterial ~= nil then hubOptions.nodeMaterial = hubOptions.hubNodeMaterial end
    if hubOptions.hubFrictionCoef ~= nil then hubOptions.frictionCoef = hubOptions.hubFrictionCoef end

    rayVec = axis:getPerpendicularVector() * float3(wheel.hubRadius, wheel.hubRadius, wheel.hubRadius)

    if wheel.hubWidth ~= nil then
        local halfWidth = 0.5 * wheel.hubWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)

        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)
    end

    local sideOptions = deepcopy(wheel)
    sideOptions.beamSpring   = sideOptions.wheelSideBeamSpring
    sideOptions.beamDamp     = sideOptions.wheelSideBeamDamp
    sideOptions.beamDeform   = sideOptions.wheelSideBeamDeform
    sideOptions.beamStrength = sideOptions.wheelSideBeamStrength

    -- hub-tire beams options
    local reinforcementOptions = deepcopy(wheel)
    reinforcementOptions.beamSpring   = reinforcementOptions.wheelReinforcementBeamSpring
    reinforcementOptions.beamDamp     = reinforcementOptions.wheelReinforcementBeamDamp
    reinforcementOptions.beamDeform   = reinforcementOptions.wheelReinforcementBeamDeform
    reinforcementOptions.beamStrength = reinforcementOptions.wheelReinforcementBeamStrength
    reinforcementOptions.springExpansion = reinforcementOptions.wheelReinforcementBeamSpringExpansion
    reinforcementOptions.dampExpansion   = reinforcementOptions.wheelReinforcementBeamDampExpansion

    local treadOptions = deepcopy(wheel)
    treadOptions.beamSpring      = treadOptions.wheelTreadBeamSpring
    treadOptions.beamDamp        = treadOptions.wheelTreadBeamDamp
    treadOptions.beamDeform      = treadOptions.wheelTreadBeamDeform
    treadOptions.beamStrength    = treadOptions.wheelTreadBeamStrength
    treadOptions.springExpansion = treadOptions.wheelTreadBeamSpringExpansion
    treadOptions.dampExpansion   = treadOptions.wheelTreadBeamDampExpansion

    local peripheryOptions     = deepcopy(treadOptions)
    if peripheryOptions.wheelPeripheryBeamSpring ~=nil then peripheryOptions.beamSpring = peripheryOptions.wheelPeripheryBeamSpring end
    if peripheryOptions.wheelPeripheryBeamDamp ~= nil then peripheryOptions.beamDamp = peripheryOptions.wheelPeripheryBeamDamp end
    if peripheryOptions.wheelPeripheryBeamDeform ~= nil then peripheryOptions.beamDeform = peripheryOptions.wheelPeripheryBeamDeform end
    if peripheryOptions.wheelPeripheryBeamStrength ~= nil then peripheryOptions.beamStrength = peripheryOptions.wheelPeripheryBeamStrength end

    local supportOptions = deepcopy(hubOptions)
    supportOptions.beamPrecompression = (0.75 * wheel.hubRadius / wheel.radius) + 0.25

    local reinforcementBeams = {}
    local sideBeams = {}
    local treadBeams = {}

    for i = 0, wheel.numRays - 1, 1 do
        local i2 = 2*i
        local nextdelta = 2*((i+1)%wheel.numRays)
        local outhubnode = hubnodebase + i2
        local inhubnode = outhubnode + 1
        local nextouthubnode = hubnodebase + nextdelta
        local nextinhubnode = nextouthubnode + 1
        local intirenode = nodebase + i2
        local outtirenode = intirenode + 1
        local nextintirenode = nodebase + nextdelta
        local nextouttirenode = nextintirenode + 1
        --tire tread
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outtirenode,    BEAM_ANISOTROPIC, treadOptions) )
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextintirenode, BEAM_ANISOTROPIC, treadOptions) )
        -- Periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', intirenode,  nextintirenode,  NORMALTYPE, peripheryOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouttirenode, NORMALTYPE, peripheryOptions)

        --hub tread
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, inhubnode,      NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  nextouthubnode, NORMALTYPE, hubOptions)
        --hub periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, nextouthubnode, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  nextinhubnode,  NORMALTYPE, hubOptions)

        --hub axis beams
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node1, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node2, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node1, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node2, NORMALTYPE, hubOptions)

        --hub tire beams
        table.insert( reinforcementBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  intirenode,     BEAM_ANISOTROPIC, reinforcementOptions) )
        table.insert( reinforcementBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   outtirenode,    BEAM_ANISOTROPIC, reinforcementOptions) )
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  outtirenode,    BEAM_ANISOTROPIC, sideOptions) )
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouthubnode, BEAM_ANISOTROPIC, sideOptions) )
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   intirenode,     BEAM_ANISOTROPIC, sideOptions) )
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   nextintirenode, BEAM_ANISOTROPIC, sideOptions) )

        -- Support beams
        if wheel.enableTireSideSupportBeams then
            self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, intirenode,  BEAM_SUPPORT, supportOptions)
            self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, outtirenode, BEAM_SUPPORT, supportOptions)
        end
    end

    wheel.nodes = hubNodes
    wheel.reinforcementBeams = reinforcementBeams
    wheel.sideBeams = sideBeams
    wheel.treadBeams = treadBeams
end

function Vehicle:addHubWheelTSI(vehicle, wheelKey, wheel)
    local node1   = vehicle.nodes[wheel.node1]
    local node2   = vehicle.nodes[wheel.node2]
    local nodeArm = vehicle.nodes[wheel.nodeArm]

    if node1 == nil or node2 == nil then
        logError("invalid hubWheel")
        return
    end

    local nodebase = vehicle.maxIDs.nodes

    if wheel.radius == nil then    wheel.radius = 0.5 end
    if wheel.hubRadius == nil then wheel.hubRadius = 0.65 * wheel.radius end
    if wheel.numRays == nil then wheel.numRays = 10 end

    -- add collision to the wheels nodes ;)
    wheel.collision = true

    -- fix it like this
    local node1_pos = tableToFloat3(node1.pos)
    local node2_pos = tableToFloat3(node2.pos)
    local width = node1_pos:distance(node2_pos)

    -- swap nodes?
    if node1_pos.z > node2_pos.z then
        log("swapping hubWheel nodes ...")
        node1, node2 = node2, node1
    end

    -- calculate axis
    local axis = node2_pos - node1_pos
    axis:normalize()

    local midpoint = (node2_pos + node1_pos) * float3(0.5, 0.5, 0.5)
    if wheel.wheelOffset ~= nil then
        local offset = wheel.wheelOffset
        midpoint = midpoint + axis * float3(offset, offset, offset)
    end

    if wheel.tireWidth ~= nil then
        local halfWidth = 0.5 * wheel.tireWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    else
        wheel.tireWidth = width
    end

    local rayVec = axis:getPerpendicularVector() * float3(wheel.radius, wheel.radius, wheel.radius)
    local rayRot = Quaternion( (-360 / (wheel.numRays* 2)) , axis);

    -- add nodes first
    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)
    end

    -- add Hub nodes
    local hubNodes = {}
    local n = 0
    local hubnodebase = vehicle.maxIDs.nodes

    local hubOptions = deepcopy(wheel)
    if hubOptions.hubBeamSpring ~= nil then hubOptions.beamSpring = hubOptions.hubBeamSpring end
    if hubOptions.hubBeamDamp ~= nil then hubOptions.beamDamp = hubOptions.hubBeamDamp end
    if hubOptions.hubBeamDeform ~= nil then hubOptions.beamDeform = hubOptions.hubBeamDeform end
    if hubOptions.hubBeamStrength ~=nil then hubOptions.beamStrength = hubOptions.hubBeamStrength end
    if hubOptions.hubNodeWeight ~= nil then hubOptions.nodeWeight = hubOptions.hubNodeWeight end
    if hubOptions.hubCollision ~= nil then hubOptions.collision = hubOptions.hubCollision end
    if hubOptions.hubNodeMaterial ~= nil then hubOptions.nodeMaterial = hubOptions.hubNodeMaterial end
    if hubOptions.hubFrictionCoef ~= nil then hubOptions.frictionCoef = hubOptions.hubFrictionCoef end

    rayVec = axis:getPerpendicularVector() * float3(wheel.hubRadius, wheel.hubRadius, wheel.hubRadius)

    if wheel.hubWidth ~= nil then
        local halfWidth = 0.5 * wheel.hubWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    else
        wheel.hubWidth = width
    end

    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)
    end

    local sideOptions = deepcopy(wheel)
    sideOptions.beamSpring   = sideOptions.wheelSideBeamSpring
    sideOptions.beamDamp     = sideOptions.wheelSideBeamDamp
    sideOptions.beamDeform   = sideOptions.wheelSideBeamDeform
    sideOptions.beamStrength = sideOptions.wheelSideBeamStrength

    -- hub-tire beams options
    local reinforcementOptions = deepcopy(wheel)
    reinforcementOptions.beamSpring   = reinforcementOptions.wheelReinforcementBeamSpring
    reinforcementOptions.beamDamp     = reinforcementOptions.wheelReinforcementBeamDamp
    reinforcementOptions.beamDeform   = reinforcementOptions.wheelReinforcementBeamDeform
    reinforcementOptions.beamStrength = reinforcementOptions.wheelReinforcementBeamStrength
    reinforcementOptions.springExpansion = reinforcementOptions.wheelReinforcementBeamSpringExpansion
    reinforcementOptions.dampExpansion   = reinforcementOptions.wheelReinforcementBeamDampExpansion

    local treadOptions = deepcopy(wheel)
    treadOptions.beamSpring      = treadOptions.wheelTreadBeamSpring
    treadOptions.beamDamp        = treadOptions.wheelTreadBeamDamp
    treadOptions.beamDeform      = treadOptions.wheelTreadBeamDeform
    treadOptions.beamStrength    = treadOptions.wheelTreadBeamStrength
    treadOptions.springExpansion = treadOptions.wheelTreadBeamSpringExpansion
    treadOptions.dampExpansion   = treadOptions.wheelTreadBeamDampExpansion

    local peripheryOptions     = deepcopy(treadOptions)
    if peripheryOptions.wheelPeripheryBeamSpring ~=nil then peripheryOptions.beamSpring = peripheryOptions.wheelPeripheryBeamSpring end
    if peripheryOptions.wheelPeripheryBeamDamp ~= nil then peripheryOptions.beamDamp = peripheryOptions.wheelPeripheryBeamDamp end
    if peripheryOptions.wheelPeripheryBeamDeform ~= nil then peripheryOptions.beamDeform = peripheryOptions.wheelPeripheryBeamDeform end
    if peripheryOptions.wheelPeripheryBeamStrength ~= nil then peripheryOptions.beamStrength = peripheryOptions.wheelPeripheryBeamStrength end

    local supportOptions = deepcopy(hubOptions)
    supportOptions.beamPrecompression = (0.75 * wheel.hubRadius / wheel.radius) + 0.25

    local pressuredOptions = deepcopy(reinforcementOptions)
    pressuredOptions.pressurePSI = pressuredOptions.pressurePSI or 30
    pressuredOptions.beamSpring = pressuredOptions.pressureSpring or pressuredOptions.springExpansion
    pressuredOptions.beamDamp = pressuredOptions.pressureDamp or pressuredOptions.dampExpansion
    pressuredOptions.volumeCoef = 1 / (wheel.numRays * 6)
    pressuredOptions.surface = math.pi * (
                                wheel.radius * wheel.tireWidth + wheel.hubRadius * wheel.hubWidth
                                + wheel.radius * wheel.radius - wheel.hubRadius * wheel.hubRadius) / (wheel.numRays * 6)

    local reinfPressureOptions = deepcopy(pressuredOptions)
    reinfPressureOptions.pressurePSI = reinfPressureOptions.reinforcementPressurePSI or reinfPressureOptions.pressurePSI
    reinfPressureOptions.beamSpring = reinfPressureOptions.reinforcementPressureSpring or reinfPressureOptions.beamSpring
    reinfPressureOptions.beamDamp = reinfPressureOptions.reinforcementPressureDamp or reinfPressureOptions.beamDamp

    local pressuredBeams = {}
    local treadBeams = {}
    local reinforcementBeams = {}

    for i = 0, wheel.numRays - 1, 1 do
        local i2 = 2*i
        local nextdelta = 2*((i+1)%wheel.numRays)
        local inhubnode = hubnodebase + i2
        local outhubnode = inhubnode + 1
        local nextinhubnode = hubnodebase + nextdelta
        local nextouthubnode = nextinhubnode + 1
        local intirenode = nodebase + i2
        local outtirenode = intirenode + 1
        local nextintirenode = nodebase + nextdelta
        local nextouttirenode = nextintirenode + 1

        --tire tread
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outtirenode,    BEAM_ANISOTROPIC, treadOptions) )
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextintirenode, BEAM_ANISOTROPIC, treadOptions) )

        -- paired treadnodes
        vehicle.nodes[intirenode].pairedNode = outtirenode
        vehicle.nodes[outtirenode].pairedNode = nextintirenode

        -- Periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', intirenode,  nextintirenode,  NORMALTYPE, peripheryOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouttirenode, NORMALTYPE, peripheryOptions)

        --hub tread
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  outhubnode,    NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, nextinhubnode, NORMALTYPE, hubOptions)

        --hub periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, nextouthubnode, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  nextinhubnode,  NORMALTYPE, hubOptions)

        --hub axis beams
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node1, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node2, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node1, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node2, NORMALTYPE, hubOptions)

        --hub tire beams
        -- table.insert( sideBeams,
        --     self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   intirenode,     BEAM_ANISOTROPIC, sideOptions) )
        -- table.insert( sideBeams,
        --     self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  outtirenode,    BEAM_ANISOTROPIC, sideOptions) )
        -- table.insert( reinforcementBeams,
        --     self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outhubnode,     BEAM_ANISOTROPIC, reinforcementOptions)    )
        -- table.insert( reinforcementBeams,
        --     self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   outtirenode,    BEAM_ANISOTROPIC, reinforcementOptions) )
        -- table.insert( reinforcementBeams,
        --     self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextinhubnode,  BEAM_ANISOTROPIC, reinforcementOptions) )
        -- table.insert( reinforcementBeams,
        --     self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  nextintirenode, BEAM_ANISOTROPIC, reinforcementOptions)    )

        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   intirenode,     BEAM_PRESSURED, pressuredOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  outtirenode,    BEAM_PRESSURED, pressuredOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outhubnode,     BEAM_PRESSURED, reinfPressureOptions)    )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   outtirenode,    BEAM_PRESSURED, reinfPressureOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextinhubnode,  BEAM_PRESSURED, reinfPressureOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  nextintirenode, BEAM_PRESSURED, reinfPressureOptions) )

        --tire side V beams
        -- if wheel.enableTireSideVBeams ~= nil and wheel.enableTireSideVBeams == true then
        --     self:addBeamWithOptions(vehicle, 'wheels', outtirenode,    nextouthubnode,  BEAM_ANISOTROPIC, sideOptions)
        --     self:addBeamWithOptions(vehicle, 'wheels', outhubnode,     nextouttirenode, BEAM_ANISOTROPIC, sideOptions)
        --     self:addBeamWithOptions(vehicle, 'wheels', nextintirenode, inhubnode,       BEAM_ANISOTROPIC, sideOptions)
        --     self:addBeamWithOptions(vehicle, 'wheels', nextinhubnode,  intirenode,      BEAM_ANISOTROPIC, sideOptions)
        -- end

        -- Support beams
        if wheel.enableTireSideSupportBeams then
            self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, intirenode,  BEAM_SUPPORT, supportOptions)
            self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, outtirenode, BEAM_SUPPORT, supportOptions)
        end
    end

    wheel.nodes = hubNodes
    wheel.pressuredBeams = pressuredBeams
    -- wheel.treadBeams = treadBeams
end

function Vehicle:addHubWheel(vehicle, wheelKey, wheel)
    local node1   = vehicle.nodes[wheel.node1]
    local node2   = vehicle.nodes[wheel.node2]
    local nodeArm = vehicle.nodes[wheel.nodeArm]
    if node1 == nil or node2 == nil then
        logError("invalid hubWheel")
        return
    end

    local nodebase = vehicle.maxIDs.nodes

    if wheel.radius == nil then    wheel.radius = 0.5 end
    if wheel.hubRadius == nil then wheel.hubRadius = 0.65 * wheel.radius end
    if wheel.numRays == nil then wheel.numRays = 10    end

    -- add collision to the wheels nodes ;)
    wheel.collision = true

    -- fix it like this
    local node1_pos = tableToFloat3(node1.pos)
    local node2_pos = tableToFloat3(node2.pos)

    --log("n1 = " .. tostring(node1_pos) .. " , n2 = " .. tostring(node2_pos))

    local tireWidth = node1_pos:distance(node2_pos)
    local hubWidth = tireWidth
    --log("hubWheel width: "..width)

    -- swap nodes?
    if node1_pos.z > node2_pos.z then
        log("swapping hubWheel nodes ...")
        node1, node2 = node2, node1
    end

    -- calculate axis
    local axis = node2_pos - node1_pos
    local axisLength = axis:length()
    axis:normalize()

    local midpoint = (node2_pos + node1_pos) * float3(0.5, 0.5, 0.5)
    if wheel.wheelOffset ~= nil then
        local offset = wheel.wheelOffset
        midpoint = midpoint + axis * float3(offset, offset, offset)
    end

    if wheel.tireWidth ~= nil then
        tireWidth = wheel.tireWidth
        local halfWidth = 0.5 * wheel.tireWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    --log("wheel axis:" .. tostring(axis))

    local rayVec = axis:getPerpendicularVector() * float3(wheel.radius, wheel.radius, wheel.radius)
    --log("rayVector: " .. tostring(rayVec))

    local rayRot = Quaternion( (-360 / (wheel.numRays* 2)) , axis);
    --log("rayRot: " .. tostring(rayRot))

    -- add tire nodes first
    local n = 0
    local rayPoint
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)
    end

    -- add Hub nodes
    local hubNodes = {}
    local n = 0
    local hubnodebase = vehicle.maxIDs.nodes

    local hubOptions = deepcopy(wheel)
    hubOptions.beamSpring = hubOptions.hubBeamSpring or hubOptions.beamSpring
    hubOptions.beamDamp = hubOptions.hubBeamDamp or hubOptions.beamDamp 
    hubOptions.beamDeform = hubOptions.hubBeamDeform or hubOptions.beamDeform
    hubOptions.beamStrength = hubOptions.hubBeamStrength or hubOptions.beamStrength
    hubOptions.nodeWeight = hubOptions.hubNodeWeight or hubOptions.nodeWeight
    hubOptions.collision = hubOptions.hubCollision or hubOptions.collision
    hubOptions.nodeMaterial = hubOptions.hubNodeMaterial or hubOptions.nodeMaterial
    hubOptions.frictionCoef = hubOptions.hubFrictionCoef or hubOptions.frictionCoef

    rayVec = axis:getPerpendicularVector() * float3(wheel.hubRadius, wheel.hubRadius, wheel.hubRadius)

    if wheel.hubWidth ~= nil then
        hubWidth = wheel.hubWidth
        local halfWidth = 0.5 * wheel.hubWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)
    end

    -- Hub Cap
    local hubcapOptions = deepcopy(wheel)
    hubcapOptions.beamSpring = hubcapOptions.hubcapBeamSpring or hubcapOptions.beamSpring
    hubcapOptions.beamDamp = hubcapOptions.hubcapBeamDamp or hubcapOptions.beamDamp
    hubcapOptions.beamDeform = hubcapOptions.hubcapBeamDeform or hubcapOptions.beamDeform
    hubcapOptions.beamStrength = hubcapOptions.hubcapBeamStrength or hubcapOptions.beamStrength
    hubcapOptions.nodeWeight = hubcapOptions.hubcapNodeWeight or hubcapOptions.nodeWeight
    hubcapOptions.collision = hubcapOptions.hubcapCollision or hubcapOptions.collision
    hubcapOptions.nodeMaterial = hubcapOptions.hubcapNodeMaterial or hubcapOptions.nodeMaterial
    hubcapOptions.frictionCoef = hubcapOptions.hubcapFrictionCoef or hubcapOptions.frictionCoef
    hubcapOptions.group = hubcapOptions.hubcapGroup or hubcapOptions.group
    hubcapOptions.wheelID = nil

    local hubcapnodebase
    if wheel.enableHubcaps ~= nil and wheel.enableHubcaps == true and wheel.numRays%2 ~= 1 then
        local hubcapOffset
        if wheel.hubcapOffset ~= nil then
            hubcapOffset = wheel.hubcapOffset
            hubcapOffset = axis * float3(hubcapOffset, hubcapOffset, hubcapOffset)
        end

        local n = 0
        hubcapnodebase = vehicle.maxIDs.nodes

        local hubCapNumRays = wheel.numRays/2
        rayVec = axis:getPerpendicularVector() * float3(wheel.hubRadius, wheel.hubRadius, wheel.hubRadius)

        local tmpRot = Quaternion( -360 / (hubCapNumRays * 4) , axis);
        rayVec = tmpRot:multiply(rayVec)
        -- all hub node rotation
        rayRot = Quaternion( -360 / (hubCapNumRays) , axis);

        for i = 0, hubCapNumRays -1, 1 do
            local rayPoint = node1_pos + rayVec - hubcapOffset
            rayVec = rayRot:multiply(rayVec)
            n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubcapOptions)
        end

        --hubcapOptions.collision = false
        --hubcapOptions.selfCollision = false
        hubcapOptions.nodeWeight = wheel.hubcapCenterNodeWeight
        --make the center rigidifying node
        local hubcapAxis = node1_pos + axis * float3(wheel.hubcapWidth,wheel.hubcapWidth,wheel.hubcapWidth)
        n = self:addNodeWithOptions(vehicle, 'wheels', hubcapAxis, NORMALTYPE, hubcapOptions)

        --hubcapOptions.collision = nil
        --hubcapOptions.selfCollision = nil
        hubcapOptions.nodeWeight = nil
    end

    local hubcapAttachOptions = deepcopy(wheel)
    hubcapAttachOptions.beamSpring = hubcapAttachOptions.hubcapAttachBeamSpring or hubcapAttachOptions.beamSpring
    hubcapAttachOptions.beamDamp = hubcapAttachOptions.hubcapAttachBeamDamp or hubcapAttachOptions.beamDamp
    hubcapAttachOptions.beamDeform = hubcapAttachOptions.hubcapAttachBeamDeform or hubcapAttachOptions.beamDeform
    hubcapAttachOptions.beamStrength = hubcapAttachOptions.hubcapAttachBeamStrength or hubcapAttachOptions.beamStrength
    hubcapAttachOptions.breakGroup = hubcapAttachOptions.hubcapBreakGroup or hubcapAttachOptions.breakGroup
    hubcapAttachOptions.wheelID = nil

    -- hub-tire beams options
    local treadOptions = deepcopy(wheel)
    treadOptions.beamSpring      = treadOptions.wheelTreadBeamSpring or treadOptions.beamSpring
    treadOptions.beamDamp        = treadOptions.wheelTreadBeamDamp or treadOptions.beamDamp
    treadOptions.beamDeform      = treadOptions.wheelTreadBeamDeform or treadOptions.beamDeform
    treadOptions.beamStrength    = treadOptions.wheelTreadBeamStrength or treadOptions.beamStrength
    treadOptions.springExpansion = treadOptions.wheelTreadBeamSpringExpansion or treadOptions.springExpansion
    treadOptions.dampExpansion   = treadOptions.wheelTreadBeamDampExpansion or treadOptions.dampExpansion

    local enableTreadReinforcementBeams = false
    if wheel.enableTreadReinforcementBeams ~= nil and wheel.enableTreadReinforcementBeams == true then
        enableTreadReinforcementBeams = true
    end    

    local treadReinfOptions           = deepcopy(treadOptions)
    treadReinfOptions.beamSpring      = treadReinfOptions.wheelTreadReinforcementBeamSpring or treadReinfOptions.beamSpring
    treadReinfOptions.beamDamp        = treadReinfOptions.wheelTreadReinforcementBeamDamp or treadReinfOptions.beamDamp
    treadReinfOptions.beamDeform      = treadReinfOptions.wheelTreadReinforcementBeamDeform or treadReinfOptions.beamDeform
    treadReinfOptions.beamStrength    = treadReinfOptions.wheelTreadReinforcementBeamStrength or treadReinfOptions.beamStrength

    local peripheryOptions     = deepcopy(treadOptions)
    peripheryOptions.beamSpring = peripheryOptions.wheelPeripheryBeamSpring or peripheryOptions.beamSpring
    peripheryOptions.beamDamp = peripheryOptions.wheelPeripheryBeamDamp or peripheryOptions.beamDamp
    peripheryOptions.beamDeform = peripheryOptions.wheelPeripheryBeamDeform or peripheryOptions.beamDeform
    peripheryOptions.beamStrength = peripheryOptions.wheelPeripheryBeamStrength or peripheryOptions.beamStrength

    local supportOptions = deepcopy(hubOptions)
    supportOptions.beamPrecompression = (0.75 * wheel.hubRadius / wheel.radius) + 0.25

    -- Pressured Beam options
    local sideBeamLength =     wheel.radius - wheel.hubRadius
    local reinfBeamLength = math.sqrt(sideBeamLength * sideBeamLength + axisLength * axisLength)
    local pressuredOptions = deepcopy(wheel)
    pressuredOptions.pressurePSI = pressuredOptions.pressurePSI or 30
    pressuredOptions.beamSpring = pressuredOptions.pressureSpring or pressuredOptions.springExpansion
    pressuredOptions.beamDamp = pressuredOptions.pressureDamp or pressuredOptions.dampExpansion
    pressuredOptions.beamStrength = pressuredOptions.pressureStrength or pressuredOptions.beamStrength
    pressuredOptions.beamDeform = pressuredOptions.pressureDeform or pressuredOptions.beamDeform
    pressuredOptions.volumeCoef = 1 --2 * sideBeamLength / (wheel.numRays * sideBeamLength) --sideBeamLength / (wheel.numRays * (2 * sideBeamLength + 4 * reinfBeamLength))
    pressuredOptions.surface = math.pi * (wheel.radius * tireWidth + wheel.hubRadius * hubWidth) / (wheel.numRays*2)    

    local reinfPressureOptions = deepcopy(pressuredOptions)
    reinfPressureOptions.pressurePSI = reinfPressureOptions.reinforcementPressurePSI or reinfPressureOptions.pressurePSI
    reinfPressureOptions.beamSpring = reinfPressureOptions.reinforcementPressureSpring or reinfPressureOptions.pressureSpring
    reinfPressureOptions.beamDamp = reinfPressureOptions.reinforcementPressureDamp or reinfPressureOptions.pressureDamp
    reinfPressureOptions.beamStrength = reinfPressureOptions.reinforcementPressureStrength or reinfPressureOptions.pressureStrength    
    reinfPressureOptions.beamDeform = reinfPressureOptions.reinforcementPressureDeform or reinfPressureOptions.pressureDeform
    reinfPressureOptions.volumeCoef = 1 --reinfBeamLength / (wheel.numRays * (2 * sideBeamLength + 4 * reinfBeamLength))
    reinfPressureOptions.surface = math.pi * (wheel.radius*wheel.radius - wheel.hubRadius*wheel.hubRadius) / (wheel.numRays*4)

    local sideOptions = deepcopy(wheel)
    sideOptions.beamSpring   = sideOptions.wheelSideBeamSpring or 0
    sideOptions.beamDamp     = sideOptions.wheelSideBeamDamp or 0
    sideOptions.beamDeform   = sideOptions.wheelSideBeamDeform or sideOptions.beamDeform
    sideOptions.beamStrength = sideOptions.wheelSideBeamStrength or sideOptions.beamStrength
    sideOptions.springExpansion = sideOptions.wheelSideBeamSpringExpansion or sideOptions.springExpansion
    sideOptions.dampExpansion   = sideOptions.wheelSideBeamDampExpansion or sideOptions.dampExpansion

    local VDisplacement = wheel.wheelSideDisplacement or 1

    local enableVbeams = false
    if wheel.enableTireSideVBeams ~= nil and wheel.enableTireSideVBeams == true then
        enableVbeams = true
    end

    local pressuredBeams = {}
    local treadBeams = {}
    local b = 0
    for i = 0, wheel.numRays - 1, 1 do
        local i2 = 2*i
        local nextdelta = 2*((i+1)%wheel.numRays)
        local inhubnode = hubnodebase + i2
        local outhubnode = inhubnode + 1
        local nextinhubnode = hubnodebase + nextdelta
        local nextouthubnode = nextinhubnode + 1
        local intirenode = nodebase + i2
        local outtirenode = intirenode + 1
        local nextintirenode = nodebase + nextdelta
        local nextouttirenode = nextintirenode + 1

        if wheel.enableHubcaps ~= nil and wheel.enableHubcaps == true and wheel.numRays%2 ~= 1 and i < ((wheel.numRays)/2) then
            local hubcapnode = hubcapnodebase + i
            local nexthubcapnode = hubcapnodebase + ((i+1)%(wheel.numRays/2))
            local nextnexthubcapnode = hubcapnodebase + ((i+2)%(wheel.numRays/2))
            local hubcapaxisnode = hubcapnode + (wheel.numRays/2) - i
            local hubcapinhubnode = inhubnode + i2
            local nexthubcapinhubnode = hubcapinhubnode + 2
            local hubcapouthubnode = hubcapinhubnode + 1

            --hubcap periphery
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, nexthubcapnode,    NORMALTYPE, hubcapOptions)
            --attach to center node
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, hubcapaxisnode,    NORMALTYPE, hubcapOptions)

            --span beams
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, nextnexthubcapnode,    NORMALTYPE, hubcapOptions)

            --attach it
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, hubcapinhubnode,    NORMALTYPE, hubcapAttachOptions)
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, nexthubcapinhubnode,    NORMALTYPE, hubcapAttachOptions)
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, hubcapouthubnode,    BEAM_SUPPORT, hubcapAttachOptions)

            --self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, wheel.node1,    NORMALTYPE, hubcapAttachOptions)
            --self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, wheel.node2,    NORMALTYPE, hubcapAttachOptions)
        end

        --tire tread
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outtirenode,    BEAM_ANISOTROPIC, treadOptions) )
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextintirenode, BEAM_ANISOTROPIC, treadOptions) )

        -- paired treadnodes
        vehicle.nodes[intirenode].pairedNode = outtirenode
        vehicle.nodes[outtirenode].pairedNode = nextintirenode

        -- Periphery beams
        b = self:addBeamWithOptions(vehicle, 'wheels', intirenode,  nextintirenode,  NORMALTYPE, peripheryOptions)
        b = self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouttirenode, NORMALTYPE, peripheryOptions)

        --hub tread
        b = self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  outhubnode,      NORMALTYPE, hubOptions)
        b = self:addBeamWithOptions(vehicle, 'wheels', outhubnode, nextinhubnode, NORMALTYPE, hubOptions)

        --hub periphery beams
        b = self:addBeamWithOptions(vehicle, 'wheels', outhubnode, nextouthubnode, NORMALTYPE, hubOptions)
        b = self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  nextinhubnode,  NORMALTYPE, hubOptions)

        --hub axis beams
        b = self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node1, NORMALTYPE, hubOptions)
        b = self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node2, NORMALTYPE, hubOptions)
        b = self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node1, NORMALTYPE, hubOptions)
        b = self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node2, NORMALTYPE, hubOptions)

        --hub tire beams
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   intirenode,     BEAM_PRESSURED, pressuredOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  outtirenode,    BEAM_PRESSURED, pressuredOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outhubnode,     BEAM_PRESSURED, reinfPressureOptions)    )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   outtirenode,    BEAM_PRESSURED, reinfPressureOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextinhubnode,  BEAM_PRESSURED, reinfPressureOptions) )
        table.insert( pressuredBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  nextintirenode, BEAM_PRESSURED, reinfPressureOptions) )

        --tire side V beams
        if enableVbeams then
            local inhubDnode = hubnodebase + 2*((i+1-VDisplacement)%wheel.numRays)
            local outhubDnode = inhubDnode + 1
            local nextinhubDnode = hubnodebase + 2*((i+VDisplacement)%wheel.numRays)
            local nextouthubDnode = nextinhubDnode + 1
            b = self:addBeamWithOptions(vehicle, 'wheels', outtirenode,  nextouthubDnode,  BEAM_ANISOTROPIC, sideOptions)
            b = self:addBeamWithOptions(vehicle, 'wheels', outhubDnode,   nextouttirenode, BEAM_ANISOTROPIC, sideOptions)
            b = self:addBeamWithOptions(vehicle, 'wheels', nextintirenode, inhubDnode,  BEAM_ANISOTROPIC, sideOptions)
            b = self:addBeamWithOptions(vehicle, 'wheels', nextinhubDnode,  intirenode, BEAM_ANISOTROPIC, sideOptions)
        end

        if enableTreadReinforcementBeams then 
            local intirenode2 = nodebase + 2*((i+2)%wheel.numRays)
            local outtirenode2 = intirenode2 + 1
            table.insert( treadBeams,
                self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outtirenode2, NORMALTYPE, treadReinfOptions) )
            table.insert( treadBeams,
                self:addBeamWithOptions(vehicle, 'wheels', outtirenode, intirenode2, NORMALTYPE, treadReinfOptions) )
        end

        -- Support beams
        if wheel.enableTireSideSupportBeams then
            self:addBeamWithOptions(vehicle, 'wheels', wheel.node1, intirenode,  BEAM_SUPPORT, supportOptions)
            self:addBeamWithOptions(vehicle, 'wheels', wheel.node2, outtirenode, BEAM_SUPPORT, supportOptions)
        end
    end

    wheel.nodes = hubNodes
    wheel.pressuredBeams = pressuredBeams
end

function Vehicle:addPressureWheel(vehicle, wheelKey, wheel)
    local node1   = vehicle.nodes[wheel.node1]
    local node2   = vehicle.nodes[wheel.node2]
    local nodeArm = vehicle.nodes[wheel.nodeArm]

    if node1 == nil or node2 == nil then
        logError("invalid pressureWheel")
        return
    end

    local nodebase = vehicle.maxIDs.nodes

    if wheel.radius == nil then    wheel.radius = 0.5 end
    if wheel.hubRadius == nil then wheel.hubRadius = 0.65 * wheel.radius end
    if wheel.numRays == nil then wheel.numRays = 10 end

    -- add collision to the wheels nodes ;)
    wheel.collision = true

    -- fix it like this
    local node1_pos = tableToFloat3(node1.pos)
    local node2_pos = tableToFloat3(node2.pos)

    local width = node1_pos:distance(node2_pos)

    -- calculate axis
    local axis = node2_pos - node1_pos
    axis:normalize()

    local midpoint = (node2_pos + node1_pos) * float3(0.5, 0.5, 0.5)
    if wheel.wheelOffset ~= nil then
        local offset = wheel.wheelOffset
        midpoint = midpoint + axis * float3(offset, offset, offset)
    end

    midpointT = float3ToTable(midpoint)

    if wheel.tireWidth ~= nil then
        local halfWidth = 0.5 * wheel.tireWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    local rayVec = axis:getPerpendicularVector() * float3(wheel.radius, wheel.radius, wheel.radius)
    local rayRot = Quaternion( (-360 / (wheel.numRays* 2)) , axis);

    -- add nodes first
    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)

        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, wheel)
    end

    -- add Hub nodes
    local hubNodes = {}
    local n = 0
    local hubnodebase = vehicle.maxIDs.nodes

    local hubOptions = deepcopy(wheel)
    hubOptions.beamSpring = hubOptions.hubBeamSpring or hubOptions.beamSpring
    hubOptions.beamDamp = hubOptions.hubBeamDamp or hubOptions.beamDamp 
    hubOptions.beamDeform = hubOptions.hubBeamDeform or hubOptions.beamDeform
    hubOptions.beamStrength = hubOptions.hubBeamStrength or hubOptions.beamStrength
    hubOptions.nodeWeight = hubOptions.hubNodeWeight or hubOptions.nodeWeight
    hubOptions.collision = hubOptions.hubCollision or hubOptions.collision
    hubOptions.nodeMaterial = hubOptions.hubNodeMaterial or hubOptions.nodeMaterial
    hubOptions.frictionCoef = hubOptions.hubFrictionCoef or hubOptions.frictionCoef

    rayVec = axis:getPerpendicularVector() * float3(wheel.hubRadius, wheel.hubRadius, wheel.hubRadius)

    if wheel.hubWidth ~= nil then
        local halfWidth = 0.5 * wheel.hubWidth
        node1_pos = midpoint - axis * float3(halfWidth, halfWidth, halfWidth)
        node2_pos = midpoint + axis * float3(halfWidth, halfWidth, halfWidth)
    end

    local n = 0
    for i = 0, wheel.numRays - 1, 1 do
        -- inner
        rayPoint = node2_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)

        -- outer
        local rayPoint = node1_pos + rayVec
        rayVec = rayRot:multiply(rayVec)
        n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubOptions)
        table.insert(hubNodes, n)
    end
-- Hub Cap
    local hubcapOptions = deepcopy(wheel)
    hubcapOptions.beamSpring = hubcapOptions.hubcapBeamSpring or hubcapOptions.beamSpring
    hubcapOptions.beamDamp = hubcapOptions.hubcapBeamDamp or hubcapOptions.beamDamp
    hubcapOptions.beamDeform = hubcapOptions.hubcapBeamDeform or hubcapOptions.beamDeform
    hubcapOptions.beamStrength = hubcapOptions.hubcapBeamStrength or hubcapOptions.beamStrength
    hubcapOptions.nodeWeight = hubcapOptions.hubcapNodeWeight or hubcapOptions.nodeWeight
    hubcapOptions.collision = hubcapOptions.hubcapCollision or hubcapOptions.collision
    hubcapOptions.nodeMaterial = hubcapOptions.hubcapNodeMaterial or hubcapOptions.nodeMaterial
    hubcapOptions.frictionCoef = hubcapOptions.hubcapFrictionCoef or hubcapOptions.frictionCoef
    hubcapOptions.group = hubcapOptions.hubcapGroup or hubcapOptions.group
    hubcapOptions.wheelID = nil

    local hubcapnodebase
    if wheel.enableHubcaps ~= nil and wheel.enableHubcaps == true and wheel.numRays%2 ~= 1 then
        local hubcapOffset
        if wheel.hubcapOffset ~= nil then
            hubcapOffset = wheel.hubcapOffset
            hubcapOffset = axis * float3(hubcapOffset, hubcapOffset, hubcapOffset)
        end

        local n = 0
        hubcapnodebase = vehicle.maxIDs.nodes

        local hubCapNumRays = wheel.numRays/2
        rayVec = axis:getPerpendicularVector() * float3(wheel.hubRadius, wheel.hubRadius, wheel.hubRadius)

        local tmpRot = Quaternion( -360 / (hubCapNumRays * 4) , axis);
        rayVec = tmpRot:multiply(rayVec)
        -- all hub node rotation
        rayRot = Quaternion( -360 / (hubCapNumRays) , axis);

        for i = 0, hubCapNumRays -1, 1 do
            local rayPoint = node1_pos + rayVec - hubcapOffset
            rayVec = rayRot:multiply(rayVec)
            n = self:addNodeWithOptions(vehicle, 'wheels', rayPoint, NORMALTYPE, hubcapOptions)
        end

        --hubcapOptions.collision = false
        --hubcapOptions.selfCollision = false
        hubcapOptions.nodeWeight = wheel.hubcapCenterNodeWeight
        --make the center rigidifying node
        local hubcapAxis = node1_pos + axis * float3(wheel.hubcapWidth,wheel.hubcapWidth,wheel.hubcapWidth)
        n = self:addNodeWithOptions(vehicle, 'wheels', hubcapAxis, NORMALTYPE, hubcapOptions)

        --hubcapOptions.collision = nil
        --hubcapOptions.selfCollision = nil
        hubcapOptions.nodeWeight = nil
    end

    local hubcapAttachOptions = deepcopy(wheel)
    hubcapAttachOptions.beamSpring = hubcapAttachOptions.hubcapAttachBeamSpring or hubcapAttachOptions.beamSpring
    hubcapAttachOptions.beamDamp = hubcapAttachOptions.hubcapAttachBeamDamp or hubcapAttachOptions.beamDamp
    hubcapAttachOptions.beamDeform = hubcapAttachOptions.hubcapAttachBeamDeform or hubcapAttachOptions.beamDeform
    hubcapAttachOptions.beamStrength = hubcapAttachOptions.hubcapAttachBeamStrength or hubcapAttachOptions.beamStrength
    hubcapAttachOptions.breakGroup = hubcapAttachOptions.hubcapBreakGroup or hubcapAttachOptions.breakGroup
    hubcapAttachOptions.wheelID = nil

    local sideOptions = deepcopy(wheel)
    sideOptions.beamSpring   = sideOptions.wheelSideBeamSpring or 0
    sideOptions.beamDamp     = sideOptions.wheelSideBeamDamp or 0
    sideOptions.beamDeform   = sideOptions.wheelSideBeamDeform or sideOptions.beamDeform
    sideOptions.beamStrength = sideOptions.wheelSideBeamStrength or sideOptions.beamStrength
    sideOptions.springExpansion = sideOptions.wheelSideBeamSpringExpansion or sideOptions.springExpansion
    sideOptions.dampExpansion   = sideOptions.wheelSideBeamDampExpansion or sideOptions.dampExpansion

    local treadOptions = deepcopy(wheel)
    treadOptions.beamSpring      = treadOptions.wheelTreadBeamSpring or treadOptions.beamSpring
    treadOptions.beamDamp        = treadOptions.wheelTreadBeamDamp or treadOptions.beamDamp
    treadOptions.beamDeform      = treadOptions.wheelTreadBeamDeform or treadOptions.beamDeform
    treadOptions.beamStrength    = treadOptions.wheelTreadBeamStrength or treadOptions.beamStrength
    treadOptions.springExpansion = treadOptions.wheelTreadBeamSpringExpansion or treadOptions.springExpansion
    treadOptions.dampExpansion   = treadOptions.wheelTreadBeamDampExpansion or treadOptions.dampExpansion

    local peripheryOptions     = deepcopy(treadOptions)
    peripheryOptions.beamSpring = peripheryOptions.wheelPeripheryBeamSpring or peripheryOptions.beamSpring
    peripheryOptions.beamDamp = peripheryOptions.wheelPeripheryBeamDamp or peripheryOptions.beamDamp
    peripheryOptions.beamDeform = peripheryOptions.wheelPeripheryBeamDeform or peripheryOptions.beamDeform
    peripheryOptions.beamStrength = peripheryOptions.wheelPeripheryBeamStrength or peripheryOptions.beamStrength

    local sideBeams = {}
    local treadBeams = {}

    vehicle.triangles = vehicle.triangles or {}
    local pressureGroupName = '_wheelPressureGroup' .. wheel.wheelID
    local wheelPressure = wheel.pressurePSI
    local wheelDragCoef = wheel.dragCoef or 100
    local wheelTreadTriangleType = NORMALTYPE
    local wheelSide1TriangleType = NORMALTYPE
    local wheelSide2TriangleType = NORMALTYPE
    if (wheel.triangleCollision or false) == false then
        wheelTreadTriangleType = NONCOLLIDABLE
        wheelSide1TriangleType = NONCOLLIDABLE
        wheelSide2TriangleType = NONCOLLIDABLE 
    end

    if (wheel.treadTriangleCollision) == false then
        wheelTreadTriangleType = NONCOLLIDABLE
    end

    if (wheel.side1TriangleCollision) == false then
        wheelSide1TriangleType = NONCOLLIDABLE
    end

    if (wheel.side2TriangleCollision) == false then
        wheelSide2TriangleType = NONCOLLIDABLE
    end

    local function addPressTri(n1, n2, n3, dCoef, tType)
        -- local dir = triLooksTowards(vehicle.nodes[n1].pos, vehicle.nodes[n2].pos, vehicle.nodes[n3].pos, midpointT)
        -- if dir >= 0 then
            table.insert(vehicle.triangles, {
                    id1 = n1, id2 = n2, id3 = n3,
                    dragCoef = dCoef, triangleType = tType,
                    pressureGroup = pressureGroupName, pressurePSI = wheelPressure
                })
        -- else
        --     table.insert(vehicle.triangles, {
        --             id1 = n2, id2 = n1, id3 = n3,
        --             dragCoef = dCoef, triangleType = wheelTriangleType,
        --             pressureGroup = pressureGroupName, pressurePSI = wheelPressure
        --         })
        -- end
    end

    for i = 0, wheel.numRays - 1, 1 do
        local i2 = 2*i
        local nextdelta = 2*((i+1)%wheel.numRays)
        local outhubnode = hubnodebase + i2
        local inhubnode = outhubnode + 1
        local nextouthubnode = hubnodebase + nextdelta
        local nextinhubnode = nextouthubnode + 1
        local intirenode = nodebase + i2
        local outtirenode = intirenode + 1
        local nextintirenode = nodebase + nextdelta
        local nextouttirenode = nextintirenode + 1
        --tire tread
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', intirenode,  outtirenode,    BEAM_ANISOTROPIC, treadOptions) )
        table.insert( treadBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextintirenode, BEAM_ANISOTROPIC, treadOptions) )

        -- paired treadnodes
        vehicle.nodes[intirenode].pairedNode = outtirenode
        vehicle.nodes[outtirenode].pairedNode = nextintirenode

        -- Periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', intirenode,  nextintirenode,  NORMALTYPE, peripheryOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouttirenode, NORMALTYPE, peripheryOptions)
		
		-- Hub caps
		if wheel.enableHubcaps ~= nil and wheel.enableHubcaps == true and wheel.numRays%2 ~= 1 and i < ((wheel.numRays)/2) then
            local hubcapnode = hubcapnodebase + i
            local nexthubcapnode = hubcapnodebase + ((i+1)%(wheel.numRays/2))
            local nextnexthubcapnode = hubcapnodebase + ((i+2)%(wheel.numRays/2))
            local hubcapaxisnode = hubcapnode + (wheel.numRays/2) - i
            local hubcapinhubnode = inhubnode + i2
            local nexthubcapinhubnode = hubcapinhubnode + 2
            local hubcapouthubnode = hubcapinhubnode + 1

            --hubcap periphery
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, nexthubcapnode,    NORMALTYPE, hubcapOptions)
            --attach to center node
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, hubcapaxisnode,    NORMALTYPE, hubcapOptions)

            --span beams
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, nextnexthubcapnode,    NORMALTYPE, hubcapOptions)

            --attach it
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, hubcapinhubnode,    NORMALTYPE, hubcapAttachOptions)
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, nexthubcapinhubnode,    NORMALTYPE, hubcapAttachOptions)
            b = self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, hubcapouthubnode,    BEAM_SUPPORT, hubcapAttachOptions)

            --self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, wheel.node1,    NORMALTYPE, hubcapAttachOptions)
            --self:addBeamWithOptions(vehicle, 'wheels', hubcapnode, wheel.node2,    NORMALTYPE, hubcapAttachOptions)
        end
		
        --hub tread
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, inhubnode,      NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  nextouthubnode, NORMALTYPE, hubOptions)
        --hub periphery beams
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, nextouthubnode, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  nextinhubnode,  NORMALTYPE, hubOptions)

        --hub axis beams
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node1, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', outhubnode, wheel.node2, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node1, NORMALTYPE, hubOptions)
        self:addBeamWithOptions(vehicle, 'wheels', inhubnode,  wheel.node2, NORMALTYPE, hubOptions)

        --hub tire beams
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outhubnode,  outtirenode,    BEAM_ANISOTROPIC, sideOptions) )
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', outtirenode, nextouthubnode, BEAM_ANISOTROPIC, sideOptions) )
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   intirenode,     BEAM_ANISOTROPIC, sideOptions) )
        table.insert( sideBeams,
            self:addBeamWithOptions(vehicle, 'wheels', inhubnode,   nextintirenode, BEAM_ANISOTROPIC, sideOptions) )

        -- tread pressure tris
        addPressTri(intirenode, outtirenode, nextintirenode, wheelDragCoef * 0.2, wheelTreadTriangleType)
        addPressTri(nextintirenode, outtirenode, nextouttirenode, wheelDragCoef * 0.2, wheelTreadTriangleType)

        -- outside pressure tris
        addPressTri(outtirenode, outhubnode, nextouthubnode, wheelDragCoef * 0.5, wheelSide1TriangleType)
        addPressTri(outtirenode, nextouthubnode, nextouttirenode, wheelDragCoef * 0.5, wheelSide1TriangleType)        

        -- inside pressure tris
        addPressTri(inhubnode, intirenode, nextintirenode, wheelDragCoef * 0.5, wheelSide2TriangleType)
        addPressTri(nextinhubnode, inhubnode, nextintirenode, wheelDragCoef * 0.5, wheelSide2TriangleType)        
    end

    wheel.nodes = hubNodes
    wheel.sideBeams = sideBeams
    -- wheel.treadBeams = treadBeams
    wheel.pressureGroup = pressureGroupName
end

function Vehicle:optimize(vehicles)
    log("- Optimizing ...")
    for keyVehicle, vehicle in pairs (vehicles) do
        -- first: optimize beams
        if vehicle.beams == nil then
            return
        end
        for k, v in pairs(vehicle.beams) do
            if type(v) == "table" and type(v.id1) == "number" and type(v.id2) == "number" and v.id1 > v.id2 then
                -- switch
                local t = v.id1
                v.id1 = v.id2
                v.id2 = t
            end
        end
        -- then order
        --dump(vehicle.beams)
        table.sort(vehicle.beams, function(a,b)
            if a == nil or b == nil or type(a) ~= "number" or type(b) ~= "number" then
                return false
            end
            if a.id1 ~= b.id1 then
                return a.id1 < b.id1
            else
                return a.id2 < b.id2
            end
        end)

        -- update cid to match with the sorted result
        for k, v in pairs(vehicle.beams) do
            v.cid = k
        end
    end
    log("- Optimization done.")

    return true
end

function Vehicle:updateCollTris(vehicles)
    for keyVehicle, vehicle in pairs (vehicles) do
        if vehicle.beams == nil or vehicle.triangles == nil then
            goto continue
        end

        local beamIndex = {}

        for k, v in pairs(vehicle.beams) do
            if type(v) == "table" and type(v.id1) == "number" and type(v.id2) == "number" then
                local t = {v.id1, v.id2}
                table.sort(t)
                beamIndex[t[1]..'\0'..t[2]] = v
            end
        end

        for k, v in pairs(vehicle.triangles) do
            if type(v) == "table" and type(v.id1) == "number" and type(v.id2) == "number" and type(v.id3) == "number" then
                local t = {v.id1, v.id2, v.id3}
                table.sort(t)

                local beamCount = 0

                local b = t[1]..'\0'..t[2]
                if beamIndex[b] then
                    if not beamIndex[b].collTris then beamIndex[b].collTris = {} end
                    table.insert(beamIndex[b].collTris, v.cid)
                    beamCount = beamCount + 1
                end
                b = t[1]..'\0'..t[3]
                if beamIndex[b] then
                    if not beamIndex[b].collTris then beamIndex[b].collTris = {} end
                    table.insert(beamIndex[b].collTris, v.cid)
                    beamCount = beamCount + 1
                end
                b = t[2]..'\0'..t[3]
                if beamIndex[b] then
                    if not beamIndex[b].collTris then beamIndex[b].collTris = {} end
                    table.insert(beamIndex[b].collTris, v.cid)
                    beamCount = beamCount + 1
                end
                v.beamCount = beamCount
            end
        end

        ::continue::
    end
    return true
end

function Vehicle:postProcess(vehicles)
    log("- post processing ...")
    for keyVehicle, vehicle in pairs (vehicles) do

        -- not working anymore
        for k, v in pairs (vehicle.nodes) do
            --vehicle.nodes[k]['pos'] = float3(v.posX, v.posY, v.posZ)
            vehicle.nodes[k]['pos'] = {x=v.posX, y=v.posY, z=v.posZ}

            -- TODO: REMOVE AGAIN
            v.posX=nil
            v.posY=nil
            v.posZ=nil
        end

        -- Process wheels section
        if vehicle.wheels ~= nil  then
            local tmpwheels = vehicle.wheels
            vehicle.wheels = {}
            vehicle.maxIDs.wheels = nil
        end

        if vehicle.wheels == nil then vehicle.wheels = {} end

        local wheelSection = "wheels"
        if vehicle[wheelSection] ~= nil then
            for k, v in pairs (vehicle[wheelSection]) do
                --log(" * "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
                local wheelID = self:increaseMax(vehicle, 'wheels')
                v.wheelID = wheelID
                self:addWheel(vehicle, k, v)
                vehicle.wheels[wheelID] = v
            end
        end
        log(" - processed "..tableSize(vehicle[wheelSection]).." of "..wheelSection.."(s)")

        local wheelSection = "monoHubWheels"
        if vehicle[wheelSection] ~= nil then
            for k, v in pairs (vehicle[wheelSection]) do
                --log(" * "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
                local wheelID = self:increaseMax(vehicle, 'wheels')
                v.wheelID = wheelID
                self:addMonoHubWheel(vehicle, k, v)
                vehicle.wheels[wheelID] = v
            end
        end
        log(" - processed "..tableSize(vehicle[wheelSection]).." of "..wheelSection.."(s)")

        local wheelSection = "hubWheelsTSV"
        if vehicle[wheelSection] ~= nil then
            for k, v in pairs (vehicle[wheelSection]) do
                --log(" * "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
                local wheelID = self:increaseMax(vehicle, 'wheels')
                v.wheelID = wheelID
                self:addHubWheelTSV(vehicle, k, v)
                vehicle.wheels[wheelID] = v
            end
        end
        log(" - processed "..tableSize(vehicle[wheelSection]).." of "..wheelSection.."(s)")

        local wheelSection = "hubWheelsTSI"
        if vehicle[wheelSection] ~= nil then
            for k, v in pairs (vehicle[wheelSection]) do
                --log(" * "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
                local wheelID = self:increaseMax(vehicle, 'wheels')
                v.wheelID = wheelID
                self:addHubWheelTSI(vehicle, k, v)
                vehicle.wheels[wheelID] = v
            end
        end
        log(" - processed "..tableSize(vehicle[wheelSection]).." of "..wheelSection.."(s)")

        local wheelSection = "hubWheels"
        if vehicle[wheelSection] ~= nil then
            for k, v in pairs (vehicle[wheelSection]) do
                --log(" * "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
                local wheelID = self:increaseMax(vehicle, 'wheels')
                v.wheelID = wheelID
                self:addHubWheel(vehicle, k, v)
                vehicle.wheels[wheelID] = v
            end
        end
        log(" - processed "..tableSize(vehicle[wheelSection]).." of "..wheelSection.."(s)")

        local wheelSection = "pressureWheels"
        if vehicle[wheelSection] ~= nil then
            for k, v in pairs (vehicle[wheelSection]) do
                --log(" * "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
                local wheelID = self:increaseMax(vehicle, 'wheels')
                v.wheelID = wheelID
                self:addPressureWheel(vehicle, k, v)
                vehicle.wheels[wheelID] = v
            end
        end
        log(" - processed "..tableSize(vehicle[wheelSection]).." of "..wheelSection.."(s)")        

        -- Add the hydros to beams section
        local hydroCount = 0
        if vehicle.hydros ~= nil then
            for i, hydro in pairs (vehicle.hydros) do
                hydro.beamType = BEAM_HYDRO
                hydro.beam = self:addBeamWithOptions(vehicle, 'hydros', nil, nil, BEAM_HYDRO, hydro)

                if hydro.inRate == nil then hydro.inRate = 2 end
                if hydro.outRate == nil then hydro.outRate = hydro.inRate end
                if hydro.autoCenterRate == nil then hydro.autoCenterRate = hydro.inRate end
                if hydro.inLimit == nil then hydro.inLimit = 0 end
                if hydro.outLimit == nil then hydro.outLimit = 2 end
                if hydro.inputSource == nil then hydro.inputSource = "steering" end
                if hydro.inputCenter == nil then hydro.inputCenter = 0 end
                if hydro.inputInLimit == nil then hydro.inputInLimit = -1 end
                if hydro.inputOutLimit == nil then hydro.inputOutLimit = 1 end
                if hydro.inputFactor == nil then hydro.inputFactor = 1 end
                if hydro.factor ~= nil then
                    hydro.inLimit = 1 - math.abs(hydro.factor)
                    hydro.outLimit = 1 + math.abs(hydro.factor)
                    hydro.inputFactor = sign(hydro.factor)
                end
                hydro.analogue = false
                
                hydroCount = hydroCount + 1
            end
            log("- added " .. hydroCount .. " hydros")
        end

        -- Process group links
        if not self:resolveGroupLinks(vehicle) then
            logError("*** group link resolving error")
            return nil
        end

        -- post process engine differential
        if vehicle.engine ~= nil then
            if vehicle.engine.differential == nil then vehicle.engine.differential = 1 end
            if vehicle.engine.gears == nil then
                vehicle.engine.gears = {-1,0,1}
            end

            -- calculate the RPM -> Angular Velocity (AV)
            vehicle.engine.maxAV = (vehicle.engine.maxRPM or 0) * 0.1047197551
            vehicle.engine.idleRPM = math.floor(vehicle.engine.idleRPM or 0)
            vehicle.engine.maxRPM = vehicle.engine.maxRPM or 3600
            vehicle.engine.idleAV = vehicle.engine.idleRPM * 0.1047197551
            vehicle.engine.stallRPM = vehicle.engine.stallRPM or vehicle.engine.idleRPM * 0.3
            vehicle.engine.stallAV = vehicle.engine.stallRPM * 0.1047197551
            vehicle.engine.shiftDownRPM = vehicle.engine.shiftDownRPM or 0
            vehicle.engine.shiftUpRPM = vehicle.engine.shiftUpRPM or 0
            vehicle.engine.shiftDownAV = vehicle.engine.shiftDownRPM * 0.1047197551
            vehicle.engine.shiftUpAV = vehicle.engine.shiftUpRPM * 0.1047197551
            vehicle.engine.lowShiftDownAV = (vehicle.engine.lowShiftDownRPM or vehicle.engine.shiftDownRPM) * 0.1047197551
            vehicle.engine.lowShiftUpAV = (vehicle.engine.lowShiftUpRPM or vehicle.engine.shiftUpRPM) * 0.1047197551
            vehicle.engine.highShiftDownAV = (vehicle.engine.highShiftDownRPM or vehicle.engine.shiftDownRPM) * 0.1047197551
            vehicle.engine.highShiftUpAV = (vehicle.engine.highShiftUpRPM or vehicle.engine.shiftUpRPM) * 0.1047197551

            -- fix up the gears
            vehicle.engine.maxGearRatio = 0
            local revGears = 0
            local gearRatio

            for k, v in pairs (vehicle.engine.gears) do
                gearRatio = vehicle.engine.gears[k] * vehicle.engine.differential
                vehicle.engine.gears[k] = gearRatio
                vehicle.engine.maxGearRatio = math.max(vehicle.engine.maxGearRatio, gearRatio)
                if v < 0 then revGears = revGears - 1 end
            end
            vehicle.engine.revGearCount = -revGears

            -- renumber
            local newGears = {}
            local fwdGear = 1
            for k, v in pairs (vehicle.engine.gears) do
                if v > 0 then
                    newGears[fwdGear] = v
                    fwdGear = fwdGear + 1
                end
                if v < 0 then
                    newGears[revGears] = v
                    revGears = revGears + 1
                end
            end
            -- neutral
            newGears[0] = 0

            vehicle.engine.gears = newGears
            vehicle.engine.fwdGearCount = fwdGear - 1

            vehicle.engine.maxTorque = 0

            -- add the torque curve
            if vehicle.enginetorque == nil then
                vehicle.enginetorque = {
                    [0] = {rpm = 0, torque = 0},
                    {rpm = 3000, torque = 400},
                    {rpm = 6000, torque = 200}
                }
                vehicle.engine.idleRPM = 1000
                vehicle.engine.idleAV = vehicle.engine.idleRPM * 0.1047197551
                vehicle.engine.maxRPM = 6000
                vehicle.engine.maxAV = vehicle.engine.maxRPM * 0.1047197551
            end

            local points = {}
            for k,v in pairs(vehicle.enginetorque) do
                table.insert(points, {v.rpm, v.torque})
            end
            vehicle.engine.torqueCurve = CatMullRomSpline(points)

            -- calc the hp curve
            vehicle.engine.hpCurve = {}
            for k,v in pairs(vehicle.engine.torqueCurve) do
                if type(k) == "number" then
                    vehicle.engine.hpCurve[k] = (v * 0.737562149277 * k) / 5252
                    vehicle.engine.maxTorque = math.max(vehicle.engine.maxTorque, v)
                end
            end

            vehicle.engine.waterDamage = vehicle.engine.waterDamage or {}
            vehicle.engine.waterDamage.nodes = {}
            arrayConcat(vehicle.engine.waterDamage.nodes, vehicle.engine.waterDamage._group_nodes or {})
            arrayConcat(vehicle.engine.waterDamage.nodes, vehicle.engine.waterDamage._engineGroup_nodes or {})
        end

        -- Process rotators
        local wheelSection = "rotators"
        if vehicle[wheelSection] ~= nil then
            for k, v in pairs (vehicle[wheelSection]) do
                --log(" * "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
                local wheelID = self:increaseMax(vehicle, 'wheels')
                v.wheelID = wheelID
                self:addRotator(vehicle, k, v)
                vehicle.wheels[wheelID] = v
            end
        end
        local rotatorCount = tableSize(vehicle[wheelSection])
        if rotatorCount ~= 0 then
            log(" - processed "..rotatorCount.." of "..wheelSection.."(s)")
        end

        if vehicle.camerasInternal ~= nil then
            for icKey, icam in pairs (vehicle.camerasInternal) do
                local nPos = {x=icam.x, y=icam.y, z=icam.z}
                local camNodeId = self:addNodeWithOptions(vehicle, 'camerasInternal', nPos, NORMALTYPE, icam)
                self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id1, NORMALTYPE, icam)
                self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id2, NORMALTYPE, icam)
                if icam.id3 ~= nil then  self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id3, NORMALTYPE, icam) end
                if icam.id4 ~= nil then  self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id4, NORMALTYPE, icam) end
                if icam.id5 ~= nil then  self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id5, NORMALTYPE, icam) end
                if icam.id6 ~= nil then  self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id6, NORMALTYPE, icam) end
                if icam.id7 ~= nil then  self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id7, NORMALTYPE, icam) end
                if icam.id8 ~= nil then  self:addBeamWithOptions(vehicle, 'camerasInternal', camNodeId, icam.id8, NORMALTYPE, icam) end

                -- record the camera node id for the  c++ side
                vehicle.camerasInternal[icKey].camNodeID = camNodeId
            end
            log(" - processed "..tableSize(vehicle.camerasInternal).." camerasInternal")
        end

        local groupCounter = 0
        vehicle.groups = {}
        for keyEntry, entry in pairs (vehicle) do
            if type(entry) == "table" then
                for rowKey, row in pairs (entry) do
                    if type(row) == "table" then
                        local newGroups = {}
                        local firstIdx = -1
                        if row.group ~= nil and type(row.group) == "table" then
                            for keyGroup, group in pairs(row.group) do
                                if group ~= "" then
                                    if vehicle.groups[group] == nil then
                                        vehicle.groups[group] = groupCounter
                                        groupCounter = groupCounter + 1
                                    end
                                    if firstIdx == -1 then
                                        firstIdx = vehicle.groups[group]
                                    end
                                    newGroups[vehicle.groups[group]] = group
                                end
                            end
                        end
                        row.group = newGroups
                        row.firstGroup = firstIdx
                    end
                end
            end
        end
        if tableSize(vehicle.groups) > 0 then
            logDebug(" - processed "..tableSize(vehicle.groups).." groups:")
            for k, g in pairs(vehicle.groups) do
                logDebug("  - "..k.." : "..g)
            end
        end

        local scaleChanges = 0
        for keyEntry, entry in pairs (vehicle) do
            if type(entry) == "table" and tableIsDict(entry) and self.ignoreSections[keyEntry] == nil then
                scaleChanges = scaleChanges + self:scaleValuesRecursive(entry)
            end
        end
        log(" - scaled "..scaleChanges.." entries")

        -- removing disabled sections
        for keyEntry, entry in pairs (vehicle) do
            if type(entry) == "table" and tableIsDict(entry) and self.ignoreSections[keyEntry] == nil and tableIsDict(entry[0]) and entry[0]['disableSection'] ~= nil then
                log(" - removing disabled section '"..keyEntry.."'")
                vehicle[keyEntry] = nil
            end
        end

        -- add default options
        if vehicle.options.beamSpring   == nil then vehicle.options.beamSpring   = 4300000 end
        if vehicle.options.beamDeform   == nil then vehicle.options.beamDeform   = 220000 end
        if vehicle.options.beamDamp     == nil then vehicle.options.beamDamp     = 580 end
        if vehicle.options.beamStrength == nil then vehicle.options.beamStrength = math.huge end
        if vehicle.options.nodeWeight   == nil then vehicle.options.nodeWeight   = 25 end
    end
    log("- post processing done.")
    return true
end

function Vehicle:scaleValuesRecursive(data)
    local c = 0
    if type(data) == 'table' then
        for key, v in pairs(data) do
            -- look for scaling key
            if data['scale'..key] ~= nil and type(data[key]) == "number" then
                data[key] = data[key] * data['scale'..key]
                --log("scaled key "..tostring(key).." with factor "..tostring(data['scale'..key]).." to "..data[key])
                -- remove scale key
                data['scale'..key] = nil
                c = c + 1
            end
            -- look for scaling keys without any value
            if type(key) == 'string' and key ~= 'scale' and key:sub(1,5) == "scale" and data[key:sub(6)] == nil then
                --log("unused scale found: "..key)
                data[key] = nil
            end

            if type(v) == 'table' then
                c = c + self:scaleValuesRecursive(data[key])
            end
        end
    end
    return c
end


function Vehicle:increaseMax(vehicle, name)
    if vehicle.maxIDs == nil then
        vehicle.maxIDs = {}
    end
    if vehicle.maxIDs[name] == nil then
        vehicle.maxIDs[name] = 0
    end
    local res = vehicle.maxIDs[name]
    vehicle.maxIDs[name] = vehicle.maxIDs[name] + 1
    return res
end

function Vehicle:addNode(vehicle, parentSection, pos, ntype)
    return self:addNodeWithOptions(vehicle, parentSection, pos, ntype, vehicle.options)
end

function Vehicle:addNodeWithOptions(vehicle, parentSection, pos, ntype, options)
    local nextID = self:increaseMax(vehicle, 'nodes')

    local n = {}
    if options ~= nil and type(options) == 'table' then
        n = deepcopy(options)
    end

    n.cid     = nextID
    n.pos     = pos
    n.ntype   = ntype
    n.creator = parentSection

    --log("adding node "..(nextID)..".")
    table.insert(vehicle.nodes, n)
    return nextID
end

function Vehicle:addBeam(vehicle, parentSection, id1, id2)
    return self:addBeamWithOptions(vehicle, parentSection, id1, id2, NORMALTYPE, vehicle.options)
end

function Vehicle:addBeamWithOptions(vehicle, parentSection, id1, id2, beamType, options)
    if id1 == nil and options.id1 ~= nil then id1 = options.id1 end
    if id2 == nil and options.id2 ~= nil then id2 = options.id2 end

    -- check if nodes are valid
    local node1 = vehicle.nodes[id1]
    if node1 == nil then
        logError("invalid node "..tostring(id1).." for new beam between "..tostring(id1).."->"..tostring(id2))
        return
    end
    local node2 = vehicle.nodes[id2]
    if node2 == nil then
        logError("invalid node "..tostring(id2).." for new beam between "..tostring(id1).."->"..tostring(id2))
        return
    end
    if vehicle.beams == nil then
        vehicle.beams = {}
    end
    -- increase counters
    local nextID = self:increaseMax(vehicle, 'beams')

    local g = {}
    g.options = options

    local b = {}
    if options ~= nil and type(options) == 'table' then
        b = deepcopy(options)
    end

    b.cid      = nextID
    b.id1      = node1.cid
    b.id2      = node2.cid
    b.beamType = beamType
    b.creator  = parentSection
    b.spring   = beamSpring
    b.damp     = beamDamp
    b.deform   = beamDeform
    b.strength = beamStrength
    b.precompression = beamPrecompression
    -- add the beam
    table.insert(vehicle.beams, b)
    return b
end

function Vehicle:loadDirectory(directory)
    self.vehicleDirectory = directory
    if FS:directoryExists(directory)  == 0 then
        logError("error loading vehicle directory:"..directory.." / "..directory )
        return false
    else
        log("loading vehicle directory:"..directory)
        dir = FS:openDirectory(directory)
        if dir then
            local file = nil
            local jbeamFiles = {}
            repeat
                file = dir:getNextFilename()
                if not file then break end
                if string.endswith(file, ".jbeam") then
                    if FS:fileExists(directory..""..file) > 0 then
                        table.insert(jbeamFiles, directory..""..file)
                        --print("### "..tostring(file))
                    end
                end
            until not file

            --dump(jbeamFiles)

            local allParts = {}

            log("* loading jbeam files:")
            for k,v in pairs(jbeamFiles) do
                local content = readFile(v)
                if content ~= nil then
                    local state, parts = pcall(json.decode, content)
                    if state == false then
                        logError("unable to decode JSON: "..tostring(v))
                        logError("JSON decoding error: "..tostring(parts))
                        return nil
                    end
                    log("  * " .. v .. " with "..tableSize(parts).." parts")
                    allParts = tableMerge(allParts, parts)
                else
                    logError("unable to read file: "..v)
                end
            end

            -- no parts workaround :)
            if tableSize(allParts) == 1 then
                -- if there only one part, use that as main
                for partK,partV in pairs(allParts) do
                    allParts[partK].slotType = "main"
                end
            end

            --dumpTableToFile(allParts, false, "test-out.jbeamp")

            -- merge the parts
            local mainPartType = 'main'

            -- create a parts map first
            self.partMap = {}
            for partK,partV in pairs(allParts) do
                local slotType = allParts[partK].slotType
                if slotType ~= nil then
                    if self.partMap[slotType] == nil then
                        self.partMap[slotType] = {}
                    end
                    local tmpentry = {}
                    partV.partName = partK
                    table.insert(self.partMap[slotType], partV)
                else
                    logError("MISSING slotType for part: "..partK)
                end
            end

            --dumpTableToFile(self.partMap, false, "test-out.jbeamp")

            -- now, try to merge the main one

            if self.partMap[mainPartType][1] == nil then
                logError("main slot not found, unable to spawn")
                return false
            end

            self.main = self.partMap[mainPartType][1]

            log("* assembling main vehicle: " ..self.main.partName)
            
            self:assemble()

            FS:closeDirectory(dir)
            return true
        end
    end
    return false
end


function Vehicle:doPartChanges(object)
    self:assemble()
    -- force reload
    v:pushToPhysics(object, float3(0,0,0))    
end

function Vehicle:assemble()
    local partsCopy = deepcopy(self.partMap)
    local mainCopy = deepcopy(self.main)
    
    self.slotMap = self:fillSlots(partsCopy, mainCopy, 1)
    --dump(self.slotMap)
    
    -- now just load the main vehicle :)
    local vehicles_temp = {main=mainCopy}

    --dumpTableToFile(allParts, false, "/pre_compiled.txt")
    --saveCompiledJBeam(vehicles_temp, directory.."compiled.json")

    self.vehicles = self:compile(vehicles_temp)
    
    --dumpTableToFile(self.vehicles, false, directory.."post_compiled.txt")
    --log("* dumping to file: " .."post_compiled.txt")
    
    if self.vehicles == nil then
        return false
    end
end

function Vehicle:fillSlots(partMap, part, level)
    if level > 50 then
        logError("* ERROR: over 50 levels of parts, check if parts are self referential")
        return
    end
    local slotMap = newT()
    if part.slots ~= nil then
        log(string.rep(" ", level).."* found "..(#part.slots-1).." slot(s):")
        for k,v in pairs(part.slots) do
            local partType  = v[1]
            local partValue = v[2]
            local slotDescription = partType
            if table.getn(v) > 2 then
                slotDescription = v[3]
            end

            if partType == "type" then
                -- ignore header
                goto continue
            end

            log(string.rep(" ", level+1).."* found slot type "..partType)

            -- next, find all parts that match this type
            if partMap[partType] ~= nil then
                -- choose the part
                slotMap[partType] = {}
                self.slotDescriptions[partType] = slotDescription
                for k2,v2 in pairs(partMap[partType]) do
                    
                    local useThis = false
                    if self.userPartConfig[partType] then
                        useThis = (v2.partName == self.userPartConfig[partType])
                    else
                        useThis = (v2.partName == partValue)
                    end

                    local tmp = {
                        partType = partType,
                        partName = v2.partName,
                        name     = v2.information.name or "",
                        authors  = v2.information.authors or "",
                        active   = useThis,
                        level    = level + 2,
                    }
                    if useThis then
                        -- yay, part found, merge now
                        local childSlotMap = self:fillSlots(partMap, v2, level + 2)
                        if tableSize(childSlotMap) > 0 then
                            tmp['parts'] = childSlotMap
                        end
                        -- TODO: add virtual parts
                        self:unifyParts(part, v2, level + 2)
                    end
                    table.insert(slotMap[partType], tmp)
                end
            else
                logError("no suitable part found for type: "..tostring(partType))
            end
            ::continue::
        end
    else
        --log(string.rep(" ", level+1).."* no slots")
    end

    return slotMap
end

-- this is the plain include merge approach
function Vehicle:unifyParts(target, source, level)
    log(string.rep(" ", level).."* merging part "..source.partName.." ["..source.slotType.."] => "..target.partName.." ["..target.slotType.."] ... ")
    -- walk and merge all sections
    for sectionKey,section in pairs(source) do
        if sectionKey == 'slots' then
            goto continue
        end

        --log(" *** "..tostring(sectionKey).." = "..tostring(section).." ["..type(section).."] -> "..tostring(sectionKey).." = "..tostring(target[sectionKey]).." ["..type(target[sectionKey]).."]")
        if target[sectionKey] == nil then
            -- easy merge
            target[sectionKey] = section
        elseif type(target[sectionKey]) == "table" and type(section) == "table" then
            -- append to existing tables
            -- add info where this came from
            local counter = 0
            for k3,v3 in pairs(section) do
                if tonumber(k3) ~= nil then
                    -- if its an index, append if index > 1
                    if counter > 0 then
                        table.insert(target[sectionKey], v3)
                    else
                        table.insert(target[sectionKey], {partOrigin=source.partName})
                    end
                else
                    -- its a key value table, overwrite
                    target[sectionKey][k3] = v3
                end
                counter = counter + 1
            end
        else
            -- just overwrite any basic data
            if sectionKey ~= "slotType" and sectionKey ~= "partName" then
                target[sectionKey] = section
            end
        end
        ::continue::
    end
end

function Vehicle:pushToPhysics(object, pos)
    if self.vehicles == nil then
        return
    end
    for keyVehicle, vehicle in pairs (self.vehicles) do
        -- there is other metadata in there, so just look for tables and assume they are the vehicle data
        if type(vehicle) ~= 'table' then
            goto continue
        end

        log(" ** pushing vehicle to physics: ".. keyVehicle)

        self.data = vehicle

        --dump(vehicle)

        local hpo = HighPerfTimer()

        if(object == nil) then
            logError("*** Error getting Object")
            return
        end
        object:requestReset(RESET_PHYSICS)

        local addNodeByData = function(node)
            local ntype
            if node.type ~= nil then 
                ntype = node.type 
            else 
                ntype = NORMALTYPE
            end

            local collision
            if node.collision ~= nil then 
                collision = node.collision 
            else
                collision = true
            end

            local selfCollision
            if node.selfCollision ~= nil then 
                selfCollision = node.selfCollision 
            else 
                selfCollision = false
            end

            local frictionCoef
            if node.frictionCoef ~= nil then 
                frictionCoef = node.frictionCoef 
            else
                frictionCoef = 1
            end

            local nodeWeight
            if node.nodeWeight ~= nil then 
                nodeWeight = node.nodeWeight
            else
                nodeWeight = vehicle.options.nodeWeight
                node.nodeWeight = nodeWeight
            end

            local nodeMaterialTypeID
            if node.nodeMaterial ~= nil then 
                nodeMaterialTypeID = node.nodeMaterial
                if type(nodeMaterialTypeID) ~= "number" then
                    print("invalid node material id:"..tostring(nodeMaterialTypeID))
                    return
                end                
            else 
                nodeMaterialTypeID = vehicle.options.nodeMaterial
            end

            if nodeMaterialTypeID == nil then nodeMaterialTypeID = 0 end
            --print (">>> " .. tostring(node.nodeWeight) .. " | " .. tostring(vehicle.options.nodeWeight))
            -- -1 = append
            local id = object:setNode(-1, tableToFloat3(node.pos), nodeWeight, ntype, frictionCoef, node.firstGroup, selfCollision, collision)
            if nodeMaterialTypeID ~= 0 then
                --print("setting material "..nodeMaterialTypeID.." for node "..id);
                object:setNodeMaterial(id, nodeMaterialTypeID)
            end
            if node.pairedNode then
                object:setNodePair(id, node.pairedNode)
            end
        end

        -- add nodes first
        if vehicle.nodes ~= nil then
            for k, node in pairs (vehicle.nodes) do
                addNodeByData(node)
            end
            log("- added " .. object.node_count .. " nodes")
        end

        local addBeamByData = function(beam)
            -- some defaults
            beam.beamStrength = beam.beamStrength or vehicle.options.beamStrength or math.huge
            beam.beamSpring = beam.beamSpring or vehicle.options.beamSpring
            beam.beamDamp = beam.beamDamp or vehicle.options.beamDamp
            beam.beamDeform = beam.beamDeform or vehicle.options.beamDeform
            beam.beamPrecompression = beam.beamPrecompression or 1
            beam.beamType = beam.beamType or NORMALTYPE

            -- error detection
            if type(beam.id1) == "string" or type(beam.id2) == "string" and tostring(beam.optional) == "true" then
                -- ignored error
                logError("- beam not committed as node was not found: " .. tostring(beam.id1) .. " -> " .. tostring(beam.id2))
                dump(beam)
                return nil
            end

            -- -1 as beam number appends it
            local node1pos = vehicle.nodes[beam.id1].pos
            local node2pos = vehicle.nodes[beam.id2].pos

            if node1pos.x == node2pos.x and node1pos.y == node2pos.y and node1pos.z == node2pos.z then
                logError("Warning: found zero size beam")
                dump(beam)
            end

            local b = object:setBeam(-1, beam.id1, beam.id2, beam.beamStrength, beam.beamSpring, beam.beamDamp, beam.beamDeform, beam.beamPrecompression)

            if b:isValid() then
                if(beam.beamType == BEAM_ANISOTROPIC) then
                    beam.springExpansion = beam.springExpansion or beam.beamSpring
                    beam.dampExpansion = beam.dampExpansion or beam.beamDamp
                    beam.beamLongBound = beam.beamLongBound or math.huge 
                    b:makeAnisotropic(beam.springExpansion, beam.dampExpansion, beam.beamLongBound)
                elseif(beam.beamType == BEAM_BOUNDED) then
                    beam.beamLongBound = beam.beamLongBound or 1
                    beam.beamShortBound = beam.beamShortBound or 1
                    beam.beamLimitSpring = beam.beamLimitSpring or 1
                    beam.beamLimitDamp = beam.beamLimitDamp or 1
                    beam.beamDampRebound = beam.beamDampRebound or beam.beamDamp
                    beam.beamDampFast = beam.beamDampFast or beam.beamDamp
                    beam.beamDampReboundFast = beam.beamDampReboundFast or beam.beamDampRebound
                    beam.beamDampVelocitySplit = beam.beamDampVelocitySplit or math.huge
                    
                    b:makeBounded(beam.beamLongBound, beam.beamShortBound, beam.beamLimitSpring, beam.beamLimitDamp,
                                  beam.beamDampRebound, beam.beamDampFast, beam.beamDampReboundFast, beam.beamDampVelocitySplit)
                elseif(beam.beamType == BEAM_SUPPORT) then
                    beam.beamLongBound = beam.beamLongBound or 1
                    beam.springExpansion = 0
                    beam.dampExpansion = 0
                    b:makeAnisotropic(beam.springExpansion, beam.dampExpansion, beam.beamLongBound)
                elseif(beam.beamType == BEAM_PRESSURED) then
                    if beam.pressure == nil and beam.pressurePSI == nil then beam.pressurePSI = 30 end
                    beam.pressure = beam.pressure or (beam.pressurePSI * 6894.757 + 101325) -- From PSI to Pa
                    beam.pressurePSI = (beam.pressure - 101325) / 6894.757
                    beam.surface = beam.surface or 1
                    beam.volumeCoef = beam.volumeCoef or 1

                    if beam.maxPressure == nil and beam.maxPressurePSI == nil then beam.maxPressure = math.huge end
                    beam.maxPressure = beam.maxPressure or (beam.maxPressurePSI * 6894.757 + 101325)
                    beam.maxPressurePSI = (beam.maxPressure - 101325) / 6894.757
                    if beam.maxPressure < 0 then beam.maxPressure = math.huge end
                    b:makePressured(beam.pressure, beam.surface, beam.volumeCoef, beam.maxPressure)
                end

                if beam.deformationTriggerRatio ~= nil and beam.deformationTriggerRatio ~= "" then
                    b:setDeformationTriggerRatio(tonumber(beam.deformationTriggerRatio))
                end
                return b
            end
            return nil
        end

        -- then the beams
        if vehicle.beams ~= nil then
            for i, beam in pairs (vehicle.beams) do
                addBeamByData(beam)
            end
            log("- added " .. object.beam_count .. " beams")
        end

        -- wheels
        if vehicle.wheels ~= nil then
            local propulsedWheels = 0
            for wheelKey, wheel in pairs (vehicle.wheels) do
                if wheel.nodes ~= nil and next(wheel.nodes) ~= nil then
                    local w = object:setWheel(-1, wheel.node1, wheel.node2, wheel.nodeArm)
                    --dump(wheel)
                    if wheel.propulsed and wheel.propulsed > 0 then
                        propulsedWheels = propulsedWheels + 1
                    end
                    if w:isValid() and wheel.nodes then
                        for k, v in pairs(wheel.nodes) do
                            w:addNode(v)
                        end
                    end
                else
                    logError("*** wheel: "..wheelKey.." doesn't have any node bindings")
                end
            end
            if vehicle.engine ~= nil then
                vehicle.engine.propulsedWheels = propulsedWheels
            end
            log("- added ".. object.wheel_count .." wheels, "..propulsedWheels.." of them are propulsed")
        end

        -- rails
        if vehicle.rails ~= nil then
            local rail_count = 0
            local cids = {}
            for _, rail in pairs(vehicle.rails) do
                if rail["links:"] ~= nil then
                    rail_count = rail_count + 1
                    local looped = 0
                    if rail.looped == 1 or rail.looped == true then
                        looped = 1
                    end
                    if rail.capped == 0 then
                        rail.capped = false
                    end

                    rail.cid = object:addRail(looped)
                    cids[rail.cid] = rail

                    -- add links
                    local brokenmap = {}
                    if rail["broken:"] ~= nil then
                        for _, nid in pairs(rail["broken:"]) do
                            brokenmap[nid] = 1
                        end
                    end

                    local rLinks = rail["links:"]
                    local linkSize = #rLinks
                    if looped == 1 then rail.capped = false end

                    -- guard for mistaken last == 1st link
                    if looped == 1 and rLinks[1] == rLinks[linkSize] then
                        table.remove(rLinks) -- remove last link
                    end

                    for i, nid in ipairs(rLinks) do
                        local lcapped = 0
                        if rail.capped and (i == 1 or i == linkSize) then lcapped = 1 end
                        object:addRailLink(rail.cid, nid, lcapped, brokenmap[nid] or 0)
                    end
                end
            end
            vehicle.rails.cids = cids
            log("- added ".. rail_count .." rails")
        end

        -- slidenodes
        if vehicle.slidenodes ~= nil then
            local snode_count = 0
            for _, snode in pairs(vehicle.slidenodes) do
                snode_count = snode_count + 1
                local attached = 1
                if snode.attached == 0 or snode.attached == false then
                    attached = 0
                end
                local fixtorail = 1
                if snode.fixToRail == 0 or snode.fixToRail == false then
                    fixtorail = 0
                end
                local railId = -1
                if snode.railName ~= nil and vehicle.rails[snode.railName] ~= nil then
                    railId = vehicle.rails[snode.railName].cid or -1
                end

                local spring = snode.spring or vehicle.options.beamSpring
                local strength = snode.strength or math.huge

                snode.cid = object:addSlidenode(
                                snode.id, 
                                railId,
                                attached, 
                                fixtorail, 
                                snode.tolerance or 0, 
                                spring,
                                strength,
                                snode.capStrength or strength
                            )
            end
            log("- added ".. snode_count .." slidenodes")
        end

        -- props
        if vehicle.props ~= nil then
                for propKey, prop in pairs (vehicle.props) do
                        local p = object:setProp(-1, prop.mesh)
                        if p ~= nil then
                                -- now clean up the input data
                                prop.rotation        = tableToFloat3(prop.rotation):toRadians()
                                p.rotation           = prop.rotation

                                prop.translation     = tableToFloat3(prop.translation)
                                p.translation        = prop.translation

                                -- calculation of the base translation is optional
                                if prop.baseTranslation ~= nil then
                                    prop.baseTranslation = tableToFloat3(prop.baseTranslation)
                                    p.baseTranslation    = prop.baseTranslation
                                end
                                if prop.baseRotation ~= nil then
                                    prop.baseRotation = tableToFloat3(prop.baseRotation):toRadians()
                                    p.baseRotation    = prop.baseRotation
                                end

                                if prop.min == nil then prop.min = 0 end
                                if prop.max == nil then prop.max = 100 end
                                if prop.offset == nil then prop.offset = 0 end
                                if prop.multiplier == nil then prop.multiplier = 1 end

                                p.nRef = tonumber(prop.idRef)
                                p.nX   = tonumber(prop.idX)
                                p.nY   = tonumber(prop.idY)
                                prop.slotID = p.slotID

                                p:initialize()
                                if prop.mesh == "SPOTLIGHT" and p.light then
                                    -- try to set the light options then
                                    local innerAngle = prop.lightInnerAngle or 40
                                    local outerAngle = prop.lightOuterAngle or 45
                                    local brightness = prop.lightBrightness or 1
                                    local range = prop.lightRange or 10
                                    local castShadows = prop.lightCastShadows or false
                                    local flareName = prop.flareName or 'vehicleDefaultLightflare'
                                    local flareScale = prop.flareScale or 1
                                    local cookieName = prop.cookieName or ''
                                    local animationType = prop.animationType or ''
                                    local animationPeriod = prop.animationPeriod or 1
                                    local animationPhase = prop.animationPhase or 1
                                    local texSize = prop.texSize or 256
                                    local shadowSoftness = prop.shadowSoftness or 1

                                    local color = color(1, 1, 1, 1)
                                    if prop.lightColor then color = parseColor(prop.lightColor) end

                                    local attenuation = float3(0, 1, 1)
                                    if prop.lightAttenuation then attenuation = tableToFloat3(prop.lightAttenuation) end
                                    p.light:setLightArgs(innerAngle, outerAngle, brightness, range, color, float3_2_Vector3(attenuation), castShadows)
                                    p.light:setLightArgs2(flareName, flareScale, cookieName, animationType, animationPeriod, animationPhase, texSize, shadowSoftness)
                                end
                        end
                end
                log("- added ".. object.prop_count .." props")
        end

        vehicle.pressureGroups = {}
        local pressureGroupCount = 0

        -- add triangles
        if vehicle.triangles ~= nil then
            for triangleKey, triangle in pairs (vehicle.triangles) do
                if triangle.dragCoef == nil then triangle.dragCoef = 100 end
                triangle.triangleType = triangle.triangleType or NORMALTYPE

                local pressureGroup = -1
                local pressure = -1
                if triangle.pressureGroup ~= nil and triangle.pressureGroup ~= '' then
                    if vehicle.pressureGroups[triangle.pressureGroup] ~= nil then
                        pressureGroup = vehicle.pressureGroups[triangle.pressureGroup]
                    else
                        vehicle.pressureGroups[triangle.pressureGroup] = pressureGroupCount
                        pressureGroup = pressureGroupCount
                        pressureGroupCount = pressureGroupCount + 1
                    end
                    
                    if triangle.pressure ~= nil or triangle.pressurePSI ~= nil then
                        triangle.pressure = math.max(triangle.pressure or (triangle.pressurePSI * 6894.757 + 101325), 0) -- From PSI to Pa
                        triangle.pressurePSI = (triangle.pressure - 101325) / 6894.757
                        pressure = triangle.pressure
                    end
                end

                object:setCollisionTriangle(-1, triangle.id1, triangle.id2, triangle.id3, triangle.dragCoef/100, 
                    pressure, pressureGroup, triangle.triangleType, triangle.groundModel or "asphalt")
            end
            log("- added ".. object:getTriangleCount() .." collision triangles")
        end        

        -- flexbodies (must be the last thing)
        if vehicle.flexbodies ~= nil then
            for flexKey, flexbody in pairs (vehicle.flexbodies) do
                local bindingCount = table.getn(flexbody['_group_nodes'])
                if bindingCount > 0 then
                    local f = object:setFlexmesh(-1, flexbody.mesh)
                    if f ~= nil then
                        for k, v in pairs(flexbody['_group_nodes']) do
                            f:addNodeBinding(v)
                        end
                        if flexbody.pos ~= nil or flexbody.rot ~= nil or flexbody.scale ~= nil then
                            local pos = tableToFloat3(flexbody.pos) or float3(0,0,0)
                            local rot = tableToFloat3(flexbody.rot) or float3(0,0,0)
                            local scale = tableToFloat3Default(flexbody.scale, float3(1,1,1))
                            --print("setInitialTransformation: " .. flexbody.mesh .. " = " .. tostring(pos) .. ", ".. tostring(rot) .. ", " .. tostring(scale))
                            f:setInitialTransformation(pos, rot:toRadians(), scale)
                        end
                        f:initialize()
                    end
                else
                    print("flexmesh has no node bindings, ignoring: " .. flexbody.mesh)
                end
            end
            log("- added ".. object.flexmesh_count .." flexMeshes")
        end

        if vehicle.refNodes == nil then
            vehicle.refNodes = {}
        end

        if vehicle.refNodes[0] == nil then
            vehicle.refNodes[0] = {ref = 0, back = 1, left = 2, up = 0}
        end

        -- set cameras
        if vehicle.refNodes ~= nil and vehicle.refNodes[0] ~= nil then
            object:setReferenceNodes(
                  vehicle.refNodes[0].ref
                , vehicle.refNodes[0].back
                , vehicle.refNodes[0].left
                , vehicle.refNodes[0].up
                , vehicle.refNodes[0].leftCorner or vehicle.refNodes[0].ref
                , vehicle.refNodes[0].rightCorner or vehicle.refNodes[0].ref
                )
        end

        if vehicle.cameraExternal ~= nil then
            if vehicle.cameraExternal.offset == nil then vehicle.cameraExternal.offset = {x=0,y=0,z=0} end
            if vehicle.cameraExternal.distance == nil then vehicle.cameraExternal.distance = 6 end
            if vehicle.cameraExternal.distanceMin == nil then vehicle.cameraExternal.distanceMin = 1.5 end
            if vehicle.cameraExternal.fov == nil then vehicle.cameraExternal.fov = 60 end
            object:setExternalCamera(
                  vehicle.cameraExternal.offset.x
                , vehicle.cameraExternal.offset.y
                , vehicle.cameraExternal.offset.z
                , vehicle.cameraExternal.distance
                , vehicle.cameraExternal.distanceMin
                , vehicle.cameraExternal.fov
                )
        end


        -- internal cameras
        if vehicle.camerasInternal ~= nil then
            for k, v in pairs (vehicle.camerasInternal) do
                if v.fov == nil then v.fov = 75 end
                if v.camNodeID ~= nil then
                    object:addInternalCamera(v.camNodeID, v.fov)
                end
            end
            log("- added ".. object.internal_camera_count .." internal cameras")
        end

        -- end
        object:finishLoading()
        logInfo("object creation took "..hpo:stop().." ms")

        ::continue::
    end
    ::endspawn::
end

-- public interface
M.newVehicle = newVehicle

return M