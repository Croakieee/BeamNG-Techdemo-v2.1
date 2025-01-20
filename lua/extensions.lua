-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

local luaMods = {}
local luaModFunctions = {}

local function loadModules(directory)
    luaMods = {}
    local dir = FS:openDirectory(directory)
    if dir then
        -- find the lua module files now
        local file = nil
        local luaFiles = {}
        repeat
            file = dir:getNextFilename()
            if not file then break end
            if string.find(file, ".lua") then
                if FS:fileExists(directory.."/"..file) > 0 then
                    table.insert(luaFiles, file:sub(1,-5))
                end
            end
        until not file
        FS:closeDirectory(dir)

        -- then load them
        for _,v in pairs(luaFiles) do
            logInfo("loading Lua mod: " .. v)
            luaMods[v] = require(v)
            
            -- also add to global scope:
            _G[v] = luaMods[v]

            --[[
            -- this ignores error mods and does not load them, not used atm
            local ok, m = pcall(require, v)
            if ok then
                luaMods[v] = m
            end
            ]]--
        end

        -- create function tables
        luaModFunctions = {}
        for k,v in pairs(luaMods) do
            for k2,v2 in pairs(v) do
                if type(v2) == 'function' then
                    if luaModFunctions[k2] == nil then luaModFunctions[k2] = {} end
                    table.insert(luaModFunctions[k2], v2)
                end 
            end
        end
    end
end

local function hook(func, ...)
    if luaModFunctions[func] == nil then return end -- no consumers then

    local args = unpack({...})
    for _,v in pairs(luaModFunctions[func]) do
        v(args)
    end
end

-- public interface
M.loadModules = loadModules
M.hook = hook

return M