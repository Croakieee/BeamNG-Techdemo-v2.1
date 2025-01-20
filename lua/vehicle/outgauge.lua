-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Settings:

-- enables/disables OutGauge
local OutGauge_Enabled = false
-- the IP Address of the OutGauge Device
local OutGauge_IP    = '192.168.1.100'
-- the port to use
local OutGauge_Port  = 4444
-- delay in 100 ms
local OutGauge_Delay = 1

-- Settings END, please do not change anything below
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local M = {}

local lastTime = 100000
local timer = 0

local ffi = require("ffi")

-- teh documentation can be found at LFS/docs/InSim.txt
ffi.cdef[[
typedef struct outgauge_t  {
    unsigned       time;            // time in milliseconds (to check order)
    char           car[4];          // Car name
    unsigned short flags;           // Info (see OG_x below)
    char           gear;            // Reverse:0, Neutral:1, First:2...
    char           plid;            // Unique ID of viewed player (0 = none)
    float          speed;           // M/S
    float          rpm;             // RPM
    float          turbo;           // BAR
    float          engTemp;         // C
    float          fuel;            // 0 to 1
    float          oilPressure;     // BAR
    float          oilTemp;         // C
    unsigned       dashLights;      // Dash lights available (see DL_x below)
    unsigned       showLights;      // Dash lights currently switched on
    float          throttle;        // 0 to 1
    float          brake;           // 0 to 1
    float          clutch;          // 0 to 1
    char           display1[16];    // Usually Fuel
    char           display2[16];    // Usually Settings
    int            id;              // optional - only if OutGauge ID is specified
} outgauge_t;
]]

--[[
CONSTANTS
// OG_x - bits for OutGaugePack Flags
#define OG_SHIFT      1        // key
#define OG_CTRL       2        // key
#define OG_TURBO      8192     // show turbo gauge
#define OG_KM         16384    // if not set - user prefers MILES
#define OG_BAR        32768    // if not set - user prefers PSI

// DL_x - bits for OutGaugePack DashLights and ShowLights
DL_SHIFT,           // bit 0    - shift light
DL_FULLBEAM,        // bit 1    - full beam
DL_HANDBRAKE,       // bit 2    - handbrake
DL_PITSPEED,        // bit 3    - pit speed limiter
DL_TC,              // bit 4    - TC active or switched off
DL_SIGNAL_L,        // bit 5    - left turn signal
DL_SIGNAL_R,        // bit 6    - right turn signal
DL_SIGNAL_ANY,      // bit 7    - shared turn signal
DL_OILWARN,         // bit 8    - oil pressure warning
DL_BATTERY,         // bit 9    - battery warning
DL_ABS,             // bit 10   - ABS active or switched off
DL_SPARE,           // bit 11
]]--

local OG_KM = 16384
local OG_BAR = 32768

local DL_FULLBEAM  = 2^1
local DL_HANDBRAKE = 2^2
local DL_SIGNAL_L  = 2^5
local DL_SIGNAL_R  = 2^6

local function nop()
end

local udpSocket = nil

local function updateGFX(dt)
    lastTime = lastTime + dt
    if lastTime < OutGauge_Delay / 10 then
        return
    end
    lastTime = lastTime - OutGauge_Delay / 10
    timer    = timer + dt
    if timer > 36000 then
        timer = 0
    end

    local o = ffi.new("outgauge_t")
    -- set the values
    o.time     = math.floor(timer*1000)
    o.car      = "beam"
    o.flags    = OG_KM + OG_BAR
    o.gear     = electrics.values.gear_M + 1 -- reverse = 0 here
    o.plid     = 0
    o.speed    = electrics.values.wheelspeed
    o.rpm      = electrics.values.rpm
    o.turbo    = 0 -- TODO
    o.engTemp  = electrics.values.watertemp
    o.fuel     = electrics.values.fuel
    o.oilPressure = 0 -- TODO
    o.oilTemp  = electrics.values.oiltemp

    -- the lights
    o.dashLights = bit.bor(o.dashLights, DL_FULLBEAM)
    if electrics.values.highbeam ~= 0 then
        o.showLights = bit.bor(o.showLights, DL_FULLBEAM)
    end
    o.dashLights = bit.bor(o.dashLights, DL_HANDBRAKE)
    if electrics.values.parkingbrake ~= 0 then
        o.showLights = bit.bor(o.showLights, DL_HANDBRAKE)
    end
    o.dashLights = bit.bor(o.dashLights, DL_SIGNAL_L)
    if electrics.values.signal_L ~= 0 then
        o.showLights = bit.bor(o.showLights, DL_SIGNAL_L)
    end
    o.dashLights = bit.bor(o.dashLights, DL_SIGNAL_R)
    if electrics.values.signal_R ~= 0 then
        o.showLights = bit.bor(o.showLights, DL_SIGNAL_R)
    end

    o.throttle = electrics.values.throttle
    o.brake    = electrics.values.brake
    o.clutch   = electrics.values.clutch
    o.display1 = "" -- TODO
    o.display2 = "" -- TODO
    o.id       = 0

    -- convert the struct into a string
    local packet = ffi.string(o, ffi.sizeof(o))

    -- send it
    udpSocket:sendto(packet, OutGauge_IP, OutGauge_Port)
end

M.updateGFX = updateGFX

local function init()
    if socket == nil or not OutGauge_Enabled then
        M.updateGFX = nop
    else
        udpSocket = socket.udp()
    end
end

-- public interface
M.init = init

return M