-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.guiState = {}

local cache = {}
local active = 1
local timer = 0

local function activated(mode)
    active = mode
end

local function send(key, value)
    if active == 0 then return end
    cache[key] = value
end

local function updateGFX(dt)
    timer = timer + dt
    if timer > 1/20 then
        timer = timer % (1/20)
    else
        return
    end
    if active == 0 then return end
    obj:executeJS("if (typeof oUpdate == 'function') oUpdate("..encodeJson(cache)..");", 0)
    cache = {}
end

local function reset()
    cache = {}
end

local moduleLookupTable = {
    debug = 'bdebug'
}

local function gotUpdate(state)
    M.guiState = state
    --dump(state)
    for _,m in pairs(state['changes']) do
        for k,v in pairs(state[m]) do
            if _G[m] ~= nil and _G[m][k] ~= nil then
                _G[m][k] = v
            else
                logError("variable not found: " .. m .. "." .. k)
            end
        end
        if _G[m] ~= nil and _G[m]['guiUpdate'] ~= nil then
            _G[m]['guiUpdate']()
        else
            logError('function guiUpdate on module ' .. tostring(m) .. ' not found')
        end
    end
end

local function message(msg, ttl, category)
    if active == 0 then return end
    ttl = ttl or 5
    category = category or ''
    obj:executeJS("HookManager.trigger('Message', "..encodeJson({msg=msg, ttl=ttl, category=category})..");", 0)
    --print(msg)
end

local function onDeserialized()
end

-- public interface
M.updateGFX = updateGFX
M.reset = reset
M.send = send
M.activated = activated
M.gotUpdate = gotUpdate
M.onDeserialized = onDeserialized
M.message = message

return M