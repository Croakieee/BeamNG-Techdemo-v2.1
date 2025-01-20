-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

local function update()
    if not v.data.props then return end

    for propKey, prop in pairs (v.data.props) do
        if not prop.slotID then goto continue end

        
        local p = prop.propObj
        if not p then goto continue end

        -- disabled?
        if prop.disabled then 
            p.dataValue = 0
            goto continue
        end
        
        local val = electrics.values[prop.func]
        if val == nil then
          goto continue
        end

        -- that also toggles the lights
        p.dataValue = val
        
        -- respect the function multiplier, limits and offset
        val = val * prop.multiplier
        if val < prop.min then val = prop.min end
        if val > prop.max then val = prop.max end
        val = val + prop.offset
        prop.lastVal = val



        -- application of the value as rotation and translation
        p.rotation    = prop.rotation:scaleCopy(val)
        local lv = prop.translation:scaleCopy(val)
        p.translation = lv
        prop.lastTranslation = lv
        
        ::continue::
    end
end

local function reset()
    if not v.data.props then return end
    for propKey, prop in pairs (v.data.props) do
        prop.disabled = nil
        if prop.slotID then
            prop.propObj = obj:getProp(prop.slotID)
        end
    end
end


local function breakPropsInDeformGroup(deformGroup)
    if not v.data.props then return end

    for propKey, prop in pairs (v.data.props) do
        if prop.deformGroup == deformGroup then
            --print("prop broke: "..propKey)
            --dump(prop)
            prop.disabled = true
            prop.dataValue = 0
        end
    end
end

-- public interface
M.update = update
M.beamBroke = beamBroke
M.reset = reset
M.init = reset
M.breakPropsInDeformGroup = breakPropsInDeformGroup

return M