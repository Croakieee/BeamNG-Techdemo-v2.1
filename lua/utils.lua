-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

-- utility things, big chaos

local inspect = require("inspect")

function dump(...)
    logAlways(inspect(...))
end

function dumps(...)
    return inspect(...)
end

function dumpToFile(filename, ...)
    local f = io.open(filename, "w")
    f:write(inspect(...))
    f:close()
end

function serializeJsonToFile(filename, obj)
    local f = io.open(filename, "w")
    f:write(encodeJson(obj))
    f:close()
end

function lpad(s, l, c)
    s = tostring(s)
    return string.rep(c, l - #s)..s
end

function saveG()
    dumpToFile("global_state.lua", _G)
end

function log(str)
    if (_disableLog) then return end
    logInfo(str)
end

function nop()
end


function updateGravity(v)
    Settings.gravity = v
    obj:requestReset(RESET_PHYSICS)
end

-- It logs and suppreses plain log messages
function logdev(str)
    log = nop
    logInfo(str)
end

function sign(n)
    if n > 0 then return 1 end
    if n < 0 then return -1 end
    return 0
end

local ExponentialSmoothing = {}
ExponentialSmoothing.__index = ExponentialSmoothing

local temporalSmoothing = {}
temporalSmoothing.__index = temporalSmoothing

local temporalSmoothingNonLinear = {}
temporalSmoothingNonLinear.__index = temporalSmoothingNonLinear

function newTemporalSmoothingNonLinear(inRate, outRate, autoCenterRate, startingValue)
    local data = {}
    setmetatable(data, temporalSmoothing)
    data.inRate = inRate
    data.outRate = outRate
    data.autoCenterRate = autoCenterRate
    data.state = startingValue
    data._startingValue = startingValue
    return data
end

function msgs(txt, t, name)
    t = t or 5
    if name == nil then
        BeamEngine:queueLuaCommand("msg('"..txt.."',"..t..")")
    else
        BeamEngine:queueLuaCommand("msg('"..txt.."',"..t..",'"..name.."')")
    end
end

function temporalSmoothingNonLinear:get(sample, dt)
    local rate
    local dir = (sample - self.state) * sign(self.state)

    -- autocentering
    if self.autoCenterRate ~= nil and sample == 0 then
        rate = self.autoCenterRate
    else
        if dir >= 0 then
            rate = self.outRate
        else
            rate = self.inRate
        end
    end

    ratio = 1 / (dt * rate)
    self.state = (sample + ratio * self.state) / (ratio + 1)

    return math.max(math.min(self.state, 1), -1)
end

function temporalSmoothingNonLinear:reset()
    self.state = self._startingValue
end

function newTemporalSmoothing(inRate, outRate, autoCenterRate, startingValue)
    local data = {}
    setmetatable(data, temporalSmoothing)
    data.inRate = inRate
    data.outRate = outRate
    data.autoCenterRate = autoCenterRate
    data.state = startingValue
    data._startingValue = startingValue
    return data
end

function temporalSmoothing:get(sample, dt)
    local rate
    local dir = (sample - self.state) * sign(self.state)

    -- autocentering
    if self.autoCenterRate ~= nil and sample == 0 then
        rate = self.autoCenterRate
    else
        if dir >= 0 then
            rate = self.outRate
        else
            rate = self.inRate
        end
    end

    if sample < self.state then
        self.state = math.max(self.state - dt * rate, sample)
    else
        self.state = math.min(self.state + dt * rate, sample)
    end

    return math.max(math.min(self.state, 1), -1)
end

function temporalSmoothing:reset()
    self.state = self._startingValue
end

-- creation method of the object, inits the member variables
function newExponentialSmoothing(window, startingValue)
    local data = {}
    setmetatable(data, ExponentialSmoothing)
    data.a = 2 / window
    data.samplePrev = 0
    data.stPrev = 0
    data.firstSample = true
    if startingValue then
        data:get(startingValue)
    else
        startingValue = 0
    end
    data._startingValue = startingValue

    return data
end

function ExponentialSmoothing:get(sample)
    if self.firstSample then
        self.firstSample = false
        self.stPrev = sample
        self.samplePrev = sample
        return sample
    end

    self.stPrev = self.stPrev + self.a * (self.samplePrev - self.stPrev)
    self.samplePrev = sample

    return self.stPrev
end

function ExponentialSmoothing:value()
    return self.stPrev
end

function ExponentialSmoothing:set(value)
    self.stPrev = value
    self.samplePrev = value
end

function ExponentialSmoothing:setWindow(window)
    self.a = 2 / window
end

function ExponentialSmoothing:reset(value)
    self.stPrev = self._startingValue
    self.samplePrev = self._startingValue
end

-- little snippet that enforces reloading of files
function rerequire(module)
    package.loaded[module] = nil
    m = require(module)
    if not m then
        logError(">>> Module failed to load: " .. tostring(module).." <<<")
    end
    return m
end

function readDictJSONTable(filename)
    if not json then json = require("json") end
    local state, data = pcall(json.decode, readFile(filename))
    for k,v in pairs(data) do
        for k2,v2 in pairs(v) do
            if k2 > 1 then
                -- re-add headers
                for i=1,#v[1],1 do
                    
                    v[k2][v[1][i]] = v[k2][i]
                    v[k2][i] = nil
                end
            end
        end
        v[1] = nil
    end
    --dump(data)
    return data
end

function toJSONString(d)
    if type(d) == "string" then
        return "\""..d.."\""
    elseif type(d) == "number" then
        return tostring(d)
    else
        return tostring(d)
    end
end

function saveCompiledJBeamRecursive(f, data, level)
    local indent = string.rep(" ", level*2)
    local columnSize = 20
    local nl = true
    if level > 2 then nl = false end
    if level > 3 then indent = "" end
    --f:write(level..indent
    f:write(indent)

    if type(data) == "table" and tableFirstKey(data) == "partOrigin" then
        f:write("\n"..indent.."/*"..string.rep("*", 50).."\n")
        f:write(indent .. " * part " .. tostring(data["partOrigin"]).."\n")
        f:write(indent .. " *"..string.rep("*", 49) .. "*/\n")
        f:write("\n"..indent)
    end
    
    if level > 2 then indent = "" end
    if type(data) == "table" then
        if tableIsDict(data) then
            f:write("{")
            if nl then f:write("\n") end
            local row = {}
            for k,v in pairs(data) do
                if type(v) == "table" then
                    f:write(indent..toJSONString(k).." : ")
                    --if nl then f:write("\n" end
                    saveCompiledJBeamRecursive(f, v, level + 1)
                    --if nl then f:write("\n" end
                else
                    if level > 3 then columnSize = 0 end
                    local txt = indent..tostring(joinKVES(columnSize,toJSONString(k), toJSONString(v)))
                    table.insert(row, txt)
                end
            end
            if tableSize(row) > 0 then
                if nl then
                    f:write(joinES(columnSize, row, ", \n"))
                else
                    f:write(joinES(columnSize, row, ", "))
                end
            end
            if nl then f:write("\n") end
            f:write(indent.."}, ")
            if level < 4 then f:write("\n") end
        else
            local nl = true
            if level > 2 then nl = false end
            f:write("[")
            if nl then f:write("\n") end
            local row = {}
            for i=1,#data,1 do
            --k,v in pairs(data) do
                local v = data[i]
                if type(v) == "table" then
                    saveCompiledJBeamRecursive(f, v, level + 1)
                else
                    local txt = toJSONString(v)
                    table.insert(row, txt)
                end
            end
            if tableSize(row) > 0 then
                f:write(joinES(columnSize, row, ", "))
            end
            f:write(indent.."], ")
            if level < 4 then f:write("\n") end
        end
    end
end

function saveCompiledJBeam(data, filename)
    local f = io.open(filename, "w")
    if f == nil then
        logError("unable to open file "..filename.." for writing")
        return false
    end
    saveCompiledJBeamRecursive(f, data, 0)
    f:close()
    return true
end

function readFile(filename)
    local f = io.open(filename, "r")
    if f == nil then
        return nil
    end
    local content = f:read("*all")
    f:close()
    return content
end

function writeFile(filename, data)
    local file, err = io.open(filename,"w")
    if file == nil then
        logError("Error opening file for writing: "..filename..": "..err)
        return nil
    end
    local content = file:write(data)
    file:close()
end

function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function tableIsDict(tbl)
    if type(tbl) ~= "table" then
        return false
    end
    for k, v in pairs (tbl) do
        return (k ~= 1)
    end
end

function arrayConcat(dst, src)
    table.foreach(src,function(i,v)table.insert(dst,v)end)
    return dst
end

function tableMerge(dst, src)
    for i,v in pairs(src) do
        if (type(v) ~= "function") then
            dst[i] = v;
        end
    end
    return dst
end

-- http://stackoverflow.com/questions/1283388/lua-merge-tables
function tableMergeRecursive(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                        tableMergeRecursive(t1[k] or {}, t2[k] or {})
                else
                        t1[k] = v
                end
        else
                t1[k] = v
        end
    end
    return t1
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function trimr(str, chrs)
  return str:match("(.-)["..chrs.."]*$")
end

-- Compatibility: Lua-5.0
function split(str, delim, maxNb)
    -- delim = delim or " "
    -- if delim == " " then
    --     str = trim(str)
    -- end
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb or lastPos < string.len(str) then
        result[nb + 1] = string.sub(str, lastPos)
    end
    --print('split str: "'.. str .. '", delim: "'..delim..'", nb: '..nb .. ', lastPos: '..lastPos.. ', strlen: ' .. string.len(str) .. ', maxNb: ' .. maxNb .. ', result: ' .. dumps(result))
    return result
end

function joinKVES(space, k, v)
  local diff = space - string.len(k)
  local str = (k) .. string.rep(" ", diff)
  str = str .. ": "
  local diff2 = space - string.len(v)
  if diff < 0 then diff2 = diff2 + diff end
  str = str .. v .. string.rep(" ", diff2)
  return str
end

-- join equally spaced
function joinES(space, list, delimiter)
  local diff = space - string.len(list[1])
  local str = list[1] .. string.rep(" ", diff)
  for i = 2, #list do 
    diff = space - string.len(list[i])
    str = str .. delimiter .. list[i] .. string.rep(" ", diff)
  end
  return str
end

function join(list, delimiter)
    return table.concat(list, delimiter)
end


function tableFirstKey(tbl)
    if type(tbl) ~= "table" then
        return ""
    end
    for k, v in pairs (tbl) do
        --logInfo("*** "..tostring(k).." = "..tostring(v).." ["..type(v).."]")
        return k
    end
end

function tableSize(tbl)
    if type(tbl) ~= "table" then
        return 0
    end
    local count = 0
    for _ in pairs (tbl) do
        count=count+1
    end
    return count
end

function _tableDepth(tbl, depth)
    if type(tbl) ~= "table" then
        return 0
    end
    for k, v in pairs (tbl) do
        if type(v) == "table" then
            return _tableDepth(v, depth + 1)
        end
    end
    return depth
end

function tableDepth(tbl)
    return _tableDepth(tbl, 0)
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- float3 conversion helpers
function tableToFloat3(v)
    if v == nil then
        return float3(0,0,0)
    end
    return float3(v.x, v.y, v.z)
end

function tableToFloat3Default(v, default)
    if v == nil then
        return default
    end
    return float3(v.x or default.x, v.y or default.y, v.z or default.z)
end

function float3ToTable(f)
    return {x=f.x, y=f.y, z=f.z}
end

function triLooksTowards(a, b, c, p)
    local acx = (a.x - c.x)
    local acy = (a.y - c.y)
    local acz = (a.z - c.z)
    local bcx = (b.x - c.x)
    local bcy = (b.y - c.y)
    local bcz = (b.z - c.z)

    return 
        (c.x - p.x) * (acy * bcz - acz * bcy) +
        (c.y - p.y) * (acz * bcx - acx * bcz) +
        (c.z - p.z) * (acx * bcy - acy * bcx)
end

-- color conversion helpers
function tableToColor(v)
    if v == nil then
        return color(0,0,0,0)
    end
end

function parseColor(v)
    if v == nil then
        return color(0,0,0,0)
    end
    if type(v) == 'table' then
        return color(v.r, v.g, v.b, v.a)
    elseif type(v) == 'string' and string.len(v) > 7 and v:sub(1,1) == '#' then
        v = v:gsub("#","")
        return color(tonumber("0x"..v:sub(1,2)), tonumber("0x"..v:sub(3,4)), tonumber("0x"..v:sub(5,6)), tonumber("0x"..v:sub(7,8)))
    end
end

-- safe table iteration functions: it will iterate the tables via a copy: "adding" to the tables will not change the iteration
function ipairs_safe(t)
    local new_table = {}
    for index, value in pairs(t) do
        new_table[index] = value
    end
    local function ipairs_safe_it(t, i)
        i = i + 1
        local v = t[i]
        if v ~= nil then
            return i,v
        else
            return nil
        end
    end
    return ipairs_safe_it, new_table, 0
end

function pairs_safe(t)
    local new_table = {}
    for index, value in pairs(t) do
        new_table[index] = value
    end
    local function pairs_safe_it(t, i)
        local k, v = next(t, i)
        if k ~= nil then
            return k,v
        else
            return nil
        end
    end
    return pairs_safe_it, new_table, nil
end

function CatMullRomSpline(points)
    if #points < 3 then return nil end
    local res = {}
    local p0, p1, p2, p3, x, steps
    for i = 1, #points - 1 do
        p0, p1, p2, p3 = points[math.max(i - 1, 1)], points[i], points[i + 1], points[math.min(i + 2, #points)]
        steps = p2[1] - p1[1]
        x = math.floor(p1[1])
        for t = 0, 1, 1/steps do
            res[x] = 0.5 * (
                  (2 * p1[2])
                + (    p2[2] -     p0[2]) * t
                + (2 * p0[2] - 5 * p1[2] + 4 * p2[2] - p3[2]) * t * t
                + (3 * p1[2] -     p0[2] - 3 * p2[2] + p3[2]) * t * t * t)
            x = x + 1
        end
        res[x] = p2[2]
    end
    return res
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function unrequire(m)
    package.loaded[m] = nil
    _G[m] = nil
end

function encodeJson(v)
    if v == nil then return "null" end

    local vtype = type(v)  

    -- Handle strings
    if vtype == 'string' then
        return string.format('%q', v)
    end

    -- Handle numbers and booleans
    if vtype == 'number' or vtype == 'boolean' then
        return tostring(v)
    end

    -- Handle tables
    if vtype == 'table' then
        local tmp = {}
        if next(v) ~= 1 then
            for kk, vv in pairs(v) do
                local cv = encodeJson(vv)
                if cv ~= nil then
                    -- no keys with nil as value, happens on functions
                    table.insert(tmp, string.format('"%s":%s', kk, cv))
                end
            end
            return string.format('{%s}', table.concat(tmp, ','))
        else
            for kk, vv in pairs(v) do
                table.insert(tmp, encodeJson(vv))
            end
            return string.format('[%s]', table.concat(tmp, ','))
        end
    end

    return nil
end

function serializeModules()
    local tmp = {}
    for k,v in pairs(package.loaded) do
        if type(v) == 'table' and v['onDeserialized'] ~= nil then
            tmp[k] = v
        end
    end
    return serialize(tmp)
end

function deserializeModules(data)
    for k,v in pairs(package.loaded) do
        --print("k="..tostring(k) .. " = " .. tostring(v))
        if type(v) == 'table' and v['onDeserialized'] ~= nil and data[k] ~= nil then
            tableMerge(v, data[k])
            v['onDeserialized']()
        end
    end
end

-- serialization functions, see testSerialization, be aware that you need to add custom datatypes in this in case you need them
-- serialized Lua
function serialize(val)
    if val == nil then
        return "nil"
    elseif type(val) == "table" then
        if val["_noSerialize"] then
            return
        end
        local tmp = {}
        if val["_serialize"] ~=nil and type(val["_serialize"]) == "table" then
            incl = val["_serialize"]
            for k, v in pairs(val) do
                if incl[k] then
                    local va = serialize(v)
                    if va ~= nil then
                        table.insert(tmp, k .. '=' .. va)
                    end
                end
            end
        else
            if next(val) ~= 1 then
                for k, v in pairs(val) do
                    local va = serialize(v)
                    if va ~= nil then
                        table.insert(tmp, k .. '=' .. va)
                    end
                end
            else
                for k, v in pairs(val) do
                    local va = serialize(v)
                    if va ~= nil then
                        table.insert(tmp, va)
                    end
                end
            end
        end
        return '{' .. table.concat(tmp, ',') ..'}'
    elseif type(val) == "number" then
        return tostring(val)
    elseif type(val) == "string" then
        return string.format("%q", val)
    elseif type(val) == "boolean" then
        return tostring(val)
    elseif type(val) == type(float3(0,0,0)) then
        -- float3 is special :)
        return string.format("float3%s", tostring(val))
    end
end

function unserialize(s)
    if s == nil then return nil end
    return loadstring("return " .. s)()
end

function testSerialization()
    d = {a = "foo", b = {c = 123, d = "foo", p = float3(1,2,3)}}
    print("original data: " .. tostring(d))
    dump(d)
    
    s = serialize(d)
    print("serialized data: " .. tostring(s))
    
    da = unserialize(s)
    print("restored data: " .. tostring(da))    
    dump(da)
    
    sa = serialize(da)
    if sa == s then
        print "serialization seems to work"
    else
        print "serialization got problems, look above"
    end
    
    if unserialize(serialize(nil)) ~= nil then print "serialize with nil fails to work corectly" end
end
--testSerialization()

-- calls a vehicle lua instance
function vehicleLua(objID, code)
    local b = BeamEngine:getSlot(objID)
    if b ~= nil then
        local future = b:queueLuaCommand("return serialize("..code..")", true)
        BeamEngine:update(1/2000) -- we step here, beware of the physics implications
        local resStr = b:getLuaResult(future)
        return unserialize(resStr)
    end
    return nil
end

--[[
   LUA 5.1 compatible
   
   Ordered Table
   keys added will be also be stored in a metatable to recall the insertion oder
   metakeys can be seen with for i,k in ( <this>:ipairs()  or ipairs( <this>._korder ) ) do
   ipairs( ) is a bit faster
   
   variable names inside __index shouldn't be added, if so you must delete these again to access the metavariable
   or change the metavariable names, except for the 'del' command. thats the reason why one cannot change its value
]]--
function newT( t )
   local mt = {}
   -- set methods
   mt.__index = {
      -- set key order table inside __index for faster lookup
      _korder = {},
      -- traversal of hidden values
      hidden = function() return pairs( mt.__index ) end,
      -- traversal of table ordered: returning index, key
      ipairs = function( self ) return ipairs( self._korder ) end,
      -- traversal of table
      pairs = function( self ) return pairs( self ) end,
      -- traversal of table ordered: returning key,value
      opairs = function( self )
         local i = 0
         local function iter( self )
            i = i + 1
            local k = self._korder[i]
            if k then
               return k,self[k]
            end
         end
         return iter,self
      end,
      -- to be able to delete entries we must write a delete function
      del = function( self,key )
         if self[key] then
            self[key] = nil
            for i,k in ipairs( self._korder ) do
               if k == key then
                  table.remove( self._korder, i )
                  return
               end
            end
         end
      end,
   }
   -- set new index handling
   mt.__newindex = function( self,k,v )
      if k ~= "del" and v then
         rawset( self,k,v )
         table.insert( self._korder, k )
      end      
   end
   return setmetatable( t or {},mt )
end

function getDirListing(pathname)
    if not FS:directoryExists('levels/') then
        return {}
    end
    local dir = FS:openDirectory('levels/')
    if not dir then
       return {}
    end 
    local files = {}
    while true do
        local filename = dir:getNextFilename()
        if not filename then break end
        table.insert(files, filename)
    end
    return files
end

function string.startswith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.endswith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end


path = {}
path.dirname = function (filename)
    while true do
        if filename == "" or string.sub(filename, -1) == "/" then
            break
        end
        filename = string.sub(filename, 1, -2)
    end
    if filename == "" then
        filename = "."
    end

    return filename
end

path.is_file = function (filename)
    local f = io.open(filename, "r")
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
end
