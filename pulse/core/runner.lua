local Result = require("pulse.core.result")
local Registry = require("pulse.core.registry")

local reporters = require("pulse.reporters")

local Runner = {}
Runner.__index = Runner

function Runner.init(config)
    local self = setmetatable({}, Runner)

    config = config or {}
    local filter = {}

    if type(config) == "string" then
        directory = config
    elseif type(config) == "table" then
        self.color = config.color or false
        directory  = config.directory or "tests"
        filter     = config.filter or {}
    end

    self.reporters = {}
    local config_reporters = config.reporters or { "console" }
    for _, reporter in ipairs(config_reporters) do
        self.reporters[#self.reporters + 1] = reporters[reporter](self.color)
    end

    self.passed = {}
    self.failed = {}
    self.skipped = {}

    self.started = false
    self.start_time = 0

    self.registry = Registry(directory, filter)
    self.tests = self.registry:scan()

    return self
end

function Runner:emit(event, ...)
    for _, reporter in ipairs(self.reporters) do
        local handler = reporter[event]
        if handler then
            handler(reporter, ...)
        end
    end
end

function Runner:step()
    local test = self.tests[1]
    if not test then
        self.duration = love.timer.getTime() - self.start_time
        self:emit("onRunEnd", self:getResults(), self.failed)
        return true
    end

    if not test.started then
        self:emit("onTestStarted", test)
        test.start_time = love.timer.getTime()
        test.started = true
    end

    local finished = test:step()
    if not finished then return false end

    local result = test:getResult()

    local t = result == Result.OK and self.passed or self.failed
    if result == Result.SKIPPED then t = self.skipped end
    t[#t + 1] = test

    table.remove(self.tests, 1)
    self:emit("onTestFinished", test)
    test.duration = love.timer.getTime() - test.start_time
    return false
end

function Runner:run()
    self:emit("onRunStart", self.tests)
    self.start_time = love.timer.getTime()

    local exit_code = 0
    while true do
        local done = self:step()
        if done then break end
    end
    love.event.quit(exit_code)
end

function Runner:getResults()
    return {
        passed = self.passed,
        failed = self.failed,
        skipped = self.skipped,
        duration = self.duration
    }
end

return setmetatable(Runner, {
    __call = function(_, config)
        return Runner.init(config)
    end
})
