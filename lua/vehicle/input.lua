-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.keys = {} -- TODO: REMOVE
M.rawDevices = {}
M.raw = {}
M.state = {}

M.VALUETYPE_KEYBD  = 0
M.VALUETYPE_PAD    = 1
M.VALUETYPE_DIRECT = 2

-- legacy support for the console (initial values)
M.parkingbrake = 0

local rateMult = nil

--set initial rates (derive these from the menu options eventually)
local kbdInRate = 4.0
local kbdOutRate = 2.0
local kbdAutoCenterRate = 2.0

local padInRate = 3.0
local padOutRate = 2.0

local function init()
    --scale rates based on steering wheel degrees
    if hydros then
        for _, h in pairs (hydros.hydros) do
            --check if it's a steering hydro
            if h.inputSource == "steering_input" then
                --if the value is present, scale the values
                if h.steeringWheelLock then
                    rateMult = 450 / math.abs(h.steeringWheelLock)
                    break
                end
            end
        end
    end

    if rateMult == nil then
        rateMult = 5/8
    end

    --inRate (towards the center), outRate (away from the center), autoCenterRate, startingValue
    M.state = { 
        axisx0 = { val = 0, inputType = 0, 
            smootherKBD = newTemporalSmoothing(kbdInRate * rateMult, kbdOutRate * rateMult, kbdAutoCenterRate * rateMult, 0), 
            smootherPAD = newTemporalSmoothingNonLinear(padInRate * rateMult, padOutRate * rateMult, nil, 0), 
            minLimit = -1, maxLimit = 1, binding = "steering" },
        axisy0 = { val = 0, inputType = 0, 
            smootherKBD = newTemporalSmoothing(3, 3, 5, 0), 
            smootherPAD = newTemporalSmoothing(10, 10, nil, 0), 
            minLimit =  0, maxLimit = 1, binding = "throttle" },
        axisy1 = { val = 0, inputType = 0, 
            smootherKBD = newTemporalSmoothing(3, 3, 5, 0), 
            smootherPAD = newTemporalSmoothing(10, 10, nil, 0), 
            minLimit =  0, maxLimit = 1, binding = "brake" },
        axisy2 = { val = 0, inputType = 0, 
            smootherKBD = newTemporalSmoothing(3, 3, 5, 0), 
            smootherPAD = newTemporalSmoothing(10, 10, nil, 0), 
            minLimit =  0, maxLimit = 1, binding = "parkingbrake" },
        axisy3 = { val = 0, inputType = 0, 
            smootherKBD = newTemporalSmoothing(3, 3, 5, 0), 
            smootherPAD = newTemporalSmoothing(10, 10, nil, 0), 
            minLimit =  0, maxLimit = 1, binding = "clutch" },
        }
end

local function update(dt)
    -- map the values
    for k, e in pairs(M.state) do
        local tmp = 0
        if e.inputType == M.VALUETYPE_DIRECT then
            tmp = e.val
        else
            if e.inputType == M.VALUETYPE_PAD then
                -- joystick / game controller - smoothing without autocentering
                tmp = e.smootherPAD:get(e.val, dt)
            else -- VALUETYPE_KEYBD
                -- digital - smoothing with autocenter
                tmp = e.smootherKBD:get(e.val, dt)
            end
        end

        tmp = math.min(math.max(tmp, e.minLimit), e.maxLimit)
        M[e.binding] = tmp
        electrics.values[e.binding..'_input'] = tmp
    end
end

-- deviceInst : Device instance: joystick0, joystick1, etc
-- fValue : Value typically ranges from -1.0 to 1.0, but doesn't have to. - It depends on the context.
-- fValue2, fValue3, fValue4 : Extended float values (often used for absolute rotation Quat)
-- iValue : Signed integer value
-- action : InputActionType
-- deviceType : InputDeviceTypes
-- objType : InputEventType
-- objInst : InputObjectInstances
-- ascii : ASCII character code if this is a keyboard event.
-- modifier : Modifiers to action: SI_LSHIFT, SI_LCTRL, etc.
local function processRawEvent(deviceInst, fValue, fValue2, fValue3, fValue4, iValue, action, deviceType, objType, objInst, ascii, modifier)
    --print("InputEvent("..deviceInst..", "..fValue..", "..fValue2..", "..fValue3..", "..fValue4..", "..iValue..", "..action..", "..deviceType..", "..objType..", "..objInst..", "..ascii..", "..modifier..")")
    
    local dev = deviceType..deviceInst
    
    if M.raw[dev] == nil then M.raw[dev] = {} end
    if M.raw[dev][objType] == nil then M.raw[dev][objType] = {} end
    if M.raw[dev][objType][objInst] == nil then M.raw[dev][objType][objInst] = {} end
    
    
    local d = M.raw[dev][objType][objInst]
    
    d.fValue  = fValue
    d.fValue2 = fValue2
    d.fValue3 = fValue3
    d.fValue4 = fValue4
    d.iValue  = iValue
    d.action  = action
    
    --dump(M.raw)
end

local function mapsReloaded()
    --print "input maps were reloaded:"
    dump(M.rawDevices)
end

local function reset()
    M.raw = {}
    for k, e in pairs(M.state) do
        e.smootherKBD:reset()
        e.smootherPAD:reset()
    end
end

local function event(itype, ivalue, inputType)
    --print("input.event("..tostring(itype)..","..tostring(ivalue)..","..tostring(inputType)..")")
    if M.state[itype] == nil then
        -- some default values
        M.state[itype] = {
            smootherKBD = newTemporalSmoothing(3, 3, 5, 0), 
            smootherPAD = newTemporalSmoothing(10, 10, nil, 0), 
            minLimit =  0, maxLimit = 1, binding = itype
        }
    end
    M.state[itype].val = ivalue
    M.state[itype].inputType = inputType
end

local function toggleEvent(itype, ivalue, inputType)
    --print("input.toggleEvent("..tostring(itype)..","..tostring(ivalue)..","..tostring(inputType)..")")
    if ivalue == 0 then return end
    if M.state[itype] ~= nil and M.state[itype].val > 0.5 then
        M.state[itype].val = 0
        M.state[itype].inputType = 0
    else
        M.state[itype].val = 1
        M.state[itype].inputType = 0
    end
end


local function toggleParkingbrake()
    if M.parkingbrakeInput < 0.01 then
        M.parkingbrakeInput = 1
    elseif M.parkingbrakeInput > 0.99 then
        M.parkingbrakeInput = 0
    end
end


-- public interface
M.update = update
M.init = init
M.reset = reset
M.toggleParkingbrake = toggleParkingbrake
M.processRawEvent = processRawEvent
M.mapsReloaded = mapsReloaded
M.event = event
M.toggleEvent = toggleEvent

return M