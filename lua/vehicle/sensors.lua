-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.gx = 0
M.gy = 0
M.gz = 0
M.gx2 = 0
M.gy2 = 0
M.gz2 = 0

M.gxMax = 0
M.gxMin = 0

M.gyMax = 0
M.gyMin = 0

M.gzMax = 0
M.gzMin = 0

local gx_smooth = nil
local gy_smooth = nil
local gz_smooth = nil
local gx_smooth2 = nil
local gy_smooth2 = nil
local gz_smooth2 = nil

local invRefNodeWeight = 1

local resetTimer = 0
local resetTime  = 10 -- time when the min/max values are getting reset

local function resetMinMax()
    M.gxMax = 0
    M.gxMin = 0
    M.gyMax = 0
    M.gyMin = 0
    M.gzMax = 0
    M.gzMin = 0

    if v.data.refNodes ~= nil then
        invRefNodeWeight = 1.0 / v.data.nodes[v.data.refNodes[0].ref].nodeWeight
    end
end

local function reset()
    gx_smooth = newExponentialSmoothing(100)
    gy_smooth = newExponentialSmoothing(100)
    gz_smooth = newExponentialSmoothing(100)
    gx_smooth2 = newExponentialSmoothing(1000)
    gy_smooth2 = newExponentialSmoothing(1000)
    gz_smooth2 = newExponentialSmoothing(1000)

    resetMinMax()
end

local function updateGFX(dt)
    resetTimer = resetTimer + dt
    if resetTimer > resetTime then
        resetMinMax()
        resetTimer = resetTimer - resetTime
    end
end

local function update()
    if not v.data.refNodes then return end

    -- collecting the data
    local gx_raw = obj:getNodeForce(v.data.refNodes[0].ref, v.data.refNodes[0].left) * invRefNodeWeight
    local gy_raw = obj:getNodeForce(v.data.refNodes[0].ref, v.data.refNodes[0].back) * invRefNodeWeight
    local gz_raw = obj:getNodeForce(v.data.refNodes[0].ref, v.data.refNodes[0].up) * invRefNodeWeight

    M.gx = gx_smooth:get(gx_raw)
    M.gy = gy_smooth:get(gy_raw)
    M.gz = gz_smooth:get(gz_raw)
    M.gx2 = gx_smooth2:get(gx_raw)
    M.gy2 = gy_smooth2:get(gy_raw)
    M.gz2 = gz_smooth2:get(gz_raw)

    if M.gx2 > M.gxMax then M.gxMax = M.gx2 end
    if M.gx2 < M.gxMin then M.gxMin = M.gx2 end

    if M.gy2 > M.gyMax then M.gyMax = M.gy2 end
    if M.gy2 < M.gyMin then M.gyMin = M.gy2 end

    if M.gz2 > M.gzMax then M.gzMax = M.gz2 end
    if M.gz2 < M.gzMin then M.gzMin = M.gz2 end
end

-- public interface
M.update = update
M.updateGFX = updateGFX
M.reset = reset

return M