-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

-- this is the main test file

rerequire("lua/tests/benchphysics")


--rerequire("lua/tests/simpleload")


function loadOneVehicle()
    BeamEngine:deleteAllObjects()
    BeamEngine:spawnObject("vehicles/pickup", float3(0, 0, 0))
end

function benchJSON()
    directory = "vehicles/pickup"
    dir = FS:openDirectory(directory)
    if dir then
        local file = nil
        local jbeamFiles = {}
        repeat
            file = dir:getNextFilename()
            if not file then break end
            if string.find(file, ".jbeam") and not string.find(file, ".jbeamc") then
                if FS:fileExists(directory.."/"..file) > 0 then
                    table.insert(jbeamFiles, directory.."/"..file)
                end
            end
        until not file

        local allParts = {}

        logInfo("* loading jbeam files:")
        for k,v in pairs(jbeamFiles) do
            local content = readFile(v)
            if content ~= nil then
                local state, parts = pcall(json.decode, content)
                if state == false then
                    logError("unable to decode JSON: "..v)
                    logError("JSON decoding error: "..parts)
                    return nil
                end
                logInfo("  * " .. v .. " with "..tableSize(parts).." parts")
                allParts = tableMerge(allParts, parts)
            else
                logError("unable to read file: "..v)
            end
        end
        FS:closeDirectory(dir)
    end
end

--loadOneVehicle()