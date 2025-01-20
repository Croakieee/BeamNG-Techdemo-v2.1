-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

package.path = "lua/t3d/?.lua;lua/gui/?.lua;lua/?.lua;?.lua"
require("utils")

t3d = require("t3d_utils")
json = require("json")

-- CEF GUI components
levelChooser = require("levelChooser")


-- rewrite some functions for T3D usage
-- TODO: clean these up
logAlways=print

-- improve stacktraces
local STP = require "StackTracePlus"
debug.traceback = STP.stacktrace

function luaPreRender(dt)
    --print("Lua frame")
end

function update()
    -- be:executeJS('alert("works :D");', 1)
    
    --[[
    print("Lua update: " .. Lua:getMemoryUsageKB())
    
    local v = bengine:getActiveObject()
    if v then
        --print("v: " ..v:getJBeamFilename())
        local am = v:getActionMap()
        am:unbindDevice("keyboard")
        print("unbound")
    end
    ]]--
end



function init()
    print('T3D Lua working')
    dump(getDirListing('levels/'))
--    be:executeJS('alert("works :D");', 1)
end


function deleteObject(name)
    local sg = scenetree[name]
    if(sg) then
        sg:delete()
    end
end


function getMission()
    local mg = scenetree.MissionGroup
    if mg then
        return mg
    end
    return nil
end

function spawnMission(mis)

    local mg = Sim.spawnObject('SimGroup', '', 'MissionGroup', '', '')
    mg = scenetree.MissionGroup

    for k, v in pairs(mis) do
        -- spawnClass, spawnDataBlock, spawnName, spawnProperties, spawnScript
        local prop_str = ''
        for k2, v2 in pairs(v) do
            if k2 ~= 'class' then
                prop_str = prop_str .. k2 .."=\"" .. v2 .."\";"
            end
        end
        --print(prop_str)
        local obj = Sim.spawnObject(v.class, v.dataBlock or '', v.name or '', prop_str, '')
        mg:addObject(obj)
        --obj:setDataField('collisionType', '', 'Collision Mesh')
    end
end

function reloadMission()
    local mis = getMission()

    -- delete it :D
    deleteObject('ClientMissionCleanup')
    deleteObject('MissionCleanup')
    deleteObject('MissionGroup')

    -- then spawn again
    spawnMission(mis)
end


function spawnTest()
    local mg = scenetree.MissionGroup
    if not mg then
        mg = Sim.spawnObject('SimGroup', '', 'MissionGroup', '', '')
        mg = scenetree.MissionGroup
    end
    
    local obj = Sim.spawnObject('TSStatic', '', '', 'shapeName = "levels/GridMap/art/shapes/misc/gm_bump.dae";position = "0 0 0";', '')
    mg:addObject(obj)


    local shape = scenetree.TSStatic({shapeName='levels/GridMap/art/shapes/misc/gm_bump.dae', position={0,0,0}})
end




function test()

    local tbl = {}
    if scenetree.sunsky then
        tbl = scenetree.sunsky
        dump(tbl)
        if tbl.className == 'ScatterSky' then
            print("Azimuth: " .. tbl.obj:getAzimuth())
            --tbl.obj:setAzimuth(30)
            --print("Azimuth: " .. tbl.obj:getAzimuth())

            print("skyBrightness = " .. tbl.obj:getField('skyBrightness', 0))

            tbl.obj:setField('skyBrightness', 0, '80')
            
            print("skyBrightness = " .. tbl.obj:getField('skyBrightness', 0))
        end
        --tbl.obj:delete()
    end

    --print("LI = " .. tostring(li))
    --li = Sim.simObjectToLevelInfo(li)
    --print("LI = " .. tostring(li))
    --print("mWorldSize = " .. tostring(li.mWorldSize))
end

function tests()
    t3d_unittests()
end


function onBeamNGTrigger(args)
    --print('onBeamNGTrigger')
    --dump(args)

    local t = {msg = 'Trigger "' .. args.triggerName .. '" : ' .. args.event, time = 1}
    local js = 'HookManager.trigger("Message",' .. encodeJson(t) .. ')'
    --print(js)
    be:executeJS(js, 0)
end


prefab = {}
prefab.spawn = function(filename)
    local s = 'fileName = "' .. filename .. '";'
    s = s .. 'loadMode = "Manual";'
    s = s .. 'position = "0 0 0";'
    s = s .. 'rotation = "1 0 0 0";'
    s = s .. 'scale = "1 1 1";'
    s = s .. 'canSave = "0";'
    s = s .. 'canSaveDynamicFields = "0";'
    
    local mg = scenetree.MissionGroup
    if not mg then
        print("unable to load prefab: unable to find mission group")
        return false
    end

    local obj = Sim.spawnObject('Prefab', '', '', s, '')
    mg:addObject(obj)
    return obj
end

local loaded_prefabs = {}

function startActivity(mission, activities, activityType)
    local mg = scenetree.MissionGroup
    if not mg then
        Sim.spawnObject('SimGroup', '', 'MissionGroup', '', '')
    end
    -- search for the fitting entry
    for k, v in pairs(activities) do
        if v.type == activityType then
            dump(activityType)
            for k2, v2 in pairs(v.prefabs) do
                local prefab_fn = path.dirname(mission) .. '/' .. v2
                dump(prefab_fn);
                local o = prefab.spawn(prefab_fn)
                if o ~= nil then
                    o.load()
                    table.insert(loaded_prefabs, o)
                else
                    print("unable to load prefab: " .. prefab_fn)
                end
            end
        end
    end
end

function tft()
    clientStartMission('levels/industrial/industrial.mis')
end

function clientStartMission(mission)
    
    print("LUA >> clientStartMission: " .. mission)
    print("LUA >> dirname: " .. path.dirname(mission))

    local activities_fn = path.dirname(mission) .. '/activities.json'
    if path.is_file(activities_fn) then
        local content = readFile(activities_fn)
        if content ~= nil then
            local state, activities = pcall(json.decode, content)
            startActivity(mission, activities, 'freeroam')
        end
    end
    
    
end
function clientEndMission(mission)
    print("LUA >> clientEndMission: " .. mission)
end
