-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.wantedSimulationSpeed = 100

M.simulationSpeed = 100
local simulationSpeed_smooth = newExponentialSmoothing(20)
local bulletTime = 0
M.bulletMode = 0 -- 1 = auto, with timer, 0 = disabled, 2 = manual
M.maxBulletTime = 10


local bulletTimeSlotLength = 5
local bulletTimeSlots = {1, 12.5, 25, 50, 100}
local instantSlowmoSlot = 2

M.selectionSlot = bulletTimeSlotLength

local function update(dt)
    if M.bulletMode == 0 then return end
    
    local currentSpeedPercent = simulationSpeed_smooth:get(M.simulationSpeed)
    --print(">>" .. currentSpeedPercent)

    local cv = currentSpeedPercent * 0.01
    BeamEngine:setSimulationTimeScale(cv) -- 0-100 --> 0-1
    
    if M.bulletMode == 1 and bulletTime > 0 then
        bulletTime = bulletTime - dt
        if bulletTime <= 0 then
            simulationSpeed_smooth = newExponentialSmoothing(20, M.simulationSpeed)
            M.simulationSpeed = 100
        end
    end
end

local function reportSpeed()
    if M.simulationSpeed > 99.9 then
        gui.message("Realtime", 5, "bullettime")
    else
        local t = 100 / M.simulationSpeed
        if t ~= math.floor(t) then
            t = string.format("%.1f", 100 / M.simulationSpeed)
        end

        gui.message(t .. " times slower than realtime", 5, "bullettime")
    end
end

local function selectPreset(val)
    if val == "^" then
        M.selectionSlot = bulletTimeSlotLength
    elseif val == "v" then
        M.selectionSlot = instantSlowmoSlot
    elseif val == "<" then
        M.selectionSlot = M.selectionSlot - 1
        if M.selectionSlot < 1 then
            M.selectionSlot = 1
        end
    elseif val == ">" then
        M.selectionSlot = M.selectionSlot + 1
        if M.selectionSlot > bulletTimeSlotLength then
            M.selectionSlot = bulletTimeSlotLength
        end
    end
    --print("bullettime preset " .. M.selectionSlot .. " = " .. tostring(bulletTimeSlots[M.selectionSlot]))
    M.simulationSpeed = bulletTimeSlots[M.selectionSlot]
    M.bulletMode = 2
    reportSpeed()
end

local function set(val)
    if type(val) ~= "number" then
        return
    end
    M.simulationSpeed = 100/val
    
    if M.simulationSpeed < 0.00001 then
        M.simulationSpeed = 0.00001
    elseif M.simulationSpeed > 100 then
        M.simulationSpeed = 100
    end
    M.bulletMode = 2
    reportSpeed()
end

local function slowMotion(slowdownTime, slowDownPercent)
    M.bulletMode = 1
    -- slowDownPercent given from 0 to 100, convert from 0 to 1
    if bulletTime <= 0 then
        M.simulationSpeed = slowDownPercent
        simulationSpeed_smooth = newExponentialSmoothing(20, slowDownPercent)
        bulletTime = slowdownTime * slowDownPercent
    else
        bulletTime = bulletTime + slowdownTime
    end
    
    -- max bullettime
    if bulletTime > M.maxBulletTime then
        bulletTime = M.maxBulletTime
    end
end

local function reset()
    --bulletTime = 0
    --M.bulletMode = 0
    --M.simulationSpeed = 100
    --M.selectionSlot = bulletTimeSlotLength
    --simulationSpeed_smooth = newExponentialSmoothing(20, M.simulationSpeed)
    --BeamEngine:setSimulationTimeScale(1)
end

local function guiUpdate()
    set(tonumber(M.wantedSimulationSpeed))
end

local function onDeserialized()
    print("bullettime.onDeserialized: ".. M.simulationSpeed)
    simulationSpeed_smooth = newExponentialSmoothing(20, M.simulationSpeed)
end


-- public interface
M.update = update
M.reset = reset
M.set = set
M.selectPreset = selectPreset
M.slowMotion = slowMotion
M.guiUpdate = guiUpdate
M.onDeserialized = onDeserialized

return M