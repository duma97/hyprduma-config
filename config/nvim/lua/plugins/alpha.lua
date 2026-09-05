return {
    "goolord/alpha-nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local dashboard = require("alpha.themes.dashboard")
        local color9 = vim.g.color9 or "#ffffff"
        local color3 = vim.g.color3 or "#ffffff"
        local color4 = vim.g.color4 or "#ffffff"
        local color5 = vim.g.color5 or "#ffffff"
        local color6 = vim.g.color6 or "#ffffff"

        local function getCharLen(s, pos)
            local byte = string.byte(s, pos)
            if not byte then
                return nil
            end
            return (byte < 0x80 and 1) or (byte < 0xE0 and 2) or (byte < 0xF0 and 3) or (byte < 0xF8 and 4) or 1
        end

        local function applyColors(logo, colors, logoColors)
            dashboard.section.header.val = logo
            for key, color in pairs(colors) do
                local name = "Alpha" .. key
                vim.api.nvim_set_hl(0, name, color)
                colors[key] = name
            end
            dashboard.section.header.opts.hl = {}
            for i, line in ipairs(logoColors) do
                local highlights = {}
                local pos = 0
                for j = 1, #line do
                    local opos = pos
                    pos = pos + getCharLen(logo[i], opos + 1)
                    local color_name = colors[line:sub(j, j)]
                    if color_name then
                        table.insert(highlights, { color_name, opos, pos })
                    end
                end
                table.insert(dashboard.section.header.opts.hl, highlights)
            end
            return dashboard.opts
        end

        local logo = {
            [[           ▄▄▄▄▄    ]],
            [[           ██▀▀▀██  ]],
            [[    ▄▄     ██    ██ ]],
            [[    ██     ██    ██ ]],
            [[           ██    ██ ]],
            [[    ██     ██▄▄▄██  ]],
            [[    ▀▀     ▀▀▀▀▀   ]],
            [[]],
            [[]],
            [[]],
            [[]],
        }

        local logoColors = {}
        for _, line in ipairs(logo) do
            table.insert(logoColors, (line
                :gsub('▄', 'a')
                :gsub('█', 'a')
                :gsub('▀', 'a')))
        end

        require("alpha").setup(applyColors(logo, {
            ["a"] = { fg = color9,  ctermfg = 33 },
            ["b"] = { fg = color3,  ctermfg = 33 },
            ["c"] = { fg = color4,  ctermfg = 33 },
            ["d"] = { fg = color5,  ctermfg = 33 },
            ["e"] = { fg = color6,  ctermfg = 33 },
        }, logoColors))

        dashboard.section.buttons.val = {
            dashboard.button( "e", "  > New file" , ":ene <BAR> startinsert <CR>"),
            dashboard.button( "f", "󰱼  > Find file", ":lua require('telescope.builtin').find_files({ find_command = { 'rg', '--files' } })<CR>"),
            dashboard.button( "F", "󰥨  > Find folder", ":lua search_and_scope_into_directory()<CR>"),
            dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
            dashboard.button( "c", "  > Config" , ":cd ~/.config/nvim | Telescope find_files<CR>"),
            dashboard.button( "l", "󰒲 > Lazy", ":Lazy<CR>"),
            dashboard.button( "h", "  > Settings" , ":cd ~/.config/hypr | Telescope find_files<CR>"),
            dashboard.button( "q", "  > Quit", ":qa<CR>"),
        }

        dashboard.section.footer.val = {
            "",
            "Welcome!",
        }
    end,
}
