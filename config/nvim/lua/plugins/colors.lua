local last_theme = require("theme-state").read()

local local_schemes = { ultraviolet = true, pywal = true, ["unyielding-grayscale"] = true, token = true }
if local_schemes[last_theme] then
    pcall(vim.cmd.colorscheme, last_theme)
end

return {

    {
        "ellisonleao/gruvbox.nvim",
        lazy = last_theme ~= "gruvbox",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "hard",
                overrides = {
                    SignColumn = { bg = "none" },
                    GruvboxGreenSign = { bg = "none" },
                    GruvboxOrangeSign = { bg = "none" },
                    GruvboxPurpleSign = { bg = "none" },
                    GruvboxYellowSign = { bg = "none" },
                    GruvboxRedSign = { bg = "none" },
                    GruvboxBlueSign = { bg = "none" },
                    GruvboxAquaSign = { bg = "none" },
                },
            })
            if last_theme == "gruvbox" then
                vim.cmd.colorscheme("gruvbox")
            end
        end,
    },

    {
        "folke/tokyonight.nvim",
        lazy = last_theme ~= "tokyonight",
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = false,
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    functions = {},
                    variables = {},
                },
            })
            if last_theme == "tokyonight" then
                vim.cmd.colorscheme("tokyonight")
            end
        end,
    },

    {
        "EdenEast/nightfox.nvim",
        lazy = last_theme ~= "nightfox",
        priority = 1000,
        config = function()
            require("nightfox").setup({
                options = {
                    transparent = false,
                    terminal_colors = true,
                    styles = {
                        comments = "italic",
                        keywords = "italic",
                    },
                },
            })
            if last_theme == "nightfox" then
                vim.cmd.colorscheme("nightfox")
            end
        end,
    },
}
