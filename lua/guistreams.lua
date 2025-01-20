-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local M = {}

M.wheelInfo = 0
M.engineInfo = 0
M.electrics = 0
M.stats = 0
M.sensors = 0

local function updateGFX()

    -- Wheelinfo --
    if M.wheelInfo > 0 then
        local wheelinfo = {}
        local avgWheelSpeed = 0
        local wheelCount = 0
        for i,wd in pairs(drivetrain.wheels) do
            if wd then
                local w = obj:getWheel(i)
                if w then
                    wheelinfo[i] = {
                          wd.name
                        , wd.radius
                        , wd.wheelDir
                        , w.angularVelocity
                        , w.lastTorque
                        , drivetrain.wheelInfo[wd.wheelID].lastSlip
                        , wd.lastTorqueMode
                        , drivetrain.wheelInfo[wd.wheelID].downForce
                    }
                    local wheelSpeed = w.angularVelocity * wd.radius * wd.wheelDir
                    wheelCount = wheelCount + 1
                    avgWheelSpeed = avgWheelSpeed + wheelSpeed
                end
            end
        end
        avgWheelSpeed = math.abs(avgWheelSpeed / wheelCount)
        gui.send('wheelInfo', wheelinfo)
    end

    -- Engineinfo --
    if M.engineInfo > 0 then
        local engineinfo = {}
        if v.data.engine ~= nil then
            engineinfo = {
                  v.data.engine.idleRPM
                , v.data.engine.maxRPM
                , v.data.engine.shiftUpRPM
                , v.data.engine.shiftDownRPM
                , drivetrain.rpm
                , drivetrain.gear
                , v.data.engine.fwdGearCount
                , v.data.engine.revGearCount
                , drivetrain.torque
                , drivetrain.torqueTransmission
                , obj:getVelocity():length()  -- airspeed
                , drivetrain.fuel
                , drivetrain.fuelCapacity
                , v.data.engine.transmissionType
            }
        end
        --dump(wheelinfo)
        gui.send('engineInfo', engineinfo)
    end

    -- Electrics --
    if M.electrics > 0 then
        gui.send('electrics', electrics.values)
    end

    -- Stats --
    if M.stats > 0 then
        local statsObj = obj:calcBeamStats()
        stats = {
            beam_count = statsObj.beam_count,
            node_count = statsObj.node_count,
            beams_broken = statsObj.beams_broken,
            beams_deformed = statsObj.beams_deformed,
            wheel_count = statsObj.wheel_count,
            total_weight = statsObj.total_weight,
            wheel_weight = statsObj.wheel_weight
        }
        gui.send('stats' , stats )
    end

    if M.sensors>0 then
    	local dirVector = obj:getDirectionVector()
    	local dirVectorUp = obj:getDirectionVectorUp()
    	local position = obj:getPosition()
        sensorvalues = {
            gx = sensors.gx,
            gy = sensors.gy,
            gz = sensors.gz,
            gx2 = sensors.gx2,
            gy2 = sensors.gy2,
            gz2 = sensors.gz2,
            gxMax = sensors.gxMax,
            gxMin = sensors.gxMin,
            gyMax = sensors.gyMax,
            gyMin = sensors.gyMin,
            gzMax = sensors.gzMax,
            gzMin = sensors.gzMin,
            ffb = hydros.lastFFBforce,
            ffb2 = hydros.lastFFBforce2,
            position = {
            	x = position.x,
            	y = position.y,
            	z = position.z
        	},
        	roll = dirVectorUp.x * -dirVector.y + dirVectorUp.y * dirVector.x,
        	pitch = dirVector.z,
        	yaw = obj:getDirection(),
        	gravity = Settings.gravity
        }
        gui.send('sensors' , sensorvalues )
    end

end

local function guiUpdate()
    --dump(M)
end

local function onDeserialized()
end

local function reset()
    M.wheelInfo = 0
    M.engineInfo = 0
    M.electrics = 0
    M.torqueCurve = 0
    M.stats = 0
    M.sensors = 0
end


-- public interface
M.reset = reset
M.updateGFX = updateGFX
M.guiUpdate = guiUpdate
M.onDeserialized = onDeserialized

return M