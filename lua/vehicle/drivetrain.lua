-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M._serialize = {
    differentialMode = true,
    manualShift = true,
    autoClutch = true,
    shifterMode = true,
    activeModeIndex = true
}

M.torque = 0
M.gear = 0
M.rpm = 0
M.torqueTransmission = 0
M.brake = 0
M.throttle = 0
M.wheels = {}
M.wheelInfo = {}
M.engineDisabled = false
M.engineIgnition = true
M.absPulse = 0
M.fuelLeakRate = 0 -- L/sec
M.fuel = 100
M.fuelCapacity = 100

-- shifterMode = 0 : full manual
-- shifterMode = 1 : manual with automatic clutch
-- shifterMode = 2 : simple automatic
-- shifterMode = 3 : real automatic
M.shifterMode = 2 -- initial value needs to fit to the two modes below
M.differentialMode = 0
M.autoClutch = true
M.manualShift = false
M.shifterPosition = 0
M.wheelCount = 0
M.avgAV = 0
M.axleAngle = 0
M.driveshaftAngle = 0
M.clutch = 1
M.activeModeIndex = 1

local diffs = {}
local diffCount = 1
local diffTypeMap = {open = 0, lsd = 1}
local diffStateMap = {open = 0, closed = 1, locked = 2}
local avgDiffAV = 0
local invDiffCount = 1
local invWheelCount = 0
local propWheelsCount = 0
local engInertia = 0.1
local invEngInertia = 10
local halfInvEngInertia = invEngInertia * 0.5
local engAV = 0
local axleAV = 0
local engFriction = 20
local brakingCoef = 0
local axleFriction = 50
local clutchTimer = 0
local clutchDuration = 0.5
local clutchRatio = 1
local clutchTorque = 0
local invClutchDuration = 2
local viscousCoupling
local viscousCouplingOrig
local engIdleAV = 0
local engStallAV = 0
local engineWorkPerUpdate = 0
local torqueReactionNodes = nil
local invBurnEfficiencyFuelDensity = 0
local torsionCoef = 0
local twist = 0
local diffRatio = 2
local invDiffRatio = 0.5
local diffLimit = 0.75
local avgPropAV = 0
local minPropAV = 0
local maxPropAV = 0
local ABSduration = 1/15
local ABShalfDuration = ABSduration * 0.5
local ABStimer = 0
local maxGearRatio = 0
local gearChangedTimer = 0
local gearChangeDelay = 0.5
local idleTorque = 0
local maxTorque = 0
local checkEngineTimer = 0
local engineDifferential = 1
local allModes = {0,1,2,3}
local autoModes = {2,3}
local manualModes = {2,1,0}
local activeModes = allModes
local avgAVsmoother = newExponentialSmoothing(15)
local smoothedAvgAV = 0

local function nop()
end

local function updateEngineState(dt)
    local max = math.max

    local engine = v.data.engine
    local torquediff
    local torque = nil
    local n, wd

    --Calc wheel sided engine AV
    local wheelBasedEngAV = avgDiffAV * engine.gears[M.gear]

    -- manual vs automatic clutch
    if M.autoClutch then
        -- auto clutch
        if clutchTimer > 0 then
            clutchTimer = max(0, clutchTimer - dt)
            clutchRatio = (clutchDuration - clutchTimer) * invClutchDuration
        end
    end

    --Calc torque from engine rpm
    torque = engine.torqueCurve[math.floor(engAV * 9.5493)] or 0
    torque = torque * M.throttle

    --Idle torque
    if engAV < engIdleAV and M.fuel ~= 0 then
        torque = max(torque, idleTorque)
    end

    -- rpm limiter
    if engAV > engine.maxAV then torque = 0 end

    -- Calculate engine's work
    local dtT = dt * torque
    engineWorkPerUpdate = engineWorkPerUpdate + dtT * (dtT * halfInvEngInertia + engAV)

    torquediff = (engAV - wheelBasedEngAV) * viscousCoupling 
    if math.abs(torquediff) > clutchTorque then
        torquediff = sign(torquediff) * clutchTorque
    end
    torquediff = torquediff * clutchRatio

    -- decouple when in neutral
    if M.gear == 0 then
        torquediff = 0
        M.torque = 0
        M.torqueTransmission = 0
        engAV = max(engAV + dt * (torque - engFriction - brakingCoef * engAV) * invEngInertia, 0)
        axleAV = avgDiffAV
    else
        M.torque = torquediff
        M.torqueTransmission = torquediff * engine.gears[M.gear]
        if torqueReactionNodes ~= nil then
            obj:applyTorque(torqueReactionNodes[1], torqueReactionNodes[2], torqueReactionNodes[3], torquediff)
        end
        engAV = max(engAV + dt * (torque - torquediff - engFriction - brakingCoef * engAV) * invEngInertia, 0)    
        axleAV = engAV / engine.gears[M.gear]
    end
end

local function updateWheels(dt)
    local abs = math.abs
    local max = math.max
    local min = math.min

    local n, wd

    -- Disable ABS for half the ABS duration time
    ABStimer = ABStimer + dt
    if ABStimer > ABSduration then ABStimer = ABSduration - ABStimer end
    local ABSavgAV
    if ABStimer < ABShalfDuration then
        ABSavgAV = -1 
    else
        ABSavgAV = abs(M.avgAV)
    end

    M.avgAV = 0
    M.absPulse = 0

    for n,wd in pairs(M.wheels) do
        local w = wd.obj
        wd.angularVelocity = w.angularVelocity
        local wBrakingTorque = 0

        M.avgAV = M.avgAV + wd.angularVelocity * wd.wheelDir

        -- braking
        if M.brake > 0 then
            wd.lastTorqueMode = 1
            wBrakingTorque = wd.brakeTorque * M.brake
            --anti-lock braking system (ABS)
            if wd.enableABS and abs(wd.angularVelocity) < ABSavgAV - wd.ABSthreshold then
                wd.lastTorqueMode = 0
                wBrakingTorque = 0
                M.absPulse = bit.bor(M.absPulse, 1)
            end
        else
            wd.lastTorqueMode = 0
        end

        -- and the parking brake
        if input.parkingbrake ~= 0 then
            wd.lastTorqueMode = 2
            wBrakingTorque = max(wBrakingTorque, wd.parkingTorque * input.parkingbrake)
        end

        w.brakingTorque = wBrakingTorque

        wd.torque = 0 -- prepare torque for propulsion
    end

    M.avgAV = M.avgAV * invWheelCount

    -- propulsion
    local torque
    local diff
    local absTorqueTransmission = abs(M.torqueTransmission)
    local absAxleAV = abs(axleAV)

    avgDiffAV = 0

    for n,diff in pairs(diffs) do
        local w1 = diff.w1
        local w2 = diff.w2
        local w1AV = w1.angularVelocity * w1.wheelDir
        local w2AV = w2.angularVelocity * w2.wheelDir

        local absW1AV = abs(w1AV)
        local absW2AV = abs(w2AV)
        local w1torque
        local w2torque

        if absW2AV < absW1AV then
            w1AV, w2AV = w2AV, w1AV
            absW1AV, absW2AV = absW2AV, absW1AV
            w1, w2 = w2, w1
        end

        avgDiffAV = avgDiffAV + w2AV -- Use max wheel speed as the axle's speed

        -- Open diffs
        if absW2AV > absAxleAV then
            if absW2AV > absAxleAV + 1 then
                local coef = min((absW2AV - (absAxleAV + 1)), 1)
                torque = coef * absTorqueTransmission * diff.engineTorqueCoef
                w1torque = sign(M.torqueTransmission) * torque
                w2torque = sign(axleAV - w2AV) * torque
            else
                torque = (1 - (absW2AV - absAxleAV)) * M.torqueTransmission * diff.engineTorqueCoef
                w1torque = torque
                w2torque = torque 
            end
        else
            torque = M.torqueTransmission * diff.engineTorqueCoef
            w1torque = torque
            w2torque = torque
        end

        -- LSD diffs
        if diff.state ~= 0 then
            local ltorque            
            diff.angle = diff.angle + (w1AV - w2AV) * dt
            if abs(diff.angle) < 0.1 then
                local absangle = abs(diff.angle * 10)
                ltorque = sign(diff.angle) * absangle * absangle * diff.closedTorque
            else
                local signangle = sign(diff.angle)
                ltorque = signangle * diff.closedTorque
                if diff.state == 1 then
                    diff.angle = 0
                else
                    diff.angle = signangle * 0.1
                end
            end
            w1torque = w1torque - ltorque
            w2torque = w2torque + ltorque
        else
            diff.angle = 0
        end

        w1.torque = w1.torque + w1torque * w1.wheelDir - sign(w1.angularVelocity) * axleFriction
        w2.torque = w2.torque + w2torque * w2.wheelDir - sign(w2.angularVelocity) * axleFriction

        w1.obj.torque = w1.torque
        w2.obj.torque = w2.torque
    end

    avgDiffAV = avgDiffAV * invDiffCount

    M.axleAngle = M.axleAngle + avgDiffAV * dt
    M.driveshaftAngle = M.driveshaftAngle + avgDiffAV * dt * engineDifferential

    if v.data.engine then
        updateEngineState(dt)
    end
end

local function disableEngine()
    M.engineDisabled = true
    engIdleAV = 0
end

local function checkEngine()
    if M.engineDisabled then return end

    -- engine dies when one of waterDamage nodes in water
    local n
    for _, n in ipairs(v.data.engine.waterDamage.nodes) do
        if obj:inWater(n) then
            disableEngine()
            break
        end
    end
end

local function simpleAutoGearbox()
    local engine = v.data.engine
    local tmpCurGear = M.gear
    -- automatic
    --interpolate based on throttle between high/low ranges
    local throttleCubed = M.throttle * M.throttle * M.throttle
    local shiftDown = engine.lowShiftDownAV + (engine.highShiftDownAV - engine.lowShiftDownAV) * throttleCubed
    local shiftUp   = engine.lowShiftUpAV + (engine.highShiftUpAV - engine.lowShiftUpAV) * throttleCubed

    --print(shiftDown, engIdleAV)

    if engAV < shiftDown then
        M.gear = M.gear - sign(M.gear)
    end
    if engAV > shiftUp then
        M.gear = M.gear + sign(M.gear)
    end

    -- neutral gear handling
    if M.gear == 0 then
        if input.throttle > 0 and smoothedAvgAV > -1 and tmpCurGear >=0 then
            M.gear = 1
        end

        if input.brake > 0 and smoothedAvgAV <= 0.15 and tmpCurGear <=0 then
            M.gear = -1
        end

        -- Control clutch to buildup engine RPM
        if clutchRatio == 1 then
            clutchRatio = math.min(math.max((engAV - engIdleAV)/(shiftDown - engIdleAV),0),1)
        end
    end

    M.gear = math.min(math.max(M.gear, -engine.revGearCount), engine.fwdGearCount)

    -- if M.gear ~= tmpCurGear then
    --     print(M.gear)
    --     print(smoothedAvgAV)
    --     print("-")
    -- end
end

local function realAutoGearbox(dt)
    clutchRatio = 1
    gearChangedTimer = math.max( gearChangedTimer - dt, 0 )

    local engine = v.data.engine
    local tmpCurGear = M.gear

    M.shifterPosition = math.max( -2, math.min(3, M.shifterPosition))

    if M.shifterPosition == 0 then 
        M.gear = 0
        return
    end

    if math.abs(M.shifterPosition) == 1 then
        --interpolate based on throttle between high/low ranges        
        if gearChangedTimer == 0 then
            local throttleCubed = M.throttle * M.throttle * M.throttle
            local shiftDown = engine.lowShiftDownAV + (engine.highShiftDownAV - engine.lowShiftDownAV) * throttleCubed
            local shiftUp   = engine.lowShiftUpAV + (engine.highShiftUpAV - engine.lowShiftUpAV) * throttleCubed

            if engAV < shiftDown then
                M.gear = M.gear - sign(M.gear)
            end

            if engAV > shiftUp then
                M.gear = M.gear + sign(M.gear)
            end

            if M.shifterPosition == 1 then M.gear = math.max(1, M.gear) end
            if M.shifterPosition == -1 then M.gear = math.min(-1, M.gear) end
            -- Control clutch to buildup engine RPM
            if math.abs(M.gear) == 1 and clutchRatio == 1 then
                clutchRatio = math.min(math.max(engAV/shiftDown,0),1)
            end
        end
    elseif M.shifterPosition == 3 then
        M.gear = 1
    elseif M.shifterPosition == 2 then
        M.gear = 2        
    elseif M.shifterPosition == -2 then
        M.gear = 0
        M.brake = 1
    end

    M.gear = math.min(math.max(M.gear, -engine.revGearCount), engine.fwdGearCount)

    if M.gear ~= tmpCurGear then
        gearChangedTimer = gearChangeDelay
    end
end

local function updateEngine(dt)
    local engine = v.data.engine

    --Update GUI engine RPM
    M.rpm = engAV * 9.5493

    M.axleAngle = M.axleAngle % math.pi
    M.driveshaftAngle = M.driveshaftAngle % math.pi

    M.throttle = input.throttle
    M.brake = input.brake
    clutchRatio = 1 - input.clutch

    -- Fuel consumption
    M.fuel = M.fuel - engineWorkPerUpdate * invBurnEfficiencyFuelDensity - M.fuelLeakRate * dt
    engineWorkPerUpdate = 0

    smoothedAvgAV = avgAVsmoother:get(M.avgAV)

    if M.fuel <= 0 then
        M.fuel = 0
        M.throttle = 0
    end

    if M.manualShift then
        if M.autoClutch then
            if M.brake ~= 0 and engAV < engIdleAV  * 2 then
                clutchRatio = 0
            end

            if engAV < engStallAV then
                clutchRatio = 0
            end
        end
    else
        -- driving backwards? - only with automatic shift - for obvious reasons ;)
        if M.shifterMode == 2 and M.gear <= 0 and smoothedAvgAV <= 0 then
            M.throttle = input.brake
            M.brake = input.throttle
        end
    end

    -- check for engine disabling (every 0.3 sec)
    checkEngineTimer = checkEngineTimer + dt
    if checkEngineTimer > 0.3 then
        checkEngineTimer = 0
        checkEngine()
    end

    if M.engineDisabled then
        M.throttle = 0
        M.rpm = 0
    end

    --transmission logic
    local tmpCurGear = M.gear
    if M.manualShift then
        -- manual
        if clutchTimer > 0 then    return end
        M.shifterPosition = math.min( math.max(M.shifterPosition, -engine.revGearCount), engine.fwdGearCount )
        M.gear = M.shifterPosition
    else
        if M.shifterMode == 2 then simpleAutoGearbox()
        elseif M.shifterMode == 3 then realAutoGearbox(dt)
        end
    end

    M.clutch = 1 - clutchRatio

    if tmpCurGear ~= M.gear then
        --print("gear changed: "..M.gear)
        --sounds.playSoundOnceAtNode("ShiftTestSound", 0, 0.6)
    end
end

local function disableDriveshaft()
    axleFriction = 0
    viscousCoupling = 0
end

local function isDriveshaftDisabled()
    return axleFriction == 0 and viscousCoupling == 0
end

local function updateCounts()
    local n,wd

    propWheelsCount = 0
    M.wheelCount = 0
    for n,wd in pairs(M.wheels) do
        if wd.propulsed ~= 0 then
            propWheelsCount = propWheelsCount + 1
        end
        M.wheelCount = M.wheelCount + 1
    end

    if M.wheelCount ~= 0 then
        invWheelCount = 1 / M.wheelCount
    else
        invWheelCount = 0
    end
end

local function updateDifferentials()
    local i = 0
    local wheelNames = {}

    -- Clear old diffs config state
    for _,diff in pairs(diffs) do
        diff.w1.obj.torque = 0
        diff.w2.obj.torque = 0
    end

    diffs = {}

    for _,wd in pairs(M.wheelInfo) do
        wheelNames[wd.name] = M.wheels[wd.wheelID]
    end


    local totalEngCoef = 0

    -- Sum engine torque coefs
    v.data.differentials = v.data.differentials or {}

    for _, diff in pairs(v.data.differentials) do
        if wheelNames[diff.wheelName1] and wheelNames[diff.wheelName2] then
            diff.engineTorqueCoef = diff.engineTorqueCoef or 1
            totalEngCoef = totalEngCoef + diff.engineTorqueCoef
        end
    end

    -- Update diffs
    for _,diff in pairs(v.data.differentials) do
        if wheelNames[diff.wheelName1] and wheelNames[diff.wheelName2] then
            diffs[i] = {    w1 = wheelNames[diff.wheelName1] , 
                            w2 = wheelNames[diff.wheelName2] ,
                            dtype = diffTypeMap[string.lower(diff.type or "open")] ,
                            closedTorque = diff.closedTorque ,
                            state = diffStateMap[string.lower(diff.state or "open")] ,
                            engineTorqueCoef = 0.5 * diff.engineTorqueCoef / totalEngCoef, --per diff wheel (0.5)
                            angle = 0
                        }
            i = i + 1
        end
    end

    diffCount = i
    if diffCount ~= 0 then
        invDiffCount = 1 / diffCount
    else
        invDiffCount = 0
    end
end

local function beamBroke(id)
    if not v.data.beams[id].name then return end
    local k,ab,n,wd
    local doUpdate = false
    local brokenBeamName = v.data.beams[id].name

    for n,wd in pairs(M.wheels) do
        if wd.axleBeams then
            for k,ab in pairs(wd.axleBeams) do
                if ab == brokenBeamName then
                    doUpdate = true
                    local w = wd.obj
                    w.torque = 0
                    w.brakingTorque = 0
                    M.wheels[n] = nil
                    break
                end
            end
        end
    end

    if v.data.engine then
        if v.data.engine.onBeamBreakDisableEngine then
            for k,ab in pairs(v.data.engine.onBeamBreakDisableEngine) do
                if ab == brokenBeamName then
                    M.engineDisabled = true
                    engIdleAV = 0
                    break
                end
            end
        end

        if v.data.engine.onBeamBreakDisableDriveshaft then
            for k,ab in pairs(v.data.engine.onBeamBreakDisableDriveshaft) do
                if ab == brokenBeamName then
                    disableDriveshaft()
                    break
                end
            end
        end

        if v.data.engine.fuelTankBeams then
            for k,ab in pairs(v.data.engine.fuelTankBeams) do
                if ab == brokenBeamName then
                    M.fuelLeakRate = M.fuelLeakRate + 1 / #v.data.engine.fuelTankBeams
                    break
                end
            end
        end
    end

    if doUpdate then
        updateCounts()
        updateDifferentials()
    end
end

local function updateWheelSlip(p)
    if not p then return end
    if not v.data.nodes[p.id1] then return end
    local wheelID = v.data.nodes[p.id1].wheelID
    if wheelID then
        local wInfo = M.wheelInfo[wheelID]
        wInfo.lastSlip = math.max(p.slipVel, wInfo.lastSlip)
        -- Smoothed instant energy (E/dt)
        wInfo.slipEnergy = 0.5 * (p.slipForce * p.slipVel + wInfo.slipEnergy)
        wInfo.contactMaterialID1 = p.materialID1
        wInfo.contactMaterialID2 = p.materialID2
        wInfo.contactDepth = math.max (p.depth, wInfo.contactDepth)
        wInfo.downForceRaw = wInfo.downForceRaw - p.normalForce
    end
end

local function wheelSlipGFXreset()
    for n,wd in pairs(M.wheelInfo) do
        wd.contactMaterialID1 = -1
        wd.contactMaterialID2 = -1
        wd.lastSlip = 0
        wd.slipEnergy = 0
        wd.contactDepth = 0
        wd.downForce = wd.downForceSmoother:get(wd.downForceRaw)
        wd.downForceRaw = 0
    end
end

local function shiftUp()
    if M.shifterMode == 2 then
        -- TODO: add automatic logic
    end
    M.shifterPosition = M.shifterPosition + 1
end

local function shiftDown()
    if M.shifterMode == 2 then
        -- TODO: add automatic logic
    end
    M.shifterPosition = M.shifterPosition - 1
end

local function shiftToGear(val)
    -- when in full automatic, shifting only to -1, 1, 2 and N is allowed
    -- TODO: lock -1 when moving forwards
    if M.shifterMode == 2 and val > 2 then
        return
    end
    M.shifterPosition = val
end

local function setShifterMode(v)
    v = v or 0

    wasDriveshaftDisabled = isDriveshaftDisabled()

    M.shifterPosition = M.gear

    M.activeModeIndex = v

    -- limits
    if M.activeModeIndex > #activeModes then
        M.activeModeIndex = 1
    end
    if M.activeModeIndex < 1 then
        M.activeModeIndex = 1
    end

    M.shifterMode = activeModes[M.activeModeIndex]

    -- now do the important things
    if M.shifterMode == 0 then
        -- full manual
        gui.message("Manual", 5, "shiftermode")
        M.autoClutch = false
        M.manualShift = true
    elseif M.shifterMode == 1 then
        -- manual with automatic clutch
        gui.message("Manual automatic clutch", 5, "shiftermode")
        M.autoClutch = true
        M.manualShift = true
    elseif M.shifterMode == 2 then
        -- simple automatic
        gui.message("Arcade automatic", 5, "shiftermode")
        M.autoClutch = true
        M.manualShift = false
        viscousCoupling = viscousCouplingOrig
    elseif M.shifterMode == 3 then
        -- real automatic
        gui.message("Real automatic", 5, "shiftermode")
        M.autoClutch = true
        M.manualShift = false
        viscousCoupling = viscousCouplingOrig
        M.shifterPosition = 0
    end

    -- if not automatic
    if M.shifterMode < 2 then
        viscousCoupling = clutchTorque / maxGearRatio 
    end

    if wasDriveshaftDisabled then
        disableDriveshaft()
    end
end

local function toggleShifterMode()
    setShifterMode(M.activeModeIndex + 1)
end

local function setDifferentialMode(v)
    M.differentialMode = math.min(math.max(v or 0, 0), 1)

    for n,diff in pairs(diffs) do
        if diff.dtype == diffTypeMap.lsd then
            diff.state = M.differentialMode
        end
    end    
end

local function toggleDifferentialMode()
    setDifferentialMode(M.differentialMode + 1)
end

local function genDiffs()
    diffs = {}

    if propWheelsCount ~= 2 then
        return
    end

    local diffWheels = {}
    local wn = 0

    for n,wd in pairs(M.wheels) do
        if wd.propulsed ~= 0 then
            diffWheels[wn] = wd
            wn = wn + 1
        end
    end

    if wn == 2 then
        log("Found 2 propulsed wheels: generating Open Differential between them")
        diffs[0] = {w1 = diffWheels[0], w2 = diffWheels[1], state = 0, engineTorqueCoef = 1, angle = 0}
    end
end

M.updateEngine = updateEngine
M.updateWheels = updateWheels
M.updateWheelSlip = updateWheelSlip
M.wheelSlipGFXreset = wheelSlipGFXreset
M.beamBroke = beamBroke

local function init()
    engAV = 0
    axleAV = 0
    clutchTimer = 0
    gearChangedTimer = 0
    M.engineDisabled = false
    M.engineIgnition = true
    engineWorkPerUpdate = 0
    M.gear = 0
    M.shifterPosition = 0
    M.fuelLeakRate = 0
    M.torqueTransmission = 0
    avgPropAV = 0
    M.avgAV = 0
    M.axleAngle = 0
    M.driveshaftAngle = 0

    M.wheels = {}
    M.wheelInfo = {}
    local wheelNames = {}

    M.updateWheels = updateWheels

    avgAVsmoother:reset()

    if not v or not v.data then
        M.updateEngine = nop
        M.updateWheels = nop
        M.updateWheelSlip = nop
        M.wheelSlipGFXreset = nop
        M.beamBroke = nop
        return
    end

    if v.data.wheels then
        M.wheels = shallowcopy(v.data.wheels)
        M.wheelInfo = shallowcopy(v.data.wheels)
    else
        M.updateWheels = nop
        M.updateWheelSlip = nop
    end

    local wobj
    for n,wd in pairs_safe(M.wheelInfo) do
        wobj = obj:getWheel(wd.wheelID)
        if wobj then
            wd.lastTorqueMode = 0
            M.wheelInfo[wd.wheelID].lastSlip = 0
            M.wheelInfo[wd.wheelID].slipEnergy = 0
            M.wheelInfo[wd.wheelID].contactMaterialID1 = -1
            M.wheelInfo[wd.wheelID].contactMaterialID2 = -1            
            M.wheelInfo[wd.wheelID].contactDepth = 0
            M.wheelInfo[wd.wheelID].downForceRaw = 0
            M.wheelInfo[wd.wheelID].downForceSmoother = newExponentialSmoothing(60)
            M.wheelInfo[wd.wheelID].downForce = 0
            M.wheelInfo[wd.wheelID].obj = wobj
            M.wheels[wd.wheelID].obj = wobj
            M.wheels[wd.wheelID].enableABS = M.wheels[wd.wheelID].enableABS or false
            M.wheels[wd.wheelID].ABSthreshold = M.wheels[wd.wheelID].ABSthreshold or 5
            M.wheels[wd.wheelID].brakeTorque = M.wheels[wd.wheelID].brakeTorque or 0
            M.wheels[wd.wheelID].parkingTorque = M.wheels[wd.wheelID].parkingTorque or 0
            M.wheels[wd.wheelID].torque = 0
            M.wheels[wd.wheelID].angularVelocity = 0
        else
            M.wheels[wd.wheelID] = nil
            M.wheelInfo[wd.wheelID] = nil
            logError('Wheel "'..M.wheels[wd.wheelID].name..'" could not be added to drivetrain')
        end
    end

    updateCounts()

    if v.data.differentials == nil then
        genDiffs()
    else
        updateDifferentials()
    end

    if v.data.engine then
        clutchDuration = v.data.engine.clutchDuration or 0.5
        invClutchDuration = 1 / clutchDuration
        engIdleAV = v.data.engine.idleAV
        engStallAV = v.data.engine.stallAV or engIdleAV * 0.5
        torsionCoef = v.data.engine.torsionCoef or 40
        engInertia = v.data.engine.inertia or 0.1
        ABSduration = 1/(v.data.engine.ABSrate or 15)
        ABShalfDuration = ABSduration * 0.5
        ABStimer = 0
        engineDifferential = v.data.engine.differential

        if v.data.engine.torqueReactionNodes_nodes then
            local t = v.data.engine.torqueReactionNodes_nodes
            if #t == 3 and v.data.nodes[t[1]] ~= nil and v.data.nodes[t[2]] ~= nil and v.data.nodes[t[3]] ~= nil then
                torqueReactionNodes = {t[1], t[2], t[3]}
            else 
                torqueReactionNodes = nil
            end
        end

        if v.data.engine.transmissionType == "automatic" then
            activeModes = autoModes
        end

        if v.data.engine.transmissionType == "manual" then
            activeModes = manualModes
        end

        if engInertia ~= 0 then
            invEngInertia = 1 / engInertia
        else
            invEngInertia = 10
        end
        halfInvEngInertia = invEngInertia * 0.5
        -- fuel
        M.fuelCapacity = v.data.engine.fuelCapacity or 100
        M.fuel = M.fuelCapacity
        local fuelEnergyDensity = (v.data.engine.fuelEnergyDensity or 32) * 1000000 -- MJ/liter
        local burnEfficiency = v.data.engine.burnEfficiency or 1
        if fuelEnergyDensity * burnEfficiency ~= 0 then
            invBurnEfficiencyFuelDensity = 1 / (fuelEnergyDensity * burnEfficiency)
        else
            invBurnEfficiencyFuelDensity = 1
        end
        diffRatio = v.data.engine.diffRatio or 2
        invDiffRatio = 1 / diffRatio
        engFriction = v.data.engine.friction or v.data.engine.engineFriction or 20
        brakingCoef = v.data.engine.brakingCoef or 0
        if v.data.engine.brakingCoefRPS ~= nil then
            brakingCoef = v.data.engine.brakingCoefRPS / ( 2 * math.pi )
        end
        axleFriction = v.data.engine.axleFriction or v.data.engine.axelFriction or 0

        if v.data.engine.torqueCurve == nil then
            v.data.engine.torqueCurve = {}
        end
        idleTorque = v.data.engine.torqueCurve[v.data.engine.idleRPM] or 0

        maxGearRatio = v.data.engine.maxGearRatio or 0
        gearChangeDelay = v.data.engine.autoGearChangeDelay or 0.5
        maxTorque = v.data.engine.maxTorque or 0

        clutchTorque = v.data.engine.clutchTorque or v.data.engine.torqueLimit
        if not clutchTorque then
            clutchTorque = v.data.engine.maxTorque
            log("clutchTorque not set. Set clutchTorque = "..clutchTorque)
        end

        viscousCoupling = v.data.engine.viscousCoupling or viscousCouplingOrig
        if not viscousCoupling then
            viscousCoupling = (clutchTorque / maxGearRatio) or 3
            log("viscousCoupling not set. Set viscousCoupling = "..viscousCoupling)
        end

        viscousCouplingOrig = viscousCoupling

        setShifterMode(M.activeModeIndex)
    else
        M.updateEngine = nop
        viscousCoupling = viscousCoupling or 3
        viscousCouplingOrig = viscousCoupling
    end
end

local function reset()
    -- for now: call init again, as it does no harm
    init()
end

local function refill()
    if M.fuel < M.fuelCapacity then
        M.fuel = math.min(M.fuel + 2, M.fuelCapacity)
    end
end

local function onDeserialized()
    setShifterMode(M.activeModeIndex)
end

-- public interface
M.reset           = reset
M.init            = init
M.refill          = refill

M.shiftUp         = shiftUp
M.shiftDown       = shiftDown
M.shiftToGear     = shiftToGear
M.toggleShifterMode = toggleShifterMode
M.setShifterMode  = setShifterMode
M.onDeserialized  = onDeserialized
return M