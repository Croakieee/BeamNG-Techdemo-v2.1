-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.skeleton_mode = 0
M.node_info_mode = 'off'
M.coltrimode = false
M.mesh_visibility = 100
M.enabled = false
M.static_collision = false
M.terrain_debug = false

local nodeDisplayDistance = 0 -- 6 - broken atm since it uses the center point of the camera :\
local globalMeshAlpha = 0

local function debugDrawNode(col, node, txt)
    if node.name == nil then
        obj.debugDrawProxy:drawNodeText(node.cid, col, "["..tostring(node.cid).."] "..txt, nodeDisplayDistance)
    else
        obj.debugDrawProxy:drawNodeText(node.cid, col, tostring(node.name).." " ..txt, nodeDisplayDistance)
    end
end


local function activated(m)
end

local function guiUpdate()
    --print("bdebug.update called " .. tostring(M.enabled))
    obj.debugDrawProxy:showDebug(M.enabled)
    
    if obj.mesh then
        obj.mesh:setAlpha(M.mesh_visibility/100, "", false)
    end
    
    --obj:executeJS("alert('hi');",0)
end

local function onDeserialized()
    --print("bdebug.onDeserialized()")
    guiUpdate()
end

local function reset()
    --print("bdebug.reset()")
    -- show all meshes
    if obj.mesh then
        obj.mesh:setAlpha(1, "", false)
    end
    M.skeleton_mode = 0
    M.node_info_mode = 'off'
    M.coltrimode = false
    M.mesh_visibility = 100
    M.enabled = false
    M.static_collision = false
    M.terrain_debug = false
end

local function draw()
    -- collision debug M.mode is special as its an attribute
    --print(type(M.node_info_mode) .. " = " .. tostring(M.node_info_mode))
    -- new option things
    if M.skeleton_mode ~= 0 then
        obj.debugDrawProxy:drawBeams(M.skeleton_mode)

        -- draw 3d beamns:
        -- 3d beam debug example
        for i, beam in pairs (v.data.beams) do
            --print("skeleton mode: " .. beam.cid)
            if beam.highlight then
                obj.debugDrawProxy:drawBeam3d(beam.cid, beam.highlight.radius, parseColor(beam.highlight.col))
            end
        end

        --[[
        -- node sphere debug example
        local w = 0
        for i, node in pairs (v.data.nodes) do
            w = w + node.nodeWeight
        end
        w = w / #v.data.nodes

        for i, node in pairs (v.data.nodes) do
            local c = color(0,255,255,150)
            local r = (node.nodeWeight / w) * 0.03
            if node.collision then
                c = color(255,0,0,200)
            elseif node.selfcollision then
                c = color(255,0,255,200)
            end
            obj.debugDrawProxy:drawNodeSphere(node.cid, r, c)
        end
        ]]--
    end

    if M.coltrimode then
        obj.debugDrawProxy:drawColTris(0, color(255,255,0,0), color(255,0,0,255))
    end

    obj.debugDrawProxy.drawCollisionTris = M.static_collision
    obj.debugDrawProxy.drawTerrainDebug = M.terrain_debug
    --print(M.drawTerraterrain_debuginDebug)
    
    if M.node_info_mode == 'numbers' then
        obj.debugDrawProxy:drawNodeNumbers(color(255,0,0,255), nodeDisplayDistance)
    elseif M.node_info_mode == 'names' then
        local col = color(128,0,255,255)
        for k, node in pairs (v.data.nodes) do
            debugDrawNode(col, node, "")
        end
    elseif M.node_info_mode == 'weights' then
        for k, node in pairs (v.data.nodes) do
            local col = color(0,0,0,255)
            col.r = 255 - (node.nodeWeight * 20)
            col.g = 0
            col.b = 0
            local txt = tostring(node.nodeWeight).."kg"
            obj.debugDrawProxy:drawNodeText(node.cid, col, txt, nodeDisplayDistance)
        end
    elseif M.node_info_mode == 'materials' then
        for k, node in pairs (v.data.nodes) do
            mat = particles.getMaterialByID(v.materials, node.nodeMaterial)
            local matname = "unknown"
            col = color(255,0,0,255) -- unknown material: red
            if mat ~= nil then
                col = color(mat.colorR, mat.colorG, mat.colorB, 255)
                matname = mat.name
            end
            debugDrawNode(col, node, matname)
        end
    end
end

-- public interface
M.reset   = reset
M.draw    = draw
M.activated = activated
M.toggleMeshAlpha = toggleMeshAlpha
M.update  = update
M.guiUpdate = guiUpdate
M.onDeserialized = onDeserialized

return M