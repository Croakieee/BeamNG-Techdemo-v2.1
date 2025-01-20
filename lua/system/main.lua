-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

-- this file is executed once on the engine lua startup

-- change default lookup path
package.path = "lua/system/?.lua;lua/?.lua;?.lua"

local STP = require "StackTracePlus"
debug.traceback = STP.stacktrace

-- setup the log level
setLogLevel(LOG_ERROR)
--setLogLevel(LOG_INFO)
--Lua:enableStackTraceFile("lua-stack.txt", false)

-- only set ground model in engine mode
require("utils")
particles = require("particles")
require("groundmodel")
console   = require("console")
gamelogic = require("gamelogic")
simpleAI  = require("simpleAI")
json      = require("json")
socket    = require("socket.socket")

--scenario  = require("scenario")

remotecontroller = nil

-- start the debugger if we enabled the sockets
--print(socket._VERSION)
--require("mobdebug").start()
--print("luasocket loaded")

-- EXPERIMENTAL remote controller
--remotecontroller = require("remotecontroller")
--remotecontroller.init()

print("system reloaded")

--scenario.init()


messageQueue = {}

function msg(txt, t, name)
    t = t or 5
    m = { txt = txt, t = t }
    if name == nil then
        table.insert(messageQueue, m)
    else
        messageQueue[name] = m
    end
end

local raceTimer = 0
local raceMode = 0
local raceRunning = 0

lastChk = -1

function abortRace()
    raceMode = 0
    raceRunning = 0
    raceTimer = 0
end

function engineEvent(what, arg1)
    --print("engineEvent("..what..","..tostring(arg1)..")")
    if what == 'timescale' then
        if arg1 == 1 then
            raceRunning = 1
        elseif arg1 > 0.00001 and arg1 < 0.99999 then
            --msg("Sorry, that is not allowed, race aborted", 10)
            abortRace()
        else
            raceRunning = 0
        end
    elseif (what == 'reset' or what == 'spawn' or what == 'despawn') and raceMode ~= 0 then
        msg("Sorry, that is not allowed, race aborted", 10)
        abortRace()
    end
end

function graphicsStep(dt)
    --print("engine - graphicsStep " .. dt )
    --gamelogic.update(dt)

    if remotecontroller then
        remotecontroller.updateGFX()
    end
    
	simpleAI.updateGFX()
    
    if raceMode ~= 0 and raceRunning == 1 then
        raceTimer = raceTimer + dt
        msg("time: " .. string.format("%0.2f",raceTimer), -1, "time")
    end
end

function onEnterSimpleRaceTrigger(triggerID, triggerName, objPID, objID, objName)
    msg("onEnterSimpleRaceTrigger: "..triggerID, 3)
    if raceMode == 1 then
        msg("last time: " .. string.format("%0.2f",raceTimer), -1, "lasttime")
    end
    raceMode = 1
    raceTimer = 0
    raceRunning = 1
end

function onEnterSimpleRaceAbortTrigger(triggerID, triggerName, objPID, objID, objName)
    msg("onEnterSimpleRaceAbortTrigger: "..triggerID, 3)
    abortRace()
end

function onEnterCheckpoint(triggerID, triggerName, objPID, objID, objName)
    print(" object " .. tostring(objPID) .. " / " .. tostring(objName) .. " [" .. tostring(objID) .. "] just entered trigger " .. tostring(triggerName) .. " [" .. tostring(triggerID) .. "]")
    
    chkNum = tonumber(string.match(triggerName, "%d+"))
    
    if chkNum == 1 and lastChk == -1 then
        msg("Race started!")
        raceTimer = 0
        lastChk = chkNum
    elseif chkNum == 5 and lastChk == 4 then
        msg(string.format("Race finished in %0.3f s", raceTimer))
        lastChk = -1
    elseif chkNum == lastChk + 1 then
        msg("Passed checkpoint "..chkNum..", head to "..(chkNum+1))
        lastChk = chkNum
    end
    

    
    --[[ 
    --example: reset the vehicle
    local b = BeamEngine:getSlot(objPID)
    if b ~= nil then
        b:queueLuaCommand("obj:requestReset(RESET_PHYSICS)")
    end
    ]]--
end

function objectBroadcast(lua)
    for i = 0, BeamEngine:getSlotCount() - 1 do
        local b = BeamEngine:getSlot(i)
        if b ~= nil then
            b:queueLuaCommand(lua)
        end
    end
end

-- set gravity on all objects
function setGravity(g)
    objectBroadcast("obj:setGravity("..g..")")
    Settings.gravity = g
end

function onLeaveCheckpoint(triggerID, triggerName, objPID, objID, objName)
    print(" object " .. tostring(objPID) .. " / " .. tostring(objName) .. " [" .. tostring(objID) .. "] just left trigger " .. tostring(triggerName) .. " [" .. tostring(triggerID) .. "]")
end

function onTickCheckpoint(triggerID, triggerName, objPID, objID, objName)
    print(" object " .. tostring(objPID) .. " / " .. tostring(objName) .. " [" .. tostring(objID) .. "] just ticked in trigger " .. tostring(triggerName) .. " [" .. tostring(triggerID) .. "]")
end


function onGasStationTick(triggerID, triggerName, objPID, objID, objName)
    local b = BeamEngine:getSlot(objPID)
    if b ~= nil then
        -- TODO
        b:queueLuaCommand("drivetrain.refill()")
    end
end
