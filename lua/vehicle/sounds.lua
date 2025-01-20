-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

local loadedSounds = {}

local engineSound = nil
local windSound = nil

local function nop()
end

local function playSoundOnceAtNode(soundName, nodeID, volume)
    obj:playSFXOnce(soundName, volume, 0, nodeID)
end

local wheelsSounds = nil

local function playWheelSound(wheelID, soundName, vol, pitch)
    ws = wheelsSounds[wheelID][soundName]
    if vol < 0.1 then vol = 0 end
    if vol == 0 then 
        pitch = 0
    else
        if math.abs(vol - ws.lastVol) / vol < 0.05 and math.abs(pitch - ws.lastPitch) < 0.05 then return end
    end
    if vol == ws.lastvol then return end
    ws.lastVol = vol
    ws.lastPitch = pitch
    obj:setVolume(ws.obj, vol)
    obj:setPitch(ws.obj, pitch)
end

local function update(dt)
    -- engine
    if v.data.engine ~= nil and v.data.engine.maxRPM ~= nil then
        local enginePitch = (drivetrain.rpm / v.data.engine.maxRPM) * 2
        obj:setPitch(engineSound, enginePitch)
        obj:setVolume(engineSound, (0.45 + (drivetrain.throttle * 0.3)) + (enginePitch * 0.12))
    end
    
    -- wind

    local speed = obj:getVelocity():length() -- speed
    local vol = (speed * speed * 0.001)
    local pitch = speed / 60
    if vol > 1 then vol = 1 end
    obj:setVolume(windSound, vol)
    obj:setPitch(windSound, pitch)

    -- wheels
    for wi,wd in pairs(drivetrain.wheelInfo) do
        local w = wd.obj
        local slip = wd.lastSlip
        local slipEnergy = wd.slipEnergy

        local skidVol = 0
        local skidPitch = 0
        local rollVol = 0
        local rollPitch = 0

        if wd.contactMaterialID1 == 10 and wd.contactMaterialID2 == 4 and wd.contactDepth == 0 then
            if slipEnergy > 20 then
                skidVol = math.min(slipEnergy * 0.005 + 0.3, 1)
                skidPitch = math.max(slip - 4, 0) * 0.05 + 0.8
            else
                local wheelSpeed = math.abs(w.angularVelocity * wd.radius)
                rollVol = math.min(math.sqrt(wheelSpeed * 0.018), 1)
                rollPitch = wheelSpeed * 0.125
            end
        end
        
        playWheelSound(wi, "SkidTestSound", skidVol, skidPitch)
        playWheelSound(wi, "RollingTestSound", rollVol, rollPitch)
    end
end

-- public interface
M.update  = update
M.playSoundOnceAtNode = playSoundOnceAtNode

local function addWheelSound(wheelID, wd, soundName)
    if wheelsSounds == nil then wheelsSounds = {} end
    if wheelsSounds[wheelID] == nil then wheelsSounds[wheelID] = {} end
    
    local s = gameEngine:createSFXSource(soundName)
    if s == nil then 
        M.update = nop
        M.playSoundOnceAtNode = nop
        return nil 
    end
    s:setVolume(0)
    s:setPitch(1)
    s:play(-1)
    obj:attachSFXNode(s, wd.node1)
    wheelsSounds[wheelID][soundName] = {obj = s, lastVol = 0, lastPitch = 0}
    table.insert(loadedSounds, s)
end

local function createSFXSource(SFXname, nodeID)
    local var = gameEngine:createSFXSource(SFXname)
    if var == nil then 
        M.update = nop
        M.playSoundOnceAtNode = nop
        return nil 
    end
    var:setVolume(0)
    var:play(-1)
    obj:attachSFXNode(var, nodeID)
    table.insert(loadedSounds, var)
    return var
end

local function init()   
    local cameraNode = 0
    if v.data.camerasInternal ~= nil then
        local k, v = next(v.data.camerasInternal)
        cameraNode = v.camNodeID
    end
    
    -- Try to get a node on the engine. There is currently a libbeamng bug that
    -- causes sound sources at the camera to cause problems for multichannel
    -- setups, as small variations in position can cause sound to dither back
    -- and forth between the channels when in cockpit view.
    local engineNode = cameraNode
    if v.data.engine ~= nil and v.data.engine.torqueReactionNodes_nodes then
        local t = v.data.engine.torqueReactionNodes_nodes
        if #t > 0 and v.data.nodes[t[1]] ~= nil then
            engineNode = t[1]
        end
    end

    if engineSound == nil then
        engineSound = createSFXSource("EngineTestSound", engineNode)
    end

    -- TODO: Find a better place to emit wind sounds. Maybe at the windows?
    if windSound == nil then
        windSound = createSFXSource("WindTestSound", cameraNode)
    end    

    if wheelsSounds == nil then
        for wi,wd in pairs(drivetrain.wheels) do
            addWheelSound(wi, wd, "RollingTestSound")
            addWheelSound(wi, wd, "SkidTestSound")
        end
    end
end

local function destroy()
    for k,v in pairs(loadedSounds) do
        if v and v:isValid() then
            gameEngine:deleteSFXSource(v, true)
            v:destroy()
        end
    end
    loadedSounds = {}
    wheelsSounds = nil
    engineSound = nil
    windSound = nil
end

-- public interface
M.destroy = destroy
M.init = init
return M