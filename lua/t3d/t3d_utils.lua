-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local function testPoint3F()
    local p1 = Point3F(1,2,3)
    assert(tostring(p1) == "1.000000,2.000000,3.000000", "Point3F: constructor failed")
    assert(math.abs(p1:lenSquared() - 14) < 0.000001, "Point3F:lenSquared failed")

    local p2 = Point3F(3,2,1)
    p2:neg()
    assert(tostring(p2) == "-3.000000,-2.000000,-1.000000", "Point3F:neg failed")

    -- todo: test asPoint2F
    
    p2:set(5,6,7)
    assert(tostring(p2) == "5.000000,6.000000,7.000000", "Point3F:set failed")

    p2:setAll(8)
    assert(tostring(p2) == "8.000000,8.000000,8.000000", "Point3F:setAll failed")

    p2:zero()
    assert(tostring(p2) == "0.000000,0.000000,0.000000", "Point3F:zero failed")

    p2 = Point3F(3,2,1)
    p2:normalize()
    assert(tostring(p2) == "0.801784,0.534522,0.267261", "Point3F:normalize failed")

    p2 = Point3F(3,2,1)
    p2:normalizeSafe()
    assert(tostring(p2) == "0.801784,0.534522,0.267261", "Point3F:normalizeSafe failed")

    p1 = Point3F(1,2,3)
    p2 = Point3F(5,6,7)
    assert(tostring(p1+p2) == "6.000000,8.000000,10.000000", "Point3F:operator+ failed")

    assert(tostring(p1-p2) == "-4.000000,-4.000000,-4.000000", "Point3F:operator- failed")

    p2 = Point3F(5,6,7)
    assert(tostring(-p2) == "-5.000000,-6.000000,-7.000000", "Point3F:-operator failed")

    p1 = Point3F(1,2,3)
    p2 = Point3F(5,6,7)
    assert(tostring(p1*p2) == "5.000000,12.000000,21.000000", "Point3F:operator* failed")

    assert(tostring(p1/p2) == "0.200000,0.333333,0.428571", "Point3F:operator/ failed")

    p1 = Point3F(1,2,3)
    p2 = Point3F(1,2,3)

    assert(p1 == p2, "Point3F:operator== failed")
end

--TODO's:

-- integrate Lui's actual setField/getField (actual calls commented out right now)
-- support callbacks/events from the c++ side, i.e. 

--scenetree.sunsky.onDelete = function(...) 
-- do something on delete
--end

--function eventHandler(object, action, parameters)
--scenetree['k'][v[1]](v[2])
--end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- this is the wrapper lua 'class' that wraps around the SimObject table that is returned by the C side
SimObjectWrapper = {}

-- is called when unknown keys are used: print(foo.unknownKey)
SimObjectWrapper.__index = function(class_table, memberName)
    --print('__index('..tostring(class_table) .. ', ' .. tostring(memberName)..')')
    --dump(class_table)
    -- 1. deal with methods on the actual lua object: like get/set below
    if getmetatable(class_table)[memberName] then
        --print(' __index case 1')
        return getmetatable(class_table)[memberName]
    end
    -- 2. deal with methods on the c++ object: i.e. wrapper.obj:delete()
    if type(class_table.obj[memberName]) == 'function' then
        --print(' __index case 2')
        -- This is a function of the C object, so pass it along in a wrapped function.
        -- We need to exchange the first argument with the userdata C object when calling it as it would find the table of the wrapper otherwise
        return function(...)
                local args = {...}
                args[1] = class_table.obj
                -- call the real C function with the fixed args
                return class_table.obj[memberName](unpack(args))
            end
    end
    -- 3. is it a field by chance, if yes, return it
    --print(' __index case 3')
    local field_res = getmetatable(class_table).get(class_table, memberName)
    if field_res then return field_res end

    -- 4. an object on the plain lua object table?
    --print(' __index case 4')
    return rawget(class_table, memberName)
end

-- is called when assignment are happening: foo.bar = 3
SimObjectWrapper.__newindex = function(class_table, memberName, value)
    --print('__newindex('..tostring(class_table) .. ', ' .. tostring(memberName)..')')
    -- 1. if a field, use set on the c object
    if getmetatable(class_table).set(class_table, memberName, value) then return end
    -- 2. never, ever use rawset to change the wrapper table data.
    -- This can lead to the problem that the lua side creates attributes that are
    -- meant to be used from the c side but not  existing.
    -- Additionally, this means that __index may not be 'enforce called' anymore.
    return
end

-- getter for Simobject fields
function SimObjectWrapper:get(key)
    --print("get: " .. tostring(self) .. ', '..tostring(key))
    --dump(self)
    local fields = rawget(self, 'fields')
    if not fields or not fields[key] then
        -- we refresh the field list whenever we hit an unknown field name
        fields = Lua:getSimobjectFieldList(self.obj)
        rawset(self, 'fields', fields)
    end
    if fields and fields[key] ~= nil and type(self.obj.getField) == 'function' then
        return self.obj:getStaticDataFieldbyIndex( fields[key], 0 )
    end    
    return self.obj:getDynDataFieldbyName( key, 0 )
end

-- setter for simobject fields
function SimObjectWrapper:set(key, value)
    --print("set: " .. tostring(self) .. ', '..tostring(key).. ', '..tostring(value))
    --dump(self)
    local fields = rawget(self, 'fields')
    if not fields or not fields[key] then
        -- we refresh the field list whenever we hit an unknown field name
        fields = Lua:getSimobjectFieldList(self.obj)
        rawset(self, 'fields', fields)
    end
    if fields and fields[key] ~= nil and type(self.obj.getField) == 'function' then
        self.obj:setStaticDataFieldbyIndex( fields[key], 0, value) -- no table required for value, directly pass it
        return true
    end
    return self.obj:setDynDataFieldbyName( key, 0, value )
end

-- constructor for the wrapper
function SimObjectWrapper.create(value_table)
    value_table = value_table or {}
    setmetatable(value_table, SimObjectWrapper)
    return value_table
end

-- SimObjectWrapper END
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Scenetree START
scenetree = {}

-- allows users to find Objects via name: scenetree.findObject('myname')
scenetree.findObject = function(objectName)
    local res_table = {}
    if Lua:findObjectByNameAsTable(objectName, res_table) then
        return SimObjectWrapper.create(res_table)
    end
    return nil
end

-- TODOs:
--  - a way to get all objects
--  - a way to get all objects of a certain class (TimeOfDay) for example

-- used on scenetree object lookups
scenetree.__index = function(class_table, memberName)
    --print('scenetree.__index('..tostring(class_table) .. ', ' .. tostring(memberName)..')')
    --dump(class_table)
    -- 1. deal with methods on the actual lua object: like get/set below
    if getmetatable(class_table)[memberName] then
        return getmetatable(class_table)[memberName]
    end
    -- 2. use findObject to collect the object otherwise
    -- TODO: cache the object!
    return getmetatable(class_table).findObject(memberName)
end
-- the scenetree is read only
scenetree.__newindex = function(...) end -- disallow any assignments
-- scenetree is a singleton, no more than one 'instance' at any time, so hardcode the creation
scenetree = setmetatable({}, scenetree)

-- Scenetree END
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------




-- tests from thomas
-- TODO: convert to proper unit-tests :)
function tf()
    -- scenetree tests:
    print("scenetree - test #1 = " .. tostring(scenetree.sunsky.shadowDistance))
    print("scenetree - test #2 = " .. tostring(scenetree.sunsky:getDeclarationLine()))
    print("scenetree - test #3 = " .. tostring(scenetree['sunsky']:getDeclarationLine()))

    -- manually find the object, working around scenetree
    local obj = scenetree.findObject('sunsky')
    --dump(obj)
    
    -- getter tests
    print("-getter tests")
    print("shadowDistance - getter #1 = " .. tostring(obj.shadowDistance))
    print("shadowDistance - getter #2 = " .. tostring(obj['shadowDistance']))
    print("shadowDistance - getter #3 = " .. tostring(obj:get('shadowDistance')))
    if obj.shadowDistanceNonExisting == nil then
        print("shadowDistance - getter #4 is nil ")
    else
        print("shadowDistanceNonExisting - getter #4 ERROR = " .. tostring(obj.shadowDistanceNonExisting))
    end

    -- setter tests
    print("-setter tests")
    obj:set('shadowDistance', 123)
    obj.shadowDistance = 123
    obj['shadowDistance'] = 123

    -- usage tests
    print("-usage tests")
    print(">> shadowDistance = " .. tostring(obj.shadowDistance))
    obj.shadowDistance = 123
    print(">> shadowDistance = " .. tostring(obj.shadowDistance))
    
    -- testing protected fields [canSave]
    print("-protected fields tests")    
    print(">> canSave = " .. tostring(obj.canSave))
    print(">> canSave set to false")
    obj.canSave = false
    print(">> canSave = " .. tostring(obj.canSave))
    obj.canSave = true
    print(">> canSave set to true")
    
    -- test if function to object forwarding works:
    --print(obj:getDataFieldbyIndex(0, 0, 0))
    print(obj:getDeclarationLine())
    --obj:delete(1,2,3, Point3F(1,2,3), "test")
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function test_T3D_fields()

    SimFieldTestObject("TestObj")
    local obj = scenetree.findObject('TestObj')
    --dump(obj)
    
    value_s32 = -5
    obj.staticFieldS32 = value_s32
    assert( obj.staticFieldS32 == value_s32 )
    obj.protectedFieldS32 = value_s32
    assert( obj.protectedFieldS32 == value_s32 )
    obj.dynFieldS32 = value_s32
    assert( obj.dynFieldS32 == value_s32 )
    
    local value_f32 = -33.330000000000
    obj.staticFieldF32 = value_f32
    assert( math.abs(obj.staticFieldF32 - value_f32) < 0.0001 )
    obj.protectedFieldF32 = value_f32
    assert( math.abs(obj.protectedFieldF32 - value_f32) < 0.0001 )
    obj.dynFieldF32 = value_f32
    assert( math.abs(obj.dynFieldF32 - value_f32) < 0.0001 )
    
    local value_f64 = -66.660000000000
    obj.staticFieldF64 = value_f64
    assert( math.abs(obj.staticFieldF64 - value_f64) < 0.0001 )
    obj.protectedFieldF64 = value_f64
    assert( math.abs(obj.protectedFieldF64 - value_f64) < 0.0001 )
    obj.dynFieldF64 = value_f64
    assert( math.abs(obj.dynFieldF64 - value_f64) < 0.0001 )
    
    value_cstring = "CString"
    obj.staticFieldCString = value_cstring
    assert( obj.staticFieldCString == value_cstring )
    obj.protectedFieldCString = value_cstring
    assert( obj.protectedFieldCString == value_cstring )
    obj.dynFieldCString = value_cstring
    assert( obj.dynFieldCString == value_cstring )
        
    value_string = String("String")
    obj.staticFieldString = value_string
    assert( obj.staticFieldString == value_string )
    obj.protectedFieldString = value_string
    assert( obj.protectedFieldString == value_string )
    obj.dynFieldString = value_string
    assert( obj.dynFieldString == value_string )
    
    obj.staticFieldSimObjectPtr = obj
    assert( obj.staticFieldSimObjectPtr.staticFieldString == obj.staticFieldString )
    obj.protectedFieldSimObjectPtr = obj
    assert( obj.protectedFieldSimObjectPtr.staticFieldString == obj.staticFieldString )
    obj.dynFieldSimObjectPtr = obj
    assert( obj.dynFieldSimObjectPtr.staticFieldString == obj.staticFieldString )
    
    obj:delete()
end
