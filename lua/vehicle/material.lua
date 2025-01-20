-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

require("utils")
local M = {}

local triggers = {}

M.switches = {}

local switchMaterialCache = {}

local brokenSwitches = {}

-- really needs to be global as the particle filters use this
mv = {}

local function materialLoadStr(str, name)
    local f, err = loadstring("return function () " .. str .. " end", name or str)
    if f then return f() else return f, err end
end

local function init()
    if obj.mesh == nil then
        return
    end

    -- clean material cache
    switchMaterialCache = {}
    triggers = {}

    -- store the flexbody materials for later usage
    local flexmeshMats = {}
    v.data.flexbodies = v.data.flexbodies or {}

    for flexKey, flexbody in pairs(v.data.flexbodies) do
        local matNamesStr = obj.mesh:getMeshsMaterials(flexbody.mesh)
        --print("flexbody mesh '"..flexbody.mesh.."' contains the following materials: " .. matNamesStr)
        flexmeshMats[flexbody.mesh] = split(trim(matNamesStr)," ")
    end

    -- now the glow map
    if v.data.glowMap ~= nil then
        for orgMat, gm in pairs (v.data.glowMap) do
            --print("getSwitchableMaterial("..orgMat..")")
            local meshStr = obj.mesh:getMeshesContainingMaterial(orgMat)
            --print("[glowmap] meshes containing material " .. orgMat .. ": " .. tostring(meshStr))
            local meshes = split(trim(meshStr)," ")
            for meshi, mesh in pairs(meshes) do
                local gmat = deepcopy(gm)
                gmat.orgMat = orgMat
                
                if mesh == "" then goto continue end
                gmat.msc = obj.mesh:getSwitchableMaterial(orgMat, gm.off, mesh)
                if gmat.msc and gmat.msc >= 0 then
                    --dump(gmat)
                    switchMaterialCache[gmat.msc] = orgMat
                    local switchName = tostring(orgMat) .. "|"..tostring(mesh)
                    --print("[glowmap] created materialSwitch '"..switchName.."' [" .. tostring(gmat.msc) .. "] for material " .. tostring(orgMat) .. " on mesh " .. mesh)
                    gmat.mesh = mesh
                    M.switches[switchName] = gmat.msc
                    local fields = {}
                    if gm.simpleFunction then
                        local cmd = nil
                        if type(gm.simpleFunction) == 'string' then
                            cmd = "mv."..gm.simpleFunction..""
                            mv[gm.simpleFunction] = 0
                            if not triggers[gm.simpleFunction] then triggers[gm.simpleFunction] = {} end
                            table.insert(triggers[gm.simpleFunction], gmat)
                        elseif type(gm.simpleFunction) == 'table' then
                            --dump(gm.simpleFunction)
                            for fk, fc in pairs(gm.simpleFunction) do
                                mv[fk] = 0
                                local s = '(mv.'..fk..'*'..fc..')'
                                table.insert(fields, s)
                                mv[fk] = 0
                            end
                            cmd = "(" .. join(fields, " + ") .. ")"
                            --print(cmd)
                            --dump(gmat)

                            for fk, fc in pairs(gm.simpleFunction) do
                                if triggers[fk] == nil then triggers[fk] = {} end
                                --print("adding to triggers " .. fk)
                                table.insert(triggers[fk], gmat)
                            end
                        end
                        --if gm.limit then
                        --    cmd = 'math.min('..gm.limit..', ('..cmd..'))'
                        --end
                        cmd = "return "..cmd
                        --print (cmd)
                        gmat.evalFunction = materialLoadStr(cmd)

                    elseif gm.advancedFunction and gm.advancedFunction.triggers and gm.advancedFunction.cmd then
                        gmat.evalFunction = materialLoadStr(gm.advancedFunction.cmd)
                        for fk, fc in pairs(gm.advancedFunction.triggers) do
                            mv[fc] = 0
                            if not triggers[fc] then triggers[fc] = {} end
                            table.insert(triggers[fc], gmat)
                        end
                    end
                else
                    logError("[glowmap] failed to create materialSwitch '"..switchName.."' for material " .. tostring(k) .. " on mesh " .. tostring(mesh))
                end
                ::continue::
            end
        end
    end

    --print("###########################################################################")
    --dump(triggers)
    --dumpTableToFile(triggers, false, "triggers.js")
    --print("###########################################################################")
    -- and the deform groups
    local switchTmp = {}

    -- debug helper: list all materials on a mesh:
    --for flexKey, flexbody in pairs(v.data.flexbodies) do
    --    print("flexbody mesh '"..flexbody.mesh.."' contains the following materials: " .. obj.mesh:getMeshsMaterials(flexbody.mesh))
    --end

    for flexKey, flexbody in pairs(v.data.flexbodies) do
        if flexbody.deformGroup and flexbody.deformGroup ~= "" then

            --logInfo("found deformGroup "..flexbody.deformGroup.." on flexmesh " .. flexbody.mesh)
            local meshStr = obj.mesh:getMeshesContainingMaterial(flexbody.deformMaterialBase)
            --logInfo("[deformgroup] meshes containing material " .. flexbody.deformMaterialBase .. ": " .. tostring(meshStr))
            --logInfo("flexbody mesh '"..flexbody.mesh.."' contains the following materials: " .. obj.mesh:getMeshsMaterials(flexbody.mesh))


            for mati, matName in pairs(flexmeshMats[flexbody.mesh]) do
                if matName == "" then goto continue end
                local switchName = tostring(matName) .. "|" .. tostring(flexbody.mesh)
                local s = M.switches[switchName]
                if s == nil then
                    s = obj.mesh:getSwitchableMaterial(matName, matName, flexbody.mesh)
                    if s >= 0 then
                        --logInfo("[deformgroup] created materialSwitch '"..switchName.."' [" .. tostring(s) .. "] for material " .. tostring(matName) .. " on mesh " .. tostring(flexbody.mesh))
                    end
                else
                    --logInfo("[deformgroup] reused materialSwitch '"..switchName.."' [" .. tostring(s) .. "] for material " .. tostring(matName) .. " on mesh " .. tostring(flexbody.mesh))
                end
                if s and s >= 0 then
                    switchMaterialCache[s] = matName
                    M.switches[switchName] = s
                    if switchTmp[flexbody.deformGroup] == nil then
                        switchTmp[flexbody.deformGroup] = {}
                    end
                    table.insert(switchTmp[flexbody.deformGroup], {switch = s, dmgMat = flexbody.deformMaterialDamaged, mesh = flexbody.mesh, deformGroup = flexbody.deformGroup})
                else
                    logError("[deformgroup] failed to create materialSwitch '"..switchName.."' for material " .. tostring(matName) .. " on mesh " .. tostring(flexbody.mesh))
                end
                ::continue::
            end
        end
    end

    -- add flexmesh switches to beam of the same deform group
    if v.data.beams ~= nil then
        local assignStats = {}

        for i, beam in pairs (v.data.beams) do
            if beam.deformGroup and beam.deformGroup ~= "" then
                if switchTmp[beam.deformGroup] ~= nil then
                    for sk, sv in pairs(switchTmp[beam.deformGroup]) do
                        if beam.deformSwitches == nil then beam.deformSwitches = {} end
                        beam.deformSwitches[sv.switch] = sv
                        obj.mesh:switchMaterial(sv.switch, sv.dmgMat) -- preload dmg material
                        if assignStats[beam.deformGroup] == nil then assignStats[beam.deformGroup] = 0 end
                        assignStats[beam.deformGroup] = assignStats[beam.deformGroup] + 1
                    end
                else
                    logError("deformGroup on beam not found on any flexmesh: "..beam.deformGroup)
                end
            end
        end
        --logInfo("available deformGroups:")
        --for k, va in pairs (assignStats) do
        --    logInfo(" * " .. k .. " on " .. va .. " beams")
        --end
    end
    
    
    -- switch all the materials through their states to precompile the shaders so it doesnt lag when the material switches really
    for tk,tv in pairs(triggers) do
        for k,s in pairs(tv) do
            if s.on then
                obj.mesh:switchMaterial(s.msc, s.on)
            end
            if s.on_intense then
                obj.mesh:switchMaterial(s.msc, s.on_intense)
            end
            obj.mesh:resetMaterials(s.msc)
        end
    end
end

local function funcChanged(f, val)
    --print("funcChanged("..f..","..val)
    if not triggers[f] then return end
    if type(val) == "boolean" then val = val and 1 or 0 end
    -- only once
    if mv[f] == val then return end
    mv[f] = val
    -- switch the materials
    for f, vNotUsed in pairs(triggers) do
        for ka, va in pairs(triggers[f]) do
            --if not va.evalFunction then
            --    dump(va)
            --end
            --dump(mv)
            local localVal = va.evalFunction()
            if localVal == nil then return end -- TODO: error report

            --if type(localVal) == "boolean" then localVal = localVal and 1 or 0 end
            --print(localVal)
            --print("MAT: " .. f .. " = " .. tostring(localVal))
            if brokenSwitches[va.msc] == nil then
                if localVal < 0.01 then
                    obj.mesh:resetMaterials(va.msc)
                else
                    --dump(va)
                    if va.on_intense ~= nil then
                        -- we have sth with 2 glow layers
                        if localVal > 0.01 and localVal <= 0.5 then
                            --print("switchMaterial(" .. tostring(va.msc) .. ", '" .. tostring(va.on).."')")
                            obj.mesh:switchMaterial(va.msc, va.on)
                        elseif localVal > 0.5 then
                            --print("switchMaterial(" .. tostring(va.msc) .. ", '" .. tostring(va.on_intense).."')")
                            obj.mesh:switchMaterial(va.msc, va.on_intense)
                        end
                    else
                        -- only one 'on' state
                        --print("switchMaterial(" .. tostring(va.msc) .. ", '" .. tostring(va.on).."')")
                        obj.mesh:switchMaterial(va.msc, va.on)
                    end
                end
            end
        end
    end
end

local function switchBrokenMaterial(deformSwitches)
    for msc, g in pairs(deformSwitches) do
        --print("switchBrokenMaterial(" .. tostring(msc) .. ", '" .. tostring(newMat).."') ["..tostring(switchMaterialCache[msc]).. "]")
        --print("mesh broke: "..g.mesh.. " with deformGroup " .. g.deformGroup)
        props.breakPropsInDeformGroup(g.deformGroup)
        obj.mesh:switchMaterial(msc, g.dmgMat)
        brokenSwitches[msc] = true
    end
end

local function reset()
    for k,va in pairs(M.switches) do
        obj.mesh:resetMaterials(va)
    end

    brokenSwitches = {}
end

local function destroy()
    if obj.mesh == nil then
        -- if it failed to initialize correctly, there is nothing to be destroyed here
        return
    end    

    -- switch back all the materials
    for tk,tv in pairs(triggers) do
        for k,s in pairs(tv) do
            --print("switching material back to its original: "..s.msc.." -> ".. s.orgMat)
            obj.mesh:switchMaterial(s.msc, s.orgMat)
        end
    end

    -- and destroy the rest
    obj.mesh:destroyMaterials()
    M.switches = {}
    brokenSwitches = {}
    switchMaterialCache = {}
end

-- public interface
M.funcChanged = funcChanged
M.init = init
M.reset = reset
M.destroy = destroy
M.switchBrokenMaterial = switchBrokenMaterial

return M