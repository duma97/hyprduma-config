return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "kdheepak/tabline.nvim" },

    config = function()
        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = { "neo-tree" },
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                always_show_tabline = true,
                globalstatus = false,
                refresh = {
                    statusline = 100,
                    tabline = 100,
                    winbar = 100,
                }
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch'},
                lualine_c = {},
                lualine_x = { { 'filetype', colored = false, icon_only = false } },
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {{'filename', cond = function() return vim.fn.expand('%') ~= '' end}},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { require'tabline'.tabline_buffers },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            winbar = {},
            inactive_winbar = {},
            extensions = {}
        }
    end,
}
