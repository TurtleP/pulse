local path = (...)

local function import(filename)
    return require(table.concat({ path, filename }, "."))
end

local ConsoleReporter = import("console")
local MarkdownReporter = import("markdown")

return { console = ConsoleReporter, markdown = MarkdownReporter }
