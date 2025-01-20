-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

local currentVehicle = 0
local currentEngine = 0

local function hook(name, params)
    gameEngine:executeJS("HookManager.trigger('"..name.."', "..encodeJson(params)..");", 0)
end

local function updateGFX()
    --vehicleChange
    if currentVehicle ~= v.data then
        currentVehicle = v.data
        hook("VehicleChange",v.vehicleDirectory)
        hook("VehicleReset",0)
    end

    --engineChange -- replaces torquecurve-stream in near future
    if currentVehicle.engine and currentEngine ~= currentVehicle.engine then
        currentEngine = currentVehicle.engine
        hook("EngineChange",{ v.data.engine.torqueCurve, v.data.engine.hpCurve, v.data.engine.maxRPM})
        hook("VehicleReset",0)
    end
end

local function guiUpdate()
    --dump(M)
end

local function onDeserialized()
end

local function reset()
    hook("VehicleReset",0)
end


-- public interface
M.reset = reset
M.updateGFX = updateGFX
M.guiUpdate = guiUpdate
M.onDeserialized = onDeserialized

return M