local _assert = assert

local assert = setmetatable({}, {
    __call = function(self, ...)
        return _assert(...)
    end
})

local ERROR_STACK_LEVEL = 2

local function detail(message)
    local indent = string.rep(" ", 4)
    return message and ("\n%s-> (%s)"):format(indent, message) or ""
end

local function assert_message(message, extra)
    local formatted = ("assertion failed: %s"):format(message)
    return ("%s%s"):format(formatted, detail(extra))
end

function assert:contains(t, expected, extra)
    for _, v in pairs(t) do if v == expected then return v end end
    local message = "table does not contain %s"
    error(assert_message(message:format(
        tostring(expected)
    ), extra), ERROR_STACK_LEVEL)
end

function assert:are_equal(a, b, extra)
    if a == b then return a end
    local message = "%s is not equal to %s"
    error(assert_message(message:format(
        tostring(a), tostring(b)
    ), extra), ERROR_STACK_LEVEL)
end

function assert:are_not_equal(a, b, extra)
    if a ~= b then return a end
    local message = "%s is equal to %s"
    error(assert_message(message:format(
        tostring(a), tostring(b)
    ), extra), ERROR_STACK_LEVEL)
end

function assert:is_true(value, extra)
    if value == true then return value end
    local message = "%s is not true"
    error(assert_message(message:format(
        tostring(value)
    ), extra), ERROR_STACK_LEVEL)
end

function assert:is_false(value, extra)
    if value == false then return value end
    local message = "%s is not false"
    error(assert_message(message:format(
        tostring(value)
    ), extra), ERROR_STACK_LEVEL)
end

function assert:is_some(value, extra)
    if value ~= nil then return value end
    local message = "value is not some"
    error(assert_message(message, extra), ERROR_STACK_LEVEL)
end

function assert:is_none(value, extra)
    if value == nil then return value end
    local message = "value is not none"
    error(assert_message(message, extra), ERROR_STACK_LEVEL)
end

function assert:should_fail(f, extra)
    local ok, result = pcall(f)
    if not ok then return result end
    local message = "expected function to fail, but it succeeded"
    error(assert_message(message, extra), ERROR_STACK_LEVEL)
end

return assert
