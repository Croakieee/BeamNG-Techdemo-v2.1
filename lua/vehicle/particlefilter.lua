-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

local function particleEmitted(p)
    --print("particleEmitted()")

    --[[
  attributes of p:
    int id1;
    float3 pos;
    float3 normal;
    float3 nodeVel;
    float perpendicularVel;
    float slipVel;
    float slipForce;
    float normalForce;
    int materialID1;
    int materialID2;

    int particleType;
    float width;
    int count;
    ]]--

    --dump(p)

    --print(p.materialID1..", "..p.materialID2)
    local pKey = p.materialID1.."_"..p.materialID2
    if v.materialsMap[pKey] ~= nil then
        for k,r in pairs(v.materialsMap[pKey]) do
            --print(r.compareFuncStr)
            if r.compareFunc(p) then
                p.nodeVel:scale(r.veloMult) -- not working?!?!
                p.particleType = r.particleType
                p.width = r.width
                p.count = r.count
                --print("spawned particle type " .. tostring(p.particleType))
                obj:addParticle(p)
            end
        end
    end

end

local function updateGFX()
end

local function reset()
end

local function init()
    reset()
end

-- public interface
M.particleEmitted = particleEmitted
M.updateGFX = updateGFX
M.reset = reset
M.init = init

return M