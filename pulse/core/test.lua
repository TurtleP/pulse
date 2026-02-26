local path = (...):gsub("test", "")
local Result = require(path .. "result")

local Test = {}
Test.__index = Test

function Test.new(module, name, callback, ...)
    callback = callback or function() return true end
    local co = coroutine.create(callback)
    local argv = { ... }

    local self = setmetatable({}, Test)

    self.module = module
    self.name = name
    self.args = argv
    self.co = co
    self.started = false
    self.skipped = false
    self.start_time = 0
    self.duration = 0

    return self
end

function Test:getResult()
    if self.skipped then
        return Result.SKIPPED
    elseif self.error then
        return Result.FAILED
    end
    return Result.OK
end

function Test:getError()
    return self.error
end

function Test:getDuration()
    return self.duration
end

function Test:step()
    if coroutine.status(self.co) == "dead" then return true end
    local ok, err = coroutine.resume(self.co, unpack(self.args))
    if not ok then
        if type(err) == "table" and err.skip then
            self.error = err.reason
            self.skipped = true
        else
            self.error = err
        end
    end
    return self.error ~= nil or coroutine.status(self.co) == "dead"
end

function Test:getModule()
    return self.module
end

function Test:getName()
    return self.name
end

function Test:__tostring()
    local module = self.module and ("%s."):format(self.module) or ""
    return ("%s%s"):format(module, self.name)
end

return setmetatable(Test, {
    __call = function(_, module, name, callback, ...)
        return Test.new(module, name, callback, ...)
    end
})
