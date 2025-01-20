-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.enableFFB = true --false

-- The direction of the real wheel's FFB
M.wheelFFBaxisdir = 1

-- The FFB Force coefficient
M.wheelFFBForceCoef = 400

-- The FFB steady force limits (in Newton)
M.wheelFFBForceLimit = 2

-- FFB smoothing
M.wheelFFBSmoothing = 100

-- High frequency FFB smoothing
M.wheelFFBSmoothingHF = 50

M.hydros = {}
M.lastFFBforce = 0
local FFBsmooth = newExponentialSmoothing(M.wheelFFBSmoothing)
local FFBHydros = {}
local FFBID    = -1 -- >=0 are valid IDs
local wheelpos = 0
local FFBIntegral = 0
local curForceLimitSmoother = newExponentialSmoothing(100)
local curForceLimit = 0
local FFBForce = 0
local FFmax = 10
local FFstep = FFmax / 256

local function nop()
end

local function toInputSpace(h, state)
    if state > h.center then
        return (state - h.center) * h.invMultOut
    else
        return (state - h.center) * h.invMultIn
    end
end

local function FFquantum(f)
    return math.floor(f/FFstep)
end

local function updateGFX(dt)
    -- update the source command value
    for i,h in pairs(M.hydros) do
        h.cmd = math.min(math.max(electrics.values[h.inputSource] or 0, h.inputInLimit), h.inputOutLimit) * h.inputFactor

        if h.cmd ~= h.inputCenter or h.analogue == true then
            h._inrate = h.inRate
            h._outrate = h.outRate
        else
            -- set autocenter rate
            h._inrate = h.autoCenterRate
            h._outrate = h.autoCenterRate
        end

        if h.cmd >= h.inputCenter then
            h.cmd = h.cOut + h.cmd * h.multOut
        else
            h.cmd = h.cIn + h.cmd * h.multIn
        end

        h.hydroDirState = toInputSpace(h, h.state)
    end

    if FFBID >= 0 then
        curForceLimit = curForceLimitSmoother:get(M.wheelFFBForceLimit)
        wheelpos = electrics.values["steering_input"] or 0
        if FFquantum(FFBForce) ~= FFquantum(M.lastFFBforce) then
            M.lastFFBforce = FFBForce
            obj:sendForceFeedback(FFBID, M.wheelFFBaxisdir * M.lastFFBforce)
        end
    end
end

local function update(dts)
    -- state: the state of the hydro from -1 to 1
    -- cmd the input value
    -- note: state is scaled to the ratio as the last step
    local hcmd = -1
    for i,h in pairs(M.hydros) do
        -- slowly approach the desired value
        if h.cmd < h.state then
            h.state = math.max(h.state - dts * h._inrate, h.cmd)
        else
            h.state = math.min(h.state + dts * h._outrate, h.cmd)
        end

        --if inputSource ~= "steering" then
        --    print("state: "..h.state .. " - inlimit: " .. h.inLimit.. " - state: "..h.state .. " cmd:"..h.cmd .. " val = "..val)
        --end
        obj:setBeamLengthRefRatio(h.beam.cid, h.state)
    end

    if FFBID >= 0 then
        local hcount = 0
        local hpos = 0
        for i,h in pairs(FFBHydros) do
            local hbcid = h.beam.cid
            if not obj:beamIsBroken(hbcid) then
                hcount = hcount + 1
                hpos = hpos + toInputSpace(h, obj:getBeamLength(hbcid) * h.invFFBHydroRefL)
            end
        end

        if hcount == 0 then
            M.lastFFBforce = 0
        else
            local hposraw = hpos / hcount
            local wheeldispl = wheelpos - hposraw
            FFBForce = M.wheelFFBForceCoef * wheeldispl
            FFBForce = FFBsmooth:get(sign(FFBForce) * math.min(math.abs(FFBForce), curForceLimit))

            if sign(wheeldispl) ~= sign(M.lastFFBforce) then
                FFBWindow = M.wheelFFBSmoothingHF
            else
                FFBWindow = M.wheelFFBSmoothing
            end
            if math.abs(FFquantum(FFBForce) - FFquantum(M.lastFFBforce)) > 1 then
                M.lastFFBforce = FFBForce
                obj:sendForceFeedback(FFBID, M.wheelFFBaxisdir * M.lastFFBforce)
            end
            FFBsmooth:setWindow(FFBWindow)
        end
    end
end

-- nop'ed functions
M.updateGFX = updateGFX
M.update = update

local function init()
    if v.data.hydros == nil then
        M.updateGFX = nop
        M.update = nop
        M.hydros = {}
        return
    end

    M.hydros = shallowcopy(v.data.hydros)

    local hydroCount = 0
    for i, h in pairs (M.hydros) do
        hydroCount = hydroCount + 1
        h.inputCenter = h.inputCenter * h.inputFactor
        h.inputInLimit = h.inputInLimit * h.inputFactor
        h.inputOutLimit = h.inputOutLimit * h.inputFactor
        local inputFactorSign = sign(h.inputFactor)

        if h.inputFactor < 0 then
            h.inputInLimit, h.inputOutLimit = h.inputOutLimit, h.inputInLimit
        end

        local inputMiddle = (h.inputOutLimit + h.inputInLimit) * 0.5
        if h.inputCenter >= inputMiddle then
            h.center = 1 + (h.outLimit - 1) * (h.inputCenter - inputMiddle) / (h.inputOutLimit - inputMiddle)
        else
            h.center = 1 - (1 - h.inLimit) * (inputMiddle - h.inputCenter) / (inputMiddle - h.inputInLimit)
        end
        h.state = h.center
        h.multOut = (h.outLimit - h.center) / (h.inputOutLimit - h.inputCenter)
        h.cOut = h.center - h.inputCenter * h.multOut
        h.multIn = (h.center - h.inLimit) / (h.inputCenter - h.inputInLimit)
        h.cIn = h.center - h.inputCenter * h.multIn
        h.cmd = h.inputCenter
        h.invMultOut = 1 / (h.outLimit - h.center) * inputFactorSign
        h.invMultIn = 1 / (h.center - h.inLimit) * inputFactorSign
        h._inrate = h.inRate
        h._outrate = h.outRate
        h.hydroDirState = 0
        
        -- little workaround
        if h.inputSource == "steering" then
            h.inputSource = "steering_input"
        end

        if h.inputSource == "steering_input" then
            h.steering = true
        end
    end

    if hydroCount == 0 then
        M.updateGFX = nop
        M.update = nop 
    end

    FFBHydros = {}
    for i,h in pairs(M.hydros) do
        if h.steering then
            h.invFFBHydroRefL = 1 / obj:getBeamRefLength(h.beam.cid)
            table.insert(FFBHydros, h)
        end
    end

    if #FFBHydros ~= 0 then
        FFBsmooth:set(0)
        curForceLimitSmoother:set(0)
        FFBIntegral = 0

        if M.enableFFB then
            FFBID = obj:setupForceFeedback("xaxis")
        end

        if FFBID >= 0 then
            logInfo("yay, force feedback is available :D")

            local config_json = obj:getForceFeedbackConfig(FFBID)
            local state, config = pcall(json.decode, config_json)
            if state == false then
                logError("unable to decode JSON: "..tostring(v))
                logError("JSON decoding error: "..tostring(config))
            else
                logInfo("Force Feedback Configuration:")
                -- dump(config)
                local FFaxis = nil
                for i, v in pairs(config.axes) do
                    if v.ff_max_force ~= 0 and v.name == 'xaxis' then
                        FFaxis = v
                    end
                end
                if FFaxis then
                    FFmax = FFaxis.ff_max_force
                    M.wheelFFBForceLimit = math.min(M.wheelFFBForceLimit, FFmax)
                    FFstep = FFmax / FFaxis.ff_res
                end
                dump(FFaxis)
            end

        end
    end
end

local function reset()
    for k,h in pairs(M.hydros) do
        h.state = h.center
        h.cmd = h.inputCenter
        h._inrate = h.inRate
        h._outrate = h.outRate
    end

    FFBsmooth:set(0)
    curForceLimitSmoother:set(0)
    FFBIntegral = 0
end

local function sendHydroStateToGUI()
    obj:executeJS("HookManager.trigger('HydrosUpdate', "..encodeJson(M.hydros)..");",0)
end

-- public interface
M.init = init
M.reset = reset
M.sendHydroStateToGUI = sendHydroStateToGUI

return M