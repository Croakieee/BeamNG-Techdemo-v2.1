--[[

 JSON Encoder and Parser for Lua 5.1. Based on:
  
 Copyright © 2007 Shaun Brown (http://www.chipmunkav.com).
 All Rights Reserved.
 
 Permission is hereby granted, free of charge, to any person 
 obtaining a copy of this software to deal in the Software without 
 restriction, including without limitation the rights to use, 
 copy, modify, merge, publish, distribute, sublicense, and/or 
 sell copies of the Software, and to permit persons to whom the 
 Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be 
 included in all copies or substantial portions of the Software.
 If you find this software useful please give www.chipmunkav.com a mention.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
 ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 Usage:

 -- Lua script:
 local t = { 
    ["name1"] = "value1",
    ["name2"] = {1, false, true, 23.54, "a \021 string"},
    name3 = Json.Null() 
 }

 local json = Json.Encode (t)
 print (json) 
 --> {"name1":"value1","name3":null,"name2":[1,false,true,23.54,"a \u0015 string"]}

 local t = Json.Decode(json)
 print(t.name2[4])
 --> 23.54
 
 Notes:
 1) Encodable Lua types: string, number, boolean, table, nil
 2) Use Json.Null() to insert a null value into a Json object
 3) All control chars are encoded to \uXXXX format eg "\021" encodes to "\u0015"
 4) All Json \uXXXX chars are decoded to chars (0-255 byte range only)
 5) Json single line // and /* */ block comments are discarded during decoding
 6) Numerically indexed Lua arrays are encoded to Json Lists eg [1,2,3]
 7) Lua dictionary tables are converted to Json objects eg {"one":1,"two":2}
 8) Json nulls are decoded to Lua nil and treated by Lua in the normal way

--]]

local M = {}

local string = string
local table = table
local error = error
local tonumber = tonumber
local tostring = tostring
local type = type
local setmetatable = setmetatable

local JsonReader = {
    escapes = {
        ['t'] = '\t',
        ['n'] = '\n',
        ['f'] = '\f',
        ['r'] = '\r',
        ['b'] = '\b'
    }
}

function JsonReader:New(s)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.s = s
    self.slength = #self.s
    self.i = 0
    return o
end

function JsonReader:Peek()
    local i = self.i + 1
    if i <= self.slength then
        return self.s:sub(i, i)
    end
    return nil
end

function JsonReader:Next()
    self.i = self.i + 1
    if self.i <= self.slength then
        return self.s:sub(self.i, self.i)
    end
    return nil
end

function JsonReader:Match(pat)
    local res = self.s:match(pat, self.i)
    if res ~= nil then
        self.i = self.i + res:len()
    end
    return res
end

function JsonReader:Error(msg)
    local prevmatch = ''
    local curlen = 0
    local n = 1
    for w in self.s:gmatch("([^\n]*)") do
        curlen = curlen + #w
        if curlen >= self.i then
            error(string.format('%s at line: %d\nLast line was:\n%s',msg, n, w:match'^%s*(.*%S)' or ''))
        end
        if w == '' then 
            n = n + 1 
            curlen = curlen + 1
        end
    end
end

function JsonReader:Read()
    local peek = self:SkipWhiteSpace()
    self.i = self.i + 1
    if peek == '"' then
        return self:ReadString()    
    elseif peek == '{' then
        return self:ReadObject()
    elseif peek == '[' then
        return self:ReadArray()
    elseif string.find(peek, "[%+%-%d]") then
        return self:ReadNumber()        
    elseif peek == 't' then
        return self:ReadTrue()
    elseif peek == 'f' then
        return self:ReadFalse()
    elseif peek == 'n' then
        return self:ReadNull()
    elseif peek == '/' then
        self:ReadComment()
        return self:ReadNull()
    elseif peek == nil then
        self:Error('Nil string')
    else
        self:Error('Invalid input')
    end
end

function JsonReader:TestReservedWord(t)
    if self.s:sub(self.i, self.i + #t - 1) ~= t then
        self:Error(string.format("Error reading '%s'", t))
    end
    self.i = self.i + #t - 1
end

function JsonReader:ReadTrue()
    self:TestReservedWord('true')
    return true
end

function JsonReader:ReadFalse()
    self:TestReservedWord('false')
    return false
end

function JsonReader:ReadNull()
    self:TestReservedWord('null')
    return nil
end

function JsonReader:ReadNumber()
    self.i = self.i - 1
    local resultstr = self:Match("[%+%-%d%.eE]+")
    local result = tonumber(resultstr)
    local peek = self:Peek()
    -- 1.#INF00 support:
    if peek == "#" then
        resultstr = resultstr .. self:Next() -- #
        resultstr = resultstr .. self:Next() -- I
        resultstr = resultstr .. self:Next() -- N
        resultstr = resultstr .. self:Next() -- F
        resultstr = resultstr .. self:Next() -- 0
        resultstr = resultstr .. self:Next() -- 0
        if string.find(resultstr, "1#INF00") ~= nil then
            result = math.huge
        else
            self:Error(string.format("Invalid number: '%s'", resultstr))
        end
    end
    if result == nil then
        self:Error(string.format("Invalid number: '%s'", tostring(resultstr)))
    else
        return result
    end
end

function JsonReader:ReadString()
    local result = {""}
    while self:Peek() ~= '"' do
        local ch = self:Match('([^"\\]+)')
        if self:Peek() == '\\' then
            ch = self:Next()
            if self.escapes[ch] then
                ch = self.escapes[ch]
            end
        end
        table.insert(result, ch)
    end
    self.i = self.i + 1 -- "

    return table.concat(result)
end

function JsonReader:ReadComment()
    local second = self:Next()
    if second == '/' then
        self:ReadSingleLineComment()
    elseif second == '*' then
        self:ReadBlockComment()
    else
        self:Error('Invalid comment')
    end
end

function JsonReader:ReadBlockComment()
    local done = false
    while not done do
        local ch = self:Next()        
        if ch == '*' and self:Peek() == '/' then
            done = true
                end
        if not done and 
            ch == '/' and 
            self:Peek() == "*" then
                self:Error("Invalid comment ('/*' illegal)")
        end
    end
    self.i = self.i + 1
end

function JsonReader:ReadSingleLineComment()
    self:Match('[^\n]+')
    self.i = self.i + 1
end

function JsonReader:ReadArray()
    local result = {}
    local done = false
    if self:Peek() == ']' then
        done = true;
    end
    while not done do
        local item = self:Read()
        result[#result+1] = item
        if self:SkipWhiteSpace() == ']' then
            done = true
        end
    end
    self.i = self.i + 1 -- ]
    return result
end

function JsonReader:ReadObject()
    local result = {}
    local done = false
    if self:SkipWhiteSpace() == '}' then
        done = true
    end
    while not done do
        local key = self:Read()
        if type(key) ~= "string" and type(key) ~= "number" then
            self:Error(string.format("Invalid non-string Dictionary key: %s", tostring(key)))
        end
        local ch = self:SkipWhiteSpace()
        self.i = self.i + 1
        if ch ~= ':' then
            self:Error(string.format("Invalid Dictionary due to: '%s'",    ch))
        end
        self:SkipWhiteSpace()
        local val = self:Read()
        result[key] = val
        if self:SkipWhiteSpace() == '}' then
            done = true
        end
    end
    self.i = self.i + 1 -- }
    return result
end

function JsonReader:SkipWhiteSpace()
::restart::
    local nonspace = self.s:find("[^%s,]", self.i + 1)
    if nonspace == nil then    return nil end
    local p = self.s:sub(nonspace, nonspace)
    if p == '/' then
        self.i = nonspace
        self:ReadComment()
        if self.i > self.slength then return nil end
        goto restart
    else
        self.i = nonspace - 1
    end
    
    return p
end

local function decode(s)
    local reader = JsonReader:New(s)
    return reader:Read()
end

local function null()
    return null
end

-- public interface
M.decode = decode
M.null = null
return M