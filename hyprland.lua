local terminal = "kitty"
local file_manager = "nautilus"
local telegram = "Telegram"
local spotify = "spotify"
local vscode = "code"
local browser = "flatpak run app.zen_browser.zen"

local main_mod = "SUPER"
local window_mod = "ALT"
local home = assert(os.getenv("HOME"), "HOME must be set")
local function xdg_path(name, fallback)
    local value = os.getenv(name)
    return value and value ~= "" and value or home .. fallback
end
local config_home = xdg_path("XDG_CONFIG_HOME", "/.config")
local cache_home = xdg_path("XDG_CACHE_HOME", "/.cache")
local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@144",
    position = "1920x0",
    scale = 1,
    transform = 2,
})

for workspace = 1, 4 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-1" })
end

for workspace = 5, 10 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "eDP-1" })
end


hl.on("hyprland.start", function()
    -- One session owner restores wallpaper and starts the optional Caelestia shell.
    hl.exec_cmd("mkdir -p " .. shell_quote(cache_home .. "/hyprduma") ..
        " && python3 -u " .. shell_quote(config_home .. "/hypr/scripts/monitor-handler.py") ..
        " >> " .. shell_quote(cache_home .. "/hyprduma/monitor-handler.log") .. " 2>&1")
    hl.exec_cmd("hyprctl setcursor Adwaita 24")
    hl.exec_cmd('mkdir -p "$HOME/Pictures/Screenshots"')
end)

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 10,
        gaps_out = 40,
        border_size = 3,
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 13,
        active_opacity = 0.985,
        inactive_opacity = 0.85,
        blur = {
            enabled = false,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout = "us, ru",
        kb_options = "grp:alt_shift_toggle",
        numlock_by_default = true,
        follow_mouse = 1,
        touchpad = {
            natural_scroll = false,
            scroll_factor = 0.6,
        },
        sensitivity = 0,
    },

    dwindle = {
        preserve_split = true,
        smart_split = false,
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
        vrr = 0,
    },

    debug = {
        vfr = true,
    },

    binds = {
        disable_keybind_grabbing = false,
    },
})

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "vertical", action = "fullscreen" })

hl.curve("specialWorkSwitch", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })

hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "specialWorkSwitch", style = "slidefadevert 15%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "standard" })

local pywal_colors = cache_home .. "/wal/hyprland-colors.lua"
local colors_file = io.open(pywal_colors, "r")
if colors_file then
    colors_file:close()
    -- A damaged cache must not prevent the remaining rules and keybinds loading.
    local ok, err = pcall(dofile, pywal_colors)
    if not ok then
        print("Could not load Pywal colors: " .. tostring(err))
    end
end

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

local floating_windows = {
    { name = "PulseAudio-float", class = "^(org.pulseaudio.pavucontrol)$" },
    { name = "Blueman-manager", title = "^(blueman-manager)$" },
    { name = "Network-Manager-Connection-Editor", class = "^(nm-connection-editor)$" },
    { name = "waypaper", class = "^(waypaper)$" },
    { name = "gnome-calculator", class = "^(gnome-calculator)$" },
    { name = "Calculator", class = "^(Calculator)$" },
}

for _, rule in ipairs(floating_windows) do
    local match = {}
    if rule.class then
        match.class = rule.class
    end
    if rule.title then
        match.title = rule.title
    end
    hl.window_rule({ name = rule.name, match = match, float = true })
end

hl.window_rule({
    name = "nokyan-Resources",
    match = { class = "^(net.nokyan.Resources)$" },
    float = true,
    size = { 1150, 600 },
})

local file_picker_titles = {
    { name = "OpenFiles", title = "^(Open Files|File Picker)$" },
    { name = "OpenFolder", title = "^(Open Folder|File Picker)$" },
    { name = "SelectImage", title = "^(Select Image|File Picker)$" },
    { name = "SaveFile", title = "^(Save File|File Picker)$" },
    { name = "ChangeDownloadLocation", title = "^(Change Download Location|File Picker)$" },
}

for _, rule in ipairs(file_picker_titles) do
    hl.window_rule({
        name = rule.name,
        match = { title = rule.title, class = "^(.*)$" },
        float = true,
    })
end

hl.window_rule({
    name = "DesktopPortal",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
})

hl.window_rule({
    name = "Picture-in-Picture",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
})

hl.window_rule({
    name = "Pin-PIP",
    match = { title = "^(Picture-in-Picture)$" },
    pin = true,
})

hl.window_rule({
    name = "PIP-Position",
    match = { title = "^(Picture-in-Picture)$" },
    move = { "69.5%", "4%" },
})

hl.layer_rule({
    name = "Caelestia-drawers",
    match = { namespace = "^caelestia-(drawers|background)$" },
    animation = "fade",
})

hl.layer_rule({
    name = "drawers",
    match = { namespace = "caelestia-drawers" },
    blur = true,
})

hl.layer_rule({
    name = "drawers-alpha",
    match = { namespace = "caelestia-drawers" },
    ignore_alpha = 0.57,
})

hl.layer_rule({
    name = "border-exclusion",
    match = { namespace = "^caelestia-(border-exclusion|area-picker)$" },
    no_anim = true,
})

hl.layer_rule({
    name = "wofi",
    match = { namespace = "wofi" },
    blur = true,
})

hl.layer_rule({
    name = "wofi-ignore-alpha",
    match = { namespace = "wofi" },
    ignore_alpha = 0.2,
})

hl.bind(main_mod .. " + C", hl.dsp.window.close())
hl.bind(main_mod .. " + M", hl.dsp.exit())
hl.bind(main_mod .. " + Z", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + X", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd("qs -c caelestia ipc call lock lock || hyprlock"))
hl.bind(main_mod .. " + O", hl.dsp.layout("togglesplit"))
hl.bind(main_mod .. " + SHIFT + O", hl.dsp.window.pseudo())
hl.bind(main_mod .. " + P", hl.dsp.exec_cmd("poweroff"))
hl.bind(main_mod .. " + RETURN", hl.dsp.exec_cmd("wlogout"))
hl.bind(main_mod .. " + N", hl.dsp.exec_cmd("qs -c caelestia ipc call drawers toggle sidebar"))

hl.bind(main_mod .. " + SHIFT + B", function()
    local blur_enabled = hl.get_config("decoration.blur.enabled")
    hl.config({ ["decoration.blur.enabled"] = not blur_enabled })
end)

hl.bind(main_mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + F", hl.dsp.exec_cmd(file_manager))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(main_mod .. " + V", hl.dsp.exec_cmd(vscode))
hl.bind(main_mod .. " + T", hl.dsp.exec_cmd(telegram))
hl.bind(main_mod .. " + S", hl.dsp.exec_cmd(spotify))
hl.bind(main_mod .. " + W", hl.dsp.exec_cmd("waypaper"))
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd(terminal .. " htop"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.exec_cmd(
    [[hyprshot -m region -o "$HOME/Pictures/Screenshots" -f "Screenshot_$(date '+%Y-%m-%d_%H:%M:%S').png" -z]]
))

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
    hl.bind(main_mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = workspace, follow = false }))
end

local workspace_directions = {
    { key = "left", workspace = "r-1" },
    { key = "right", workspace = "r+1" },
    { key = "H", workspace = "r-1" },
    { key = "L", workspace = "r+1" },
}

for _, direction in ipairs(workspace_directions) do
    -- Leave plain Ctrl+H/L available for terminal and Neovim window navigation.
    if direction.key == "left" or direction.key == "right" then
        hl.bind(main_mod .. " + " .. direction.key, hl.dsp.focus({ workspace = direction.workspace }))
    end
    hl.bind(main_mod .. " + SHIFT + " .. direction.key, hl.dsp.window.move({ workspace = direction.workspace }))
    hl.bind(main_mod .. " + CTRL + " .. direction.key, hl.dsp.window.move({
        workspace = direction.workspace,
        follow = false,
    }))
end

hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

local directions = {
    { key = "left", direction = "left", resize_x = -50, resize_y = 0 },
    { key = "right", direction = "right", resize_x = 50, resize_y = 0 },
    { key = "up", direction = "up", resize_x = 0, resize_y = -50 },
    { key = "down", direction = "down", resize_x = 0, resize_y = 50 },
    { key = "H", direction = "left", resize_x = -50, resize_y = 0 },
    { key = "L", direction = "right", resize_x = 50, resize_y = 0 },
    { key = "K", direction = "up", resize_x = 0, resize_y = -50 },
    { key = "J", direction = "down", resize_x = 0, resize_y = 50 },
}

for _, binding in ipairs(directions) do
    hl.bind(window_mod .. " + " .. binding.key, hl.dsp.focus({ direction = binding.direction }))
    hl.bind(window_mod .. " + CTRL + " .. binding.key, hl.dsp.window.resize({
        x = binding.resize_x,
        y = binding.resize_y,
        relative = true,
    }))
    hl.bind(window_mod .. " + SHIFT + " .. binding.key, hl.dsp.window.move({
        direction = binding.direction,
    }))
end

hl.bind(window_mod .. " + TAB", hl.dsp.window.cycle_next())
hl.bind(main_mod .. " + TAB", hl.dsp.window.cycle_next({ next = false }))

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys
local repeat_locked = { repeating = true, locked = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), repeat_locked)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), repeat_locked)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), repeat_locked)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), repeat_locked)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), repeat_locked)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), repeat_locked)

local locked = { locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
