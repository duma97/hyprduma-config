local M = {}
local themes = {
    ultraviolet = true, token = true, pywal = true, ["unyielding-grayscale"] = true,
    gruvbox = true, tokyonight = true, nightfox = true,
}

function M.config_path(relative)
    local root = vim.env.XDG_CONFIG_HOME
    return (root and root ~= "" and root or vim.fn.expand("~/.config")) .. "/" .. relative
end

function M.read()
    for _, path in ipairs({
        vim.fn.stdpath("state") .. "/current-theme",
        M.config_path("wezterm/current_theme.txt"),
    }) do
        local file = io.open(path, "r")
        if file then
            local name = file:read("*l")
            file:close()
            if themes[name] then return name end
        end
    end
    return "ultraviolet"
end

function M.write(name)
    if not themes[name] then return end
    vim.fn.mkdir(vim.fn.stdpath("state"), "p")
    local file = assert(io.open(vim.fn.stdpath("state") .. "/current-theme", "w"))
    file:write(name .. "\n")
    file:close()
end

return M
