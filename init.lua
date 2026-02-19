local path  = (...)

local pulse = { version = "0.1.0" }

local function import(filepath)
    return require(table.concat({ path, filepath }, "."))
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

pulse.module = import("module")
pulse.assert = import("assert")
pulse.skip = skip
pulse.runner = import("runner")
pulse.wait_seconds = wait_seconds
pulse.Result = import("result")

pulse.reporters = import("reporters")

pulse.run = function(config)
    local runner = pulse.runner(config)
    runner:run()
end

return pulse
