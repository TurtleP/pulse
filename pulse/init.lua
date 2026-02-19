--
-- pulse
-- Copyright (c) TurtleP
--

local pulse = { version = "0.1.0" }

local PATH = (...):gsub("[^%.]+$", "")

local function import(module)
    return require(PATH .. module)
end

local paths = love.filesystem.getRequirePath()

local function wait_seconds(seconds)
    local target = love.timer.getTime() + seconds
    repeat
        coroutine.yield()
    until love.timer.getTime() >= target
end

local function skip(reason)
    error({ skip = true, reason = reason or "Skipped" }, 2)
end

local function load()
    love.filesystem.setRequirePath(paths .. (";%s/?.lua"):format(PATH))

    local Core = import("pulse.core")
    for core_name, value in pairs(Core) do
        pulse[core_name] = value
    end

    local Reporters = import("pulse.reporters")
    for reporter_name, value in pairs(Reporters) do
        pulse[reporter_name] = value
    end

    local Utils = import("pulse.utils")
    for util_name, value in pairs(Utils)do
        pulse[util_name] = value
    end

    pulse.skip = skip
    pulse.wait_seconds = wait_seconds

    love.filesystem.setRequirePath(paths)
    return pulse
end

pulse.run = function(config)
    local runner = pulse.runner(config)
    runner:run()
end

return load()
