-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

package.path = "lua/vehicle/?.lua;lua/?.lua;?.lua"
require("utils")

-- improve stacktraces
local STP = require "StackTracePlus"
debug.traceback = STP.stacktrace

function init(path)
    if not obj then logError("Error getting main object: unable to spawn") ; return end

    -- we change the lookup path here, so it prefers the vehicle lua
    package.path = path .. "/lua/?.lua;lua/vehicle/?.lua;lua/?.lua;?.lua"
    extensions = require("extensions")
    extensions.loadModules(path.."/lua")
    drivetrain = require("drivetrain")
    sounds     = require("sounds")
    bdebug     = require("bdebug")
    input      = require("input")
    props      = require("props")
    beamng     = require("beamng")
    particlefilter = require("particlefilter")
    particles  = require("particles")
    material   = require("material")
    electrics  = require("electrics")
    json       = require("json")
    beamstate  = require("beamstate")
    sensors    = require("sensors")
    bullettime = require("bullettime")
    thrusters  = require("thrusters")
    hydros     = require("hydros")
    gui        = require("gui") -- do not change its name, the GUI callback will break otherwise
    partmgmt   = require("partmgmt") -- do not change its name, the GUI callback will break otherwise
    streams    = require("guistreams")
    hooks      = require("guihooks")
    outgauge   = require("outgauge")
    --outsim     = require("outsim")

    v = beamng.newVehicle()
    v['_noSerialize'] = true

    local hp = HighPerfTimer()
    -- load jbeam file
    if not v:loadDirectory(path) then
        return
    end

    --v:showPartsGUI()

    -- you can change the data in here before it gets submitted to the physics
    -- submit to physics
    v:pushToPhysics(obj, float3(0,0,0))

    if v.data == nil then
        v.data = {}
    end

    initSystems()

    -- temporary camera settings
    obj.camRelaxation = 3

    -- temporary tire mark setting
    obj.slipTireMarkThreshold = 25
    logInfo("vehicle loading took "..hp:stop()..' ms')
end

function initSystems()
    material.init()
    drivetrain.init()
    sensors.reset()
    beamstate.init()
    thrusters.init()
    hydros.init()
    input.init()
    sounds.init()
    props.init()
    electrics.init()
    outgauge.init()
    --outsim.init()

    extensions.hook('init')
end

local colnum = 0

-- This is called in the global scope, so it is safe to do things that contact things outside the vehicle
function graphicsStep(dt)
    input.update(dt) -- must come first ;)
    drivetrain.updateEngine(dt)
    electrics.update(dt)
    props.update()
    beamstate.updateGFX()
    bullettime.update(dt)
    outgauge.updateGFX(dt)
    --outsim.updateGFX(dt)
    extensions.hook('updateGFX', dt)
    hooks.updateGFX()
end

-- This is called in the local scope, so it is NOT safe to do things that contact things outside the vehicle
-- It is called right after graphicsStep
function graphicsStepLocal(dt)
    sounds.update(dt)
    hydros.updateGFX(dt)
    sensors.updateGFX(dt)
    thrusters.updateGFX()
    streams.updateGFX()    
    gui.updateGFX(dt)
    drivetrain.wheelSlipGFXreset()
end


-- step functions
function physicsStep(dts)
    drivetrain.updateWheels(dts)
    sensors.update()
    thrusters.update()
    hydros.update(dts)
end

-- debug
function debugDraw()
    bdebug.draw()
end

-- various callbacks
function beamBroken(id, energy)
    beamstate.beamBroken(id, energy)
    --bullettime.slowMotion(0.05, 20) -- 20% of realtime
end

function beamDeformed(id, ratio)
    beamstate.beamDeformed(id, ratio)
end

-- called when everything was cleared
function vehicleDestroy()
    --print("vehicleDestroy()")
    -- when the vehicle gets unloaded, remove all sounds
    sounds.destroy()
    material.destroy()

    -- car emptied, v:destyoyed() might reload it with different parts
    if partmgmt:destroyed() then
        -- make sure the things init correctly
        initSystems()
    end
end

-- called when the user pressed I
function vehicleResetted(retainDebug)
    --print("vehicleResetted()")
    drivetrain.reset()
    props.reset()
    sensors.reset()
    if not retainDebug then
        bdebug.reset()
    end
    bullettime.reset()
    beamstate.reset()
    thrusters.reset()
    input.reset()
    hydros.reset()
    material.reset()
    electrics.reset()
    hooks.reset()
    extensions.hook('reset', dt)
end

function particleEmitted(p)
    drivetrain.updateWheelSlip(p)
    particlefilter.particleEmitted(p)
end

function activated(mode)
    --[[
    if mode == 1 then
        print("yay, we got active")
    else
        print("deactivated :(")
    end
    ]]--
    gui.activated(mode)
    bdebug.activated(mode)
end

function instabilityDetected()
    -- enable break debug, so we see what beams broke
    local m = "instability detected for vehicle " .. tostring(v.vehicleDirectory) .. ": enabling beam break debug, reseting the vehicle and disabling the physics."
    print(m)
    gui.message(m, 60, 'instability')
    BeamEngine:setEnabled(false)
    obj:requestReset(RESET_PHYSICS)
end

function exportPersistentData()
    local s = serializeModules()
    --print("exportPersistentData(): " .. s)
    obj:setPersistentData(s)
    --[[
    v.userPartConfig.guiMode = 0
    local data = {
        fuel = drivetrain.fuel,
        shifterMode = drivetrain.shifterMode,
        userPartConfig = v.userPartConfig,
        modules = serializeableModules(),
    }
    v.userPartConfig.guiMode = nil
    s = serialize(data)
    --print("setPersistentData("..s..")")
    obj:setPersistentData(s)
    ]]--
end

function importPersistentData(s)
    --print("importPersistentData("..s..")")
    --drivetrain.fuel = data.fuel
    --drivetrain.setShifterMode(data.shifterMode)

    deserializeModules(unserialize(s))
    
    --if data.userPartConfig ~= nil and data.userPartConfig ~= {} then
    --    partmgmt.setConfig(data.userPartConfig)
    --end
end

function guiUpdate(d)
    --print("guiUpdate()")
    --dump(d)
    gui.gotUpdate(d)
end