local Result = {}

Result.OK = "ok"
Result.FAILED = "FAILED"
Result.SKIPPED = "skipped"

return setmetatable(Result, {
    __index = function(_, key)
        error("Attempt to access undefined result type: " .. key)
    end
})
