return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require('gitsigns').setup {
            signs = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
            },
            signs_staged = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
            },
            signs_staged_enable = true,
            signcolumn = true,
            numhl      = false,
            linehl     = false,
            word_diff  = false,
            watch_gitdir = {
                follow_files = true
            },
            auto_attach = true,
            attach_to_untracked = false,
            current_line_blame = false,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol',
                delay = 1000,
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true,
            },
            current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil,
            max_file_length = 40000,
            preview_config = {

                border = 'single',
                style = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
            },
        }

        vim.keymap.set("n", "]h", function() require("gitsigns").nav_hunk("next") end, { desc = "Next git hunk" })
        vim.keymap.set("n", "[h", function() require("gitsigns").nav_hunk("prev") end, { desc = "Previous git hunk" })

        vim.keymap.set("n", "<leader>hs", require("gitsigns").stage_hunk, { desc = "Stage hunk" })
        vim.keymap.set("n", "<leader>hr", require("gitsigns").reset_hunk, { desc = "Reset hunk" })
        vim.keymap.set("v", "<leader>hs", function()
            require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage hunk (visual)" })
        vim.keymap.set("v", "<leader>hr", function()
            require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset hunk (visual)" })
        vim.keymap.set("n", "<leader>hS", require("gitsigns").stage_buffer, { desc = "Stage buffer" })
        vim.keymap.set("n", "<leader>hu", require("gitsigns").undo_stage_hunk, { desc = "Undo stage hunk" })
        vim.keymap.set("n", "<leader>hR", require("gitsigns").reset_buffer, { desc = "Reset buffer" })
        vim.keymap.set("n", "<leader>hp", require("gitsigns").preview_hunk, { desc = "Preview hunk" })
        vim.keymap.set("n", "<leader>hd", require("gitsigns").diffthis, { desc = "Diff this" })
        vim.keymap.set("n", "<leader>htb", require("gitsigns").toggle_current_line_blame, { desc = "Toggle line blame" })
    end
}
