-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.values = {}
local lastValues = {}
local smoothValuesExp = {}
M.disabledState = {}

local lightsState = 0

local wheelObj = -1
local wheelRadius = 0

local signalRightState = false
local signalLeftState = false
local signalWarnState = false

local blinkPulse = false
local blinkTimerThreshold = 0.4
local blinkTimer = 0

local function updateValue(func, smoothing)
    smoothing = smoothing or 0
    if M.disabledState[func] ~= nil then return nil end
    local val = nil

    if func == "steering" then
        local _, h
        for _, h in pairs (hydros.hydros) do
            if h.inputSource == "steering_input" then
                if h.steeringWheelLock and h.hydroDirState then
                    val = -h.hydroDirState * h.steeringWheelLock
                    break
                else
                    val = -h.hydroDirState
                    break
                end
            end
        end
    elseif func == "wheelspeed" and wheelObj ~= nil then
        val = math.abs(wheelObj.angularVelocity) * wheelRadius
    elseif func == "gear_M" then
        val = drivetrain.gear
    elseif func == "gear_A" then
        -- P R N D 2 1
        -- 0 1 2 3 4 5
        if drivetrain.shifterMode == 3 then
            val = drivetrain.shifterPosition + 2
        else
            val = math.min(math.max(drivetrain.gear + 2, 1), 3)
            if M.values.parkingbrake_input > 0 then val = 0 end
        end
        val = val * (1/5)
    elseif func == "driveshaft" then
      val = drivetrain.driveshaftAngle * (360 / math.pi)
    elseif func == "axle" then
      val = drivetrain.axleAngle * (360 / math.pi)
    elseif func == "rpm" and obj.wheel_count > 0 then
      val = drivetrain.rpm
    elseif func == "rpmspin" and obj.wheel_count > 0 then
      val = rpmspin
    elseif func == "clutch" then
      val = drivetrain.clutch
    elseif func == "brake" then
      val = drivetrain.brake
    elseif func == "throttle" then
      val = drivetrain.throttle
    elseif func == "parkingbrake" then
      val = M.values.parkingbrake_input
    elseif func == "abs" then
      val = drivetrain.absPulse
    elseif func == "fuel" then
      val = drivetrain.fuel / drivetrain.fuelCapacity
    elseif func == "lowfuel" then
      val = (drivetrain.fuel / drivetrain.fuelCapacity) < 0.1
    elseif func == "checkengine" then
      val = drivetrain.engineDisabled == true
    elseif func == "ignition" then
      val = drivetrain.engineDisabled == false
    elseif func == "lowpressure" then
      val = beamstate.lowpressure
    elseif func == "oiltemp" then
      -- TODO: add this
      val = 0.3
    elseif func == "watertemp" then
      -- TODO: add this
      val = 0.4
    elseif func == "turnsignal" then
        val = 0
        if signalWarnState then val = 0
        elseif signalRightState then val = 1
        elseif signalLeftState then val = -1
        end
    elseif func == "airspeed" then
        val = math.abs(obj:getVelocity():length())
    elseif func == "altitude" then
        val = obj:getPosition().z
    elseif func == "brake" then
        val = drivetrain.brake > 0
    elseif func == "parking" then
        val = 0 -- TODO: input.parkinglights
    elseif func == "signal_right_input" then
        val = signalRightState
    elseif func == "signal_left_input" then
        val = signalLeftState
    elseif func == "reverse" then
        val = drivetrain.gear < 0
    elseif func == "lowbeam" then
        val = lightsState == 1
    elseif func == "highbeam" then
        val = lightsState == 2
    elseif func == "lights" then
        val = lightsState
    elseif func == "running" then
		val = drivetrain.engineDisabled == false
    elseif func == "blinkPulse" then
        val = blinkPulse
    elseif func == "signal_L" then
        val = M.values.signal_left_input == 1 and M.values.blinkPulse == 1
    elseif func == "signal_R" then
        val = M.values.signal_right_input == 1 and M.values.blinkPulse == 1
    elseif func == "hazard" then
        val = signalWarnState and M.values.blinkPulse == 1
    elseif func == "lowhighbeam" then
        val = lightsState == 1 or lightsState == 2
    end

    if type(val) == 'boolean' then
            val = val and 1 or 0
    end

    if val == nil then
        -- logError("electrics: got nil for function "..func)
        return nil
    end

    if smoothing > 0 then
        if smoothValuesExp[func] == nil then
            smoothValuesExp[func] = newExponentialSmoothing(smoothing)
        end
        val = smoothValuesExp[func]:get(val)
    end

    M.values[func] = val
    if val ~= lastValues[func] then
        -- value changed
        material.funcChanged(func, val)
    end
    lastValues[func] = val
end

local function generateBlinkPulse(dt)
    blinkTimer = blinkTimer + dt
    if blinkTimer > blinkTimerThreshold then
        blinkPulse = not blinkPulse
        blinkTimer = blinkTimer - blinkTimerThreshold
    end
    updateValue("blinkPulse", 0)
end

local function rpmspinUpdate(dt)
    if not rpmspin then
        rpmspin = 0
    end
    rpmspin = rpmspin + (dt * drivetrain.rpm)
    if rpmspin > 360 then rpmspin = rpmspin - 360 end
end
    
local function update(dt)
    -- the primary source values
    updateValue("steering")
    updateValue("wheelspeed", 10)
    updateValue("driveshaft")
    updateValue("axle")    
    updateValue("gear_A", 10)
    updateValue("gear_M", 10)
    updateValue("rpm", 10)
    updateValue("brake")
    updateValue("throttle")
    updateValue("clutch")
    updateValue("parkingbrake")
    updateValue("lights", 10)
    updateValue("fuel", 10)
    updateValue("oiltemp", 10)
    updateValue("watertemp", 10)
    updateValue("turnsignal", 10)
    updateValue("airspeed", 10)
    updateValue("altitude", 10)
    updateValue("parking")
    updateValue("reverse")

    -- highbeam
    generateBlinkPulse(dt)
    
    rpmspinUpdate(dt)
    updateValue("rpmspin")
    
    -- and then the derived values
    updateValue("american_taillight_R")
    updateValue("american_taillight_L")
    updateValue("signal_L")
    updateValue("signal_R")
    updateValue("hazard")
    updateValue("checkengine")
    updateValue("ignition")
    updateValue("lowfuel")
    updateValue("lowpressure")
    updateValue("abs")
    updateValue("lowhighbeam")

    gui.send("electrics", M.values)
end

local function reset()
    M.disabledState = {}

    -- find wheel to get wheelspeed from
    wheelObj = nil
    wheelRadius = 0
    for wi,wd in pairs(drivetrain.wheelInfo) do
        if wd.speedo ~= nil and wd.speedo == true then
            wheelObj = obj:getWheel(wd.wheelID)
            wheelRadius = wd.radius
            break
        end
    end
end

local function beamBroke(id)
--[[
    if not v.data.props then return end
    local brokenBeamName = v.data.beams[id].name
    if not brokenBeamName then
        return
    end

    for propKey, prop in pairs (v.data.props) do
        if prop.disableBeams then
            for k,ab in pairs(prop.disableBeams) do
                if ab == brokenBeamName then
                    print("prop beam broke:"..v)
                    prop.disabled = 1
                    break
                end
            end
        end
    end
]]--
end

-- internal functions
local function signalModeChanged()
    updateValue("signal_right_input", 0)
    updateValue("signal_left_input", 0)
end

-- user input functions
local function toggle_left_signal()
    if not signalWarnState then
        signalLeftState = not signalLeftState
    else
        signalLeftState = true
    end
    if signalLeftState then
        signalRightState = false
        signalWarnState = false
    end
    signalModeChanged()
end

local function toggle_right_signal()
    if not signalWarnState then
        signalRightState = not signalRightState
    else
        signalRightState = true
    end    
    if signalRightState then
        signalLeftState = false
        signalWarnState = false
    end
    signalModeChanged()
end

local function toggle_warn_signal()
    signalWarnState = not signalWarnState
    signalRightState = signalWarnState
    signalLeftState  = signalWarnState
    signalModeChanged()
end

local function toggle_lights()
    lightsState = lightsState + 1
    if lightsState == 3 then lightsState = 0 end

    updateValue("lowbeam", 0)
    updateValue("highbeam", 0)
    updateValue("running", 0)
end

local function setLightsState(newval)
    lightsState = newval

    updateValue("lowbeam", 0)
    updateValue("highbeam", 0)
    updateValue("running", 0)
end

-- public interface
M.update = update
M.toggle_left_signal  = toggle_left_signal
M.toggle_right_signal = toggle_right_signal
M.toggle_warn_signal  = toggle_warn_signal
M.toggle_lights       = toggle_lights
M.setLightsState      = setLightsState
M.beamBroke           = beamBroke
M.reset               = reset
M.init                = reset

return M