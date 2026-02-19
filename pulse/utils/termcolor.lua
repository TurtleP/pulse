local TermColor   = {}
TermColor.__index = TermColor

TermColor.Reset   = "\27[0m"
TermColor.Red     = "\27[31m"
TermColor.Green   = "\27[32m"
TermColor.Yellow  = "\27[33m"
TermColor.Gray    = "\27[90m"

function TermColor.new(use_color)
    return setmetatable({ parts = {}, color = use_color }, TermColor)
end

function TermColor:add(color, text)
    assert(text ~= nil, "text cannot be nil")
    if color and self.color then
        self.parts[#self.parts + 1] = color
        self.parts[#self.parts + 1] = text
        self.parts[#self.parts + 1] = TermColor.Reset
    else
        self.parts[#self.parts + 1] = text
    end
    return self
end

function TermColor:text(text)
    return self:add(nil, text)
end

function TermColor:green(text)
    return self:add(TermColor.Green, text)
end

function TermColor:red(text)
    return self:add(TermColor.Red, text)
end

function TermColor:yellow(text)
    return self:add(TermColor.Yellow, text)
end

function TermColor:gray(text)
    return self:add(TermColor.Gray, text)
end

function TermColor:__tostring()
    return table.concat(self.parts)
end

function TermColor:print()
    print(self)
end

return setmetatable(TermColor, {
    __call = function(_, ...)
        return TermColor.new(...)
    end
})
