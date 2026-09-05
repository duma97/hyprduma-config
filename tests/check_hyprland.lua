-- Safe configuration regression checks: records dispatchers without launching apps.
-- Run from the repository root with: luajit tests/check_hyprland.lua
local function check_config(cache_present)
    local binds, rules, layers, events, commands, warnings = {}, {}, {}, {}, {}, {}
    local blur = false
    local function dispatcher(name)
        return function(options)
            return { name = name, options = options }
        end
    end
    local hl = { dsp = { window = {} } }
    for _, name in ipairs({ "close", "float", "fullscreen", "pseudo", "move", "resize", "cycle_next", "drag" }) do
        hl.dsp.window[name] = dispatcher(name)
    end
    for _, name in ipairs({ "exit", "exec_cmd", "layout", "focus" }) do
        hl.dsp[name] = dispatcher(name)
    end
    for _, name in ipairs({ "monitor", "workspace_rule", "env", "gesture", "curve", "animation" }) do
        hl[name] = function() end
    end
    hl.config = function(options)
        if options.decoration then blur = options.decoration.blur.enabled end
        if options["decoration.blur.enabled"] ~= nil then blur = options["decoration.blur.enabled"] end
    end
    hl.get_config = function() return blur end
    hl.window_rule = function(rule) table.insert(rules, rule) end
    hl.layer_rule = function(rule) table.insert(layers, rule) end
    hl.on = function(event, callback) events[event] = callback end
    hl.exec_cmd = function(command) table.insert(commands, command) end
    hl.bind = function(key, callback)
        assert(not binds[key], "Duplicate shortcut: " .. key)
        binds[key] = callback
    end
    local paths = { HOME = "/tmp/example user", XDG_CONFIG_HOME = "/tmp/config's folder", XDG_CACHE_HOME = "/tmp/custom cache" }
    local env = setmetatable({
        hl = hl,
        os = { getenv = function(name) return paths[name] end },
        io = { open = function(path)
            assert(path == "/tmp/custom cache/wal/hyprland-colors.lua")
            return cache_present and { close = function() end } or nil
        end },
        dofile = function() error("damaged color cache") end,
        print = function(message) table.insert(warnings, message) end,
    }, { __index = _G })
    setfenv(assert(loadfile("hyprland.lua")), env)()

    assert(not binds["CTRL + H"] and not binds["CTRL + L"], "Neovim navigation is intercepted")
    assert(binds["SUPER + SHIFT + O"].name == "pseudo", "Pseudo mode must be opt-in")
    for _, rule in ipairs(rules) do assert(not rule.pseudo, "Window rules force pseudo mode") end
    for workspace = 1, 10 do
        local key = tostring(workspace % 10)
        assert(binds["SUPER + " .. key].options.workspace == workspace)
        assert(binds["SUPER + SHIFT + " .. key].options.workspace == workspace)
        assert(binds["SUPER + CTRL + " .. key].options.follow == false)
    end
    binds["SUPER + SHIFT + B"]()
    assert(blur)
    binds["SUPER + SHIFT + B"]()
    assert(not blur)
    assert(binds["SUPER + N"].options == "qs -c caelestia ipc call drawers toggle sidebar")
    assert(binds["SUPER + L"].options == "qs -c caelestia ipc call lock lock || hyprlock")
    events["hyprland.start"]()
    assert(#commands == 3, "Wallpaper/shell startup has more than one owner")
    assert(commands[1] == "mkdir -p '/tmp/custom cache/hyprduma' && python3 -u '/tmp/config'\\''s folder/hypr/scripts/monitor-handler.py' >> '/tmp/custom cache/hyprduma/monitor-handler.log' 2>&1")
    assert(#warnings == (cache_present and 1 or 0), "Damaged cache must be reported without aborting keybinds")
end

check_config(false)
check_config(true)
print("Hyprland checks passed: navigation, workspace moves, toggles, session startup and damaged-cache recovery")
