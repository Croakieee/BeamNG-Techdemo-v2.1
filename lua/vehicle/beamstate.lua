-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.wheels = {}

local totalBreakEnergy = 0
local breakNode = -1
local maxEnergy = 0
local collTriState = {}

local materialBrokeQueue = {}

local soundTimer
local prevElapsedTime = 0

-- local helper function
local function luaBreakBeam(id)
    -- notify the rest
    drivetrain.beamBroke(id)
    electrics.beamBroke(id)
end

local function deflateTire(wheelid)
    local wheel = M.wheels[wheelid]
    local i, beam
    M.lowpressure = true
    
    --if wheel.reinforcementBeams ~= nil then
    --    for i, beam in pairs (wheel.reinforcementBeams) do
    --        obj:setBeamSpringDamp(beam.cid, beam.beamSpring * 0.5, -1, beam.beamSpring * 0.02, -1)
    --    end
    --end

    if wheel.pressureGroup ~= nil then
        if v.data.pressureGroups[wheel.pressureGroup] ~= nil then
            obj:setGroupPressure(v.data.pressureGroups[wheel.pressureGroup], (0.2 * 6894.757 + 101325))
        end
    end
    
    if wheel.treadBeams ~= nil then
        for i, beam in pairs (wheel.treadBeams) do
            obj:setBeamSpringDamp(beam.cid, beam.beamSpring * 0.5, -1, beam.beamSpring * 0.005, -1)
        end
    end
    
    if wheel.sideBeams ~= nil then
        for i, beam in pairs (wheel.sideBeams) do
            obj:setBeamSpringDamp(beam.cid, beam.beamSpring * 0.00, -1, beam.beamSpring * 0.5, -1)
        end
    end

    if wheel.pressuredBeams ~= nil then
        for i, beam in pairs (wheel.pressuredBeams) do
            obj:setBeamPressureRel(beam.cid, 0, math.huge, -1, -1)
        end
    end
end

local function updateGFX()
    -- crash sounds
    if totalBreakEnergy ~= 0 then
        if breakNode ~= -1 then
            local et = soundTimer:stop() + prevElapsedTime
            prevElapsedTime = et
            soundTimer:reset()
            -- Don't play the sound a billion times at once (this logic should eventually go in the sound code)
            if et > 600 then
                sounds.playSoundOnceAtNode("CrashTestSound", breakNode, math.log10(totalBreakEnergy) * 0.2)
                prevElapsedTime = 0
            end
        end
        totalBreakEnergy = 0
        breakNode = -1
        maxEnergy = 0
    end
    
    -- work off the material switching, needs to happen in synchronous mode
    if obj.mesh ~= nil then
        for k,beam in pairs(materialBrokeQueue) do
            material.switchBrokenMaterial(beam.deformSwitches)
        end
    end
    materialBrokeQueue = {}
end

local function beamBroken(id, energy)
    local beam
    
    if energy > maxEnergy then
        breakNode = v.data.beams[id].id1
        maxEnergy = energy
    end
    totalBreakEnergy = totalBreakEnergy + energy
    
    luaBreakBeam(id)
    if v.data.beams[id] ~= nil then
        local beam = v.data.beams[id]
        
        if bdebug.enabled == true then
            local m ="beam "..id.." just broke: " .. v.data.nodes[beam.id1].name .. " ["..beam.id1.."]" .."  ->  " .. v.data.nodes[beam.id2].name .. " ["..beam.id2.."]"
            print(m)
            gui.message(m)
        end
        
        -- Break coll tris
        if beam.collTris then
            for k,ctid in pairs(beam.collTris) do
                if collTriState[ctid] then
                    collTriState[ctid] = collTriState[ctid] - 1
                    if collTriState[ctid] <= 1 then
                        obj:breakCollisionTriangle(ctid)
                        -- deflate pressureGroup
                        if v.data.triangles then
                            local triangle = v.data.triangles[ctid]
                            if triangle.pressureGroup ~= nil and v.data.pressureGroups[triangle.pressureGroup] ~= nil then
                                obj:deflatePressureGroup(v.data.pressureGroups[triangle.pressureGroup])
                            end
                        end
                    end
                end
            end
        end
        
        -- Break the meshes
        if beam.disableMeshBreaking == nil or beam.disableMeshBreaking == false then
            obj:breakMeshes(id)
        end

        -- Break rails
        obj:breakRails(id)
        
        -- Check for punctured tire
        if beam.wheelID ~= nil then
            M.wheels[beam.wheelID].punctured = true
            deflateTire(beam.wheelID)
        end
        
        -- breakgroup handling
        if beam.breakGroup and beam.breakGroup ~= "" then
            -- find all beams with that breakgroup
            if beam.breakGroupType == 0 or beam.breakGroupType == nil then
                -- break all beams in that group
                for k, b in pairs(v.data.beams) do
                    if b.breakGroup == beam.breakGroup then
                        --print("  breakgroups: also breaking beam "..k.. " as in breakgroup ".. b.breakGroup)
                        obj:breakBeam(k)
                        luaBreakBeam(k)
                    end
                end

            elseif beam.breakGroupType == 1 then
                -- this type does not break the group but will be broken by the group
            end
        end
        
        if beam.deformSwitches then
            table.insert(materialBrokeQueue, beam)
        end
    else
        --print ("beam "..id.." just broke")
    end
    
    -- funky: disable engine once a beam breaks ;)
    --BeamEngine:setEnabled(false)
end

local function init()
    totalBreakEnergy = 0
    breakNode = -1
    maxEnergy = 0    
    soundTimer = HighPerfTimer()

    if v.data.wheels then
        M.wheels = deepcopy(v.data.wheels)
        for i, wheel in pairs(M.wheels) do
            wheel.punctured = false
            wheel.pressureCoef = 1
        end
    end    
    
    local i, beam
    for i, beam in pairs (v.data.beams) do
        obj:setBeamSpringDamp(beam.cid, beam.beamSpring or -1, beam.beamDamp or -1, beam.springExpansion or -1, beam.dampExpansion or -1)
    end
    
    -- Reset colltris
    if v.data.triangles then
        collTriState = {}
        for k, v in pairs(v.data.triangles) do
            if v.cid and v.beamCount then
                collTriState[v.cid] = v.beamCount
            end
        end
    end
end

local function beamDeformed(id, ratio)
    --print("beam "..id.." deformed with ratio "..ratio)
    if v.data.beams[id] then
        local beam = v.data.beams[id]
        if beam.deformSwitches then
            table.insert(materialBrokeQueue, beam)
        end
    end
end

local function reset()
    init()
    M.lowpressure = false

    --[[
    for flexKey, flexbody in pairs (v.data.flexbodies) do
        print("resetting flexbody")
        local sw = flexbody.switch
        if sw then
            sw:reset()
        end
    end
    ]]--
end

local function breakAllBreakgroups()
    for k, b in pairs(v.data.beams) do
        if b.breakGroup ~= nil and b.breakGroup ~= "" then
            obj:breakBeam(k)
        end
    end
end

local function breakHinges()
    for k, b in pairs(v.data.beams) do
        if b.breakGroup ~= nil and b.breakGroup ~= "" then
            if string.find(b.breakGroup, "hinge") ~= nil or string.find(b.breakGroup, "latch") ~= nil then
                --print("  breaking hinge beam "..k.. " as in breakgroup ".. b.breakGroup)
                obj:breakBeam(k)
            end
        end
    end
end

local function deflateTires()
    for i, wheel in pairs(M.wheels) do
        wheel.punctured = true
        deflateTire(i)
    end
end

-- public interface
M.beamBroken  = beamBroken
M.reset       = reset
M.init          = init
M.deflateTire = deflateTire
M.updateGFX   = updateGFX
M.beamDeformed = beamDeformed
M.breakAllBreakgroups = breakAllBreakgroups
M.breakHinges = breakHinges
M.deflateTires = deflateTires

return M