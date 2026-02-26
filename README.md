# pulse

pulse is a small, dependency-free test runner for LÖVE (love2d) written in Lua. It provides a lightweight test harness, simple assertions, and multiple reporters (console and markdown) for producing human- and machine-friendly outputs.

**Features**

- **Simple assertions:** `assert.are_equal`, `assert.is_true`, `assert.contains`, etc.
- **Reporters:** Console reporter with optional color and a Markdown reporter that writes a report file.
- **Filtering:** Run subsets of tests by module or name via configuration.

**Quick Start**

1. Place the `pulse` files into your LÖVE project.
2. Add test files under a `tests` directory (default). Test files must be named `test_*.lua`.
3. Create a minimal `main.lua` to run the tests with LÖVE:

```lua
local pulse = require("path.to.pulse")

function love.load()
  pulse.run({ directory = "tests", color = true, reporters = { "console" } })
end
```

Run the project with LÖVE (`love .`) and the test runner will execute and quit when finished.

**Test file example**

```lua
local pulse = require("path.to.pulse")

return function(test)
    test("simple equality", function()
        pulse.assert:are_equal(1, 1)
    end)

    test("skip example", function()
        pulse.skip("Not relevant on this platform")
    end)
end
```

**API & Configuration**

- `local pulse = require("pulse")` — main module.
- `pulse.run(config)` — create and run the test runner. `config` may be:
    - `directory` (string): folder to scan for `test_*.lua` files (default: `tests`).
    - `color` (bool): enable coloured console output (default: `false`).
    - `reporters` (array): list of reporter names (defaults to `{ "console" }`).
    - `filter` (table): optional filter with `module` and/or `name` arrays to include specific tests.

Other helpers:

- `pulse.assert` — assertion helpers (see `assert.lua`).
- `pulse.skip(reason)` — skip the current test with an optional reason.
- `pulse.wait_seconds(n)` — convenience util that yields for `n` seconds using `love.timer`

**Reporters**

- `console` — default, prints concise output to the console (supports color toggle).
- `markdown` — produces a timestamped Markdown report file in the LÖVE save folder.

**Contributing**

- Feel free to open issues or pull requests.
