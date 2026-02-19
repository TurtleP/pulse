local path = (...):match("^(.-)reporters%..+")
local Result = require(path .. "result")

local MarkdownReporter = {}
MarkdownReporter.__index = MarkdownReporter

function MarkdownReporter.new()
    local time = os.date("%Y-%m-%d_%H:%M:%S")
    local output = love.filesystem.openFile(("%s.md"):format(time:gsub(":", "-")), "w")
    return setmetatable({ output = output, time = time, modules = {} }, MarkdownReporter)
end

function MarkdownReporter:write(text)
    self.output:write(text)
end

function MarkdownReporter:writeLine(text)
    self:write(text .. "\n")
end

function MarkdownReporter:onRunStart()
    self:writeLine("## Test Report")
    self:writeLine(("*Run started at %s*\n"):format(self.time))
end

function MarkdownReporter:onTestStarted(test)
    local module = test:getModule() or "General"
    self.modules[module] = self.modules[module] or { tests = {} }
    table.insert(self.modules[module].tests, test)
end

function MarkdownReporter:onTestFinished(test)
end

local RESULTS_TEXT = "%d passed, %d failed, %d skipped — %s"

local utf8 = require("utf8")
local module_fail_char = utf8.char(0x1F534)
local module_pass_char = utf8.char(0x1F7E2)
local module_part_char = utf8.char(0x1F535)

function MarkdownReporter:onRunEnd(results, failures)
    self:writeLine("| **Module** | **Pass** | **Fail** | **Skip** | **Duration (s)** |")
    self:writeLine("|:----------:|:--------:|:--------:|:--------:|:----------------:|")

    for module, data in pairs(self.modules) do
        local passed, failed, skipped, duration = 0, 0, 0, 0
        for _, test in ipairs(data.tests) do
            local result = test:getResult()
            if result == Result.OK then passed = passed + 1 end
            if result == Result.FAILED then failed = failed + 1 end
            if result == Result.SKIPPED then skipped = skipped + 1 end
            duration = duration + test:getDuration()
        end
        local emoji = failed > 0 and module_fail_char or module_pass_char
        if failed > 0 and passed > 0 and passed > failed then emoji = module_part_char end
        self:writeLine(("| %s %s | %d | %d | %d | %.3f |"):format(emoji, module, passed, failed, skipped, duration))
    end

    local result = #results.failed == 0 and Result.OK or Result.FAILED
    self:write(("\n**Test result:** %s — "):format(result:upper()))
    local time = ("Finished in %.2fs"):format(results.duration)
    self:writeLine((RESULTS_TEXT):format(#results.passed, #results.failed, #results.skipped, time))

    if #failures > 0 then
        self:writeLine("\nFailures:\n")
        for _, test in ipairs(failures) do
            self:writeLine((" - %s: %s\n"):format(test, test:getError()))
        end
    end
end

return setmetatable(MarkdownReporter, {
    __call = function(_, ...)
        return MarkdownReporter.new()
    end
})
