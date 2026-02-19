local TermColor = require("pulse.utils.termcolor")
local Result = require("pulse.core.result")

local ConsoleReporter = {}
ConsoleReporter.__index = ConsoleReporter

function ConsoleReporter.new(color)
    return setmetatable({ color = color }, ConsoleReporter)
end

function ConsoleReporter:onRunStart(tests)
    local plural = #tests == 1 and "" or "s"
    TermColor(self.color):text(("\nrunning %d test%s"):format(#tests, plural)):print()
end

function ConsoleReporter:onTestStarted(test)
end

function ConsoleReporter:onTestFinished(test)
    local result, color = test:getResult(), TermColor.Green
    if result == Result.FAILED then color = TermColor.Red end
    if result == Result.SKIPPED then color = TermColor.Yellow end
    TermColor(self.color):text(("test %s ... "):format(test)):add(color, result):print()
end

local RESULTS_TEXT = ". %d passed; %d failed; %d skipped; %s\n"

function ConsoleReporter:onRunEnd(results, failures)
    local result = #results.failed == 0 and Result.OK or Result.FAILED
    local color = result == Result.OK and TermColor.Green or TermColor.Red
    local output = TermColor(self.color):text("\ntest result: "):add(color, result)

    local time = ("finished in %.2fs"):format(results.duration)
    output:text((RESULTS_TEXT):format(#results.passed, #results.failed, #results.skipped, time))

    if #failures > 0 then
        output:text("\nfailures:\n")
        for _, test in ipairs(failures) do
            output:text(("  %s: %s\n"):format(test, test:getError()))
        end
    end

    output:print()
end

return setmetatable(ConsoleReporter, {
    __call = function(_, ...)
        return ConsoleReporter.new(...)
    end
})
