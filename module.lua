local Module = {}
Module.__index = Module

function Module.new(name, ...)
    return setmetatable({ name = name, tests = { ... } }, Module)
end

function Module:__tostring()
    return self.name
end

return function(name, ...)
    local module = Module.new(name, ...)
    for _, test in ipairs(module.tests) do
        test.module = module
    end
    return module
end
