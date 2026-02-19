local path = (...):gsub("registry", "")
local Test = require(path .. "test")

local Registry = {}
Registry.__index = Registry

function Registry.new(directory, filters)
    return setmetatable({ tests = {}, directory = directory, filters = filters }, Registry)
end

local pattern = "^test_.*%.lua$"

local function find_module_path(filename)
    return filename:gsub("%.lua$", ""):gsub("[/\\]", ".")
end

function Registry:scan(directory)
    directory = directory or self.directory
    local items = love.filesystem.getDirectoryItems(directory)
    for _, filename in ipairs(items) do
        local filepath = directory .. "/" .. filename
        local info = love.filesystem.getInfo(filepath)

        if filename:match(pattern) and info.type == "file" then
            local module_path = find_module_path(filepath)
            local test_module, err = pcall(require, module_path)
            if not test_module then
                print("Error loading test:", err)
            end
        elseif info.type == "directory" then
            self:scan(directory .. "/" .. filename)
        end
    end
    return self.tests
end

function Registry:add(source, name, co_function, ...)
    local module = find_module_path(source):match("test_(.+)")
    if self:filter(module, name) then return end
    self.tests[#self.tests + 1] = Test(module, name, co_function, ...)
end

local function to_set(list)
    list = list or {}
    local set = {}
    for i = 1, #list do
        set[list[i]] = true
    end
    return set
end

local function is_empty(t)
    return next(t) == nil
end

function Registry:filter(module, name)
    local module_set = to_set(self.filters.module)
    local names_set  = to_set(self.filters.name)
    if is_empty(module_set) and is_empty(names_set) then
        return false
    end
    return not module_set[module] and not names_set[name]
end

return setmetatable(Registry, {
    __call = function(_, ...)
        return Registry.new(...)
    end
})
