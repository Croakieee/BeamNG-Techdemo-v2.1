-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Settings:

-- enables/disables it
local RemoteController_Enabled = false

-- Settings END, please do not change anything below
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


local M = {}

local udpSocket = nil
local receive_sockets = {}

local ffi = require("ffi")
ffi.cdef[[
typedef struct { float x, y, z; } ori_t;
]]

local function nop()
end

local function init()
    if socket == nil or not RemoteController_Enabled then
        return
    end
    udpSocket = socket.udp()
    if udpSocket:setsockname('*', 3000) == nil then
        logError("Unable to open UDP Socket")
        udpSocket = nil
        return false
    end
    --ip, port = udpSocket:getsockname() 
    udpSocket:settimeout(0)
    receive_sockets[0] = udpSocket
    print("Remote Controller started")
end

local function updateGFX()
    local data, ip, port = udpSocket:receivefrom(128)
    if not data then
        return
    end
    --udpSocket:setpeername(ip, port)
    --print("got '" .. data .. "' from "..ip .. ":" .. port)
    if (data:sub(0, 10) == 'BEAMNGEDD1') then
        print("Got discovery package")
        udpSocket:sendto("EHLO", ip, port)
        goto continue
    elseif (data:sub(0,3) == "ORI") then
        local orientation = ffi.new("ori_t")
        ffi.copy(orientation, data:reverse(), ffi.sizeof(orientation)) -- notice the reverse - for the network endian byte order
        --print("Got input package")
        --print("Orientation: "..math.floor(orientation.x * 100)..", "..math.floor(orientation.y*100)..", "..math.floor(orientation.z*100))

        local steer_lua = "input.event('axisx0', " .. (-orientation.z) .. ", 2);" -- steering
        steer_lua = steer_lua .. "input.event('axisy0', " .. orientation.y .. ", 2);" -- accelerate
        steer_lua = steer_lua .. "input.event('axisy1', " .. (-orientation.y) .. ", 2);" -- brake

        -- TODO: broadcast only to the active object, not all ;)
        objectBroadcast(steer_lua)
    end
    ::continue::
end

M.updateGFX = updateGFX

local function init()
    if socket == nil or not RemoteController_Enabled then
        M.updateGFX = nop
    else
        udpSocket = socket.udp()
    end
end

-- public interface
M.init   = init

return M