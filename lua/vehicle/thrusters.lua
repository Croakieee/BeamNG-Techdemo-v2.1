-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.activeThrusters = {}

local thrusterState = {}
local autoThrusters = {}
local thrusting = false

local gfxFrameTick = 0

local function nop()
end

local function update()
    -- node1 is source, node2 is destination
    -- we apply and measure forces/velocity for node2

    local t
    for key, thruster in pairs(autoThrusters) do
        local vel = -obj:getNodeVelocity(thruster.id2, thruster.id1)
        if vel > 0.3 then
            t = (vel *vel) * thruster.factor
            if thrusting then
                t = math.min( math.max(obj:getNodeForce(thruster.id1, thruster.id2), 0) + t, thruster.thrustLimit)
            else
                t = math.min( t, thruster.thrustLimit)
            end
            obj:applyForce(thruster.id2, thruster.id1, t )
            if gfxFrameTick == 1 then
            end
        end
    end    

    for key, thruster in pairs(thrusterState) do
        -- applyForce(node1, node2, forceMagnitude)
        obj:applyForce(thruster[2], thruster[1], thruster[3])
        if gfxFrameTick == 1 then    
        end
    end

    if gfxFrameTick == 1 then gfxFrameTick = 0 end
end

local function updateGFX()
    thrusterState = {}
    for key, thruster in pairs (M.activeThrusters) do
        if thruster.control == '+axisX' and input.axisX > 0 then
            table.insert(thrusterState, {thruster.id1, thruster.id2, math.min(input.axisX * thruster.factor, thruster.thrustLimit)})
        elseif thruster.control == '-axisX' and input.axisX < 0 then
            table.insert(thrusterState, {thruster.id1, thruster.id2, math.min(-input.axisX * thruster.factor, thruster.thrustLimit)})
        elseif thruster.control == '+axisY' and input.axisY > 0 then
            table.insert(thrusterState, {thruster.id1, thruster.id2, math.min(input.axisY * thruster.factor, thruster.thrustLimit)})
        elseif thruster.control == '-axisY' and input.axisY < 0 then
            table.insert(thrusterState, {thruster.id1, thruster.id2, math.min(-input.axisY * thruster.factor, thruster.thrustLimit)})
        
        elseif input.keys[thruster.control] then
            table.insert(thrusterState, {thruster.id1, thruster.id2, thruster.thrustLimit})
        end
    end
    
    thrusting = (next(thrusterState) ~= nil)
    gfxFrameTick = 1
end

local function init()
    -- update public interface
    if v.data.thrusters == nil or next(v.data.thrusters) == nil then
        M.update = nop
        M.updateGFX = nop
        return
    else
        M.update = update
        M.updateGFX = updateGFX
    end

    thrusterState = {}
    autoThrusters = {}
    M.activeThrusters = {}
    for key, thruster in pairs(v.data.thrusters) do
        if thruster.control == 'auto' then
            table.insert(autoThrusters, thruster)
        else
            table.insert(M.activeThrusters, thruster)
        end
    end
    
    for key, thruster in pairs (M.activeThrusters) do
        thruster.factor = thruster.factor or 1
        thruster.thrustLimit = thruster.thrustLimit or math.huge
    end
end

local function reset()
    init()
end

-- public interface
M.reset       = reset
M.init        = init
M.update      = nop
M.updateGFX   = nop

return M