--
-- pulse
-- Copyright (c) TurtleP
--

local PATH = (...):gsub("[^%.]+$", "")

local function with_module(init)
    local M = {}

    local original_paths = love.filesystem.getRequirePath()

    local library_paths = table.concat({
        ("%s/?.lua"):format(PATH),
        ("%s/?/init.lua"):format(PATH)
    }, ";")

    -- Extend require path
    love.filesystem.setRequirePath(original_paths .. ";" .. library_paths)

    local function import(module)
        return require(PATH .. module)
    end

    init(M, import)

    love.filesystem.setRequirePath(original_paths)
    return M
end

local function wait_seconds(seconds)
    local target = love.timer.getTime() + seconds
    repeat
        coroutine.yield()
    until love.timer.getTime() >= target
end

local function skip(reason)
    error({ skip = true, reason = reason or "Skipped" }, 2)
end

local pulse = with_module(function(pulse, import)
    local Core = import("pulse.core")
    for core_name, value in pairs(Core) do
        pulse[core_name] = value
    end

    local Reporters = import("pulse.reporters")
    for reporter_name, value in pairs(Reporters) do
        pulse[reporter_name] = value
    end

    local Utils = import("pulse.utils")
    for util_name, value in pairs(Utils) do
        pulse[util_name] = value
    end

    pulse.skip = skip
    pulse.wait_seconds = wait_seconds

    pulse.run = function(config)
        local runner = pulse.runner(config)
        runner:run()
    end
end)

pulse._VERSION = "0.1.0"

return pulse
