-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.config = {}

local partsChanged = false

local function save(fn)
    local file, err = io.open(fn, "w")
    if file then
        local s = serialize(v.userPartConfig)
        file:write(s)
        file:close()
    else
        logError("unable to open file for writing: "..fn)
    end
end

local function load(fn, guiMode, reload)
    local file, err = io.open(fn, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local args = unserialize(content)
        args.guiMode = guiMode
        setConfig(args, reload)
    else
        logError("unable to open file for reading: "..fn)
    end
end

function setConfig(args, reload)
    if tableSize(args) == 0 then return end

    -- TODO: fix it up properly that it does not require a reset
    -- the persistence-data is destroyed on the reset of this reset then which breaks the persistency :(
    M.config = args
    if reload == nil then reload = true end
    v.userPartConfig = args
    if reload then
        obj:requestReset(RESET_COMPLETELY)
        obj:requestReset(RESET_PHYSICS)
        partsChanged = true
    end
end

local function showGUI()
	obj:executeJS("window.location.href='/html/partmgmt.html';", 0)
end


local function doPartChanges()
    v:doPartChanges(obj)
    if v.userPartConfig.guiMode == 1 then
        showGUI()
    end
end

local function destroyed()
    if partsChanged == true then
        doPartChanges(obj)
        partsChanged = false
        return true
    end
    return false
end

local function selectPart(partName)
    -- only show that mesh
    obj.mesh:setAlpha(0.3, "", true)
    for flexKey, flexbody in pairs (v.data.flexbodies) do
        if flexbody.partOrigin == partName then
            obj.mesh:setAlpha(1, flexbody.mesh, false)
        end
    end
    if v.data.props then
	    for propKey, prop in pairs (v.data.props) do
            if prop.partOrigin == partName then
                obj.mesh:setAlpha(1, prop.mesh, false)
            end
        end
    end
end

local function selectReset()
    -- show all
    obj.mesh:setAlpha(1, "", false)
end



local function guiCallback(mode, str)
    --print("guiCallback("..tostring(mode)..","..tostring(str)..")")
    if not obj.mesh then return end
    if mode == "button" then
        local args = unserialize(str)
        local btnName = args.button
        if btnName == "resetBtn" then
            setConfig({})
        elseif btnName == "saveBtn" then
            local fn = args.saveBtn
            -- clean up the args
            args.button = nil
            args.saveBtn = nil
            args.loadBtn = nil
            args.resetBtn = nil
            -- set the config and then save
            setConfig(args, false)
            save(fn)
        elseif btnName == "loadBtn" then
            selectReset()
            load(args.loadBtn, 1)
        end
    elseif mode == "apply" then
        local args = unserialize(str)
        if args.DebugMode ~= nil then
            --bdebug.setMode(tonumber(args.DebugMode))
        end
        args.guiMode = 1
        if args.done ~= nil then args.guiMode = 0 end
        --dump(args)
        setConfig(args)
    elseif mode == "selectStart" then
        selectPart(str)
    elseif mode == "selectEnd" then
        selectReset()
    end
end

local function onDeserialized()
    --print("partmgmt.onDeserialized()")
    setConfig(M.config)
end


local function resetConfig()
    setConfig({})
end

local function getConfig()
    return {slotMap=v.slotMap, slotDescriptions=v.slotDescriptions}
end

-- public interface
M.destroyed = destroyed
M.save = save
M.load = load
M.selectPart = selectPart
M.selectReset = selectReset
M.showGUI = showGUI
M.guiCallback = guiCallback
M.setConfig = setConfig
M.onDeserialized = onDeserialized
M.resetConfig = resetConfig
M.getConfig = getConfig

return M