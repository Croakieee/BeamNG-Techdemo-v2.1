rerequire("lua/tests/test")

-- the vehicle to test with
local testVehicle = "vehicles/pickup/"
local physicsFPS  = 2000
local physicsSteps = 80 -- max physics steps do *NOT* increase beyond this point
local gfxSteps   = 15
local currentObjects = 0
local maxMbeams = 0
local version = "0.2"

function myBenchStep(n)
    -- delete everything
    -- spawn n vehicles
    for i=currentObjects + 1,n do
        BeamEngine:spawnObject(testVehicle, float3(3 * n, 3 * n, 3 * n)) -- this assumes that the object is max. 3 meters high
        currentObjects = currentObjects + 1
    end
    
    -- run the update loop and measure the total time

    local dt = (physicsSteps + 0.1)/ physicsFPS    
    local hp = HighPerfTimer()    
    for i=1,gfxSteps
    do
        BeamEngine:update(dt)
    end
    return hp:stop()
end

function myBenchPhysics(vehicleMin, vehicleMax)
    -- init
    BeamEngine:deleteAllObjects()
    BeamEngine:spawnObject(testVehicle, float3(0,3,0))
    currentObjects = 1
    local nodecount = vehicleLua(0, "#v.data.nodes")
    local beamcount = vehicleLua(0, "#v.data.beams")
    
    print("Beam ANAlysis NArrator, Version: " .. version)
    print("Test vehicle:  " .. testVehicle)
    -- test start
    for n=vehicleMin,vehicleMax,1
    do
        -- do a warmup round
        myBenchStep(n)
        io.write(lpad(n, 2, ' ') .. " vehicle")
        if n > 1 then
            io.write('s')
        else
            io.write(' ')
        end
        local totalTime = 0
        totalTime = totalTime + myBenchStep(n)
        io.write("  : ")
        totalTime = totalTime + myBenchStep(n)
        local totalSteps = physicsSteps * 2 * gfxSteps
        local totalBeams = totalSteps * beamcount * n
        local totalNodes = totalSteps * nodecount * n
        
        -- then calc the stats and output them
        local nodespersec = totalNodes / totalTime
        local beamspersec = totalBeams / totalTime
        maxMbeams = math.max(maxMbeams, beamspersec)
        if n == 0 then
            nodespersec = 0
            beamspersec = 0
        end
        io.write(" ")
        io.write(lpad(string.format("%0.3f", beamspersec / 1000), 6, ' ') .. " Mbeams/s, ")
        --io.write(string.format("%0.3f", nodespersec / 1000) .. " Mnodes/s, ")
        io.write(lpad(string.format("%0.2f", (100 * (1000/physicsFPS) * totalSteps)/ totalTime), 6, ' ').." % realtime")
        print("")
    end
end

-- myBenchPhysics(<min vehicles>, <max vehicles>)
myBenchPhysics(1,10)

print("Max Mbeams/s:   " .. string.format("%0.3f", maxMbeams / 1000) .. " Mbeams/s")
print("")
print(" BANANAA!!!")
print(" .______,# ")
print(" \\ -----'/ ")
print("  `-----' ")
