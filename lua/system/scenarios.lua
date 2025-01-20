-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

local scenarios = {}
local directory = "scenarios"

local function loadScenarios()
    if FS:directoryExists(directory)  == 0 then
        logError("error loading scenarios directory: "..directory.." / "..directory )
        return false
    else
        logInfo("loading scenarios directory: "..directory)
        dir = FS:openDirectory(directory)
        if dir then
            local file = nil
            local files = {}
            repeat
                file = dir:getNextFilename()
                if not file then break end
                if string.find(file, ".bsc") then
                    if FS:fileExists(directory.."/"..file) > 0 then
                        table.insert(files, directory.."/"..file)
                    end
                end
            until not file

            scenarios = {}
            logInfo("* loading scenario files:")
            
            for k,fn in pairs(files) do
                local scenario  = require(fn)
                scenario.init()
                table.insert(scenarios, scenario)
            end
            
            FS:closeDirectory(dir)
            return true
        end
    end
    return false
end

local function init()
    loadScenarios()
end


-- public interface
M.init = init

return M