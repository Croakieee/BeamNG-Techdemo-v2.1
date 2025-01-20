-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

local lockMult = 1
local steeringLockLimitSmoothed = 1
    
local rateMult = 1

--set initial rates (derive these from the menu options eventually)
--local kbdInRate = 6
--local kbdOutRate = 3
--local kbdAutoCenterRate = 2.0

local kbdInRate = 5.0
local kbdOutRate = 2.5
local kbdAutoCenterRate = 1.5

local padInRate = 10.0
local padOutRate = 5.0

M.keys = {} -- TODO: REMOVE
M.rawDevices = {}
M.raw = {}
M.state = {}

M.enableDynamicSteering = true

M.VALUETYPE_KEYBD  = 0
M.VALUETYPE_PAD    = 1
M.VALUETYPE_DIRECT = 2

local function toggleDynamicSteering()
    M.enableDynamicSteering = not M.enableDynamicSteering
    if M.enableDynamicSteering then
        print("Dynamic Steering is now enabled")
    else
        print("Dynamic Steering is now disabled")
    end
end

local function init()
    if M.enableDynamicSteering == true then
        --create smoothers
        if steerSmoothing == nil then
            steerSmoothing = newExponentialSmoothing(5)
        end
        if slidingSmoothing == nil then
            slidingSmoothing = newExponentialSmoothing(5)
        end
        if steeringLockLimitSmoothing == nil then
            steeringLockLimitSmoothing = newExponentialSmoothing(5)
        end
        for _, h in pairs (hydros.hydros) do
            --check if it's a steering hydro
            if h.inputSource == "steering_input" then
                --compensation for different turning radii
                if h.lockDegrees then
                    lockMult = (35/h.lockDegrees)
                    break
                end
            end
        end
    end
    
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
            smootherKBD = newSteerSmoothing(0),
            smootherPAD = newTemporalSmoothingNonLinear(padInRate * rateMult, padOutRate * rateMult, nil, 0), 
            minLimit = -1, maxLimit = 1, binding = "steering" },
        axisy0 = { val = 0, inputType = 0, 
            smootherKBD = newPedalSmoothing(1, 0.1, 310, 310, 0.8, 0),
            smootherPAD = newTemporalSmoothing(10, 10, nil, 0),
            minLimit =  0, maxLimit = 1, binding = "throttle" },
        axisy1 = { val = 0, inputType = 0,
            smootherKBD = newPedalSmoothing(1, 0.05, 310, 580, 0.8, 0),
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

local function dynamicSteering(e, dt)
	local tmp
	local slidingRate = 1
	local lockAdd = 1
	--get speed
	local airSpeed = math.abs(obj:getVelocity():length())
	--roughly tuned to reduce lock with speed but still allow steering past slip limit

	local w3slip = 0
	local w4slip = 0
	
	if drivetrain.wheelInfo[2] then
		w3slip = drivetrain.wheelInfo[2].lastSlip
	end
	
	if drivetrain.wheelInfo[3] then
		w4slip = drivetrain.wheelInfo[3].lastSlip
	end
	
	--check how much it's sliding
	local sliding = math.abs((w3slip + w4slip)/2)
	--smooth the inherently unstable sliding value
	sliding = slidingSmoothing:get(sliding)


	--counter steer special case - increase lock with rear wheel slip
	if sliding > 7 then
		sliding = sliding - 7
		lockAdd = math.min(2, ( 1 +((dt * sliding) * 10)))
		slidingRate = math.min(2, (1 + ((dt * sliding) * 10)))
		--print(sliding .. " " .. lockAdd .. " " .. slidingRate)
	end
	
	local steeringLockLimit = math.abs(225/((airSpeed + 1) * (airSpeed + 1))) * lockAdd
	
	rateMult = (0.5/steeringLockLimit) + 1
	
	--print(rateMult)

	tmp = e.smootherKBD:get(e.val, dt, kbdInRate * rateMult * slidingRate, kbdOutRate * rateMult * slidingRate, kbdAutoCenterRate * slidingRate)

	
	--limits
	if steeringLockLimit < 0.25 then steeringLockLimit = 0.25 end
	--multiply it to compensate for different front wheel turn degrees
	--steeringLockLimit = steeringLockLimit * lockMult
	if steeringLockLimit > 1 then steeringLockLimit = 1 end
	
	--smooth the limit otherwise it jerks violently
	steeringLockLimitSmoothed = steeringLockLimitSmoothing:get(steeringLockLimit)
	
	--limit the smoothed value
	if steeringLockLimitSmoothed < 0.25 then steeringLockLimitSmoothed = 0.25 end
	if steeringLockLimitSmoothed > 1 then steeringLockLimitSmoothed = 1 end
	
	--scale the steering
	tmp = tmp * steeringLockLimitSmoothed
	
	--smooth the final value
	tmp = steerSmoothing:get(tmp)
	
	return tmp
end

local function update(dt)
    -- map the values
    for k, e in pairs(M.state) do
        local tmp = 0
        if e.inputType == M.VALUETYPE_DIRECT then
            -- steering wheel
            tmp = e.val
        elseif e.inputType == M.VALUETYPE_PAD then
            -- joystick / game controller - smoothing without autocentering
            --get the value
            tmp = e.smootherPAD:get(e.val, dt)
            --and for pads
            if k == "axisx0" and M.enableDynamicSteering == true then
                tmp = dynamicSteering(e, dt)
            end
        else -- VALUETYPE_KEYBD
            -- digital - smoothing with autocenter
            --get the value
            if k == "axisx0" and M.enableDynamicSteering == true then
                tmp = dynamicSteering(e, dt)
            else
                tmp = e.smootherKBD:get(e.val, dt, kbdInRate * rateMult, kbdOutRate * rateMult, kbdAutoCenterRate)
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
    
    --[[
    if bdebug.mode == 10 then
        -- we are currently in beam debug mode, what coincidence ;)
        canvas.inputInfoText = "Thanks, but this features is not implemented yet."
        -- TODO: WIP
    end
    ]]--
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
M.toggleDynamicSteering = toggleDynamicSteering
M.event = event
M.toggleEvent = toggleEvent

return M