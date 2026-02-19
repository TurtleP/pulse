local _assert = assert

local assert = setmetatable({}, {
    __call = function(self, ...)
        return _assert(...)
    end
})

local ERROR_STACK_LEVEL = 2

function assert:contains(t, expected)
    for _, v in pairs(t) do if v == expected then return v end end
    error(("assertion failed: table does not contain %s"):format(
        tostring(expected)
    ), ERROR_STACK_LEVEL)
end

function assert:are_equal(a, b)
    if a == b then return a end
    error(("assertion failed: %s is not equal to %s"):format(
        tostring(a), tostring(b)
    ), ERROR_STACK_LEVEL)
end

function assert:are_not_equal(a, b)
    if a ~= b then return a end
    error(("assertion failed: %s is equal to %s"):format(
        tostring(a), tostring(b)
    ), ERROR_STACK_LEVEL)
end

function assert:is_true(value)
    if value == true then return value end
    error(("assertion failed: %s is not true"):format(
        tostring(value)
    ), ERROR_STACK_LEVEL)
end

function assert:is_false(value)
    if value == false then return value end
    error(("assertion failed: %s is not false"):format(
        tostring(value)
    ), ERROR_STACK_LEVEL)
end

function assert:is_some(value)
    if value ~= nil then return value end
    error(("assertion failed: value is not some"), ERROR_STACK_LEVEL)
end

function assert:is_none(value)
    if value == nil then return value end
    error(("assertion failed: value is not none"), ERROR_STACK_LEVEL)
end

return assert
