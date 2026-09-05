return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<C-p>", builtin.find_files, {})
            vim.keymap.set("n", "<A-f>", builtin.live_grep, {})

            _G.search_and_scope_into_directory = function()
                builtin.find_files({
                    prompt_title = "Search Directories",
                    find_command = {"fd", "--type", "d", "--hidden", "--follow"},
                    attach_mappings = function(prompt_bufnr)
                        local actions = require("telescope.actions")
                        actions.select_default:replace(function()
                            local selection = require("telescope.actions.state").get_selected_entry()
                            if not selection then
                                return
                            end
                            local selected_dir = selection.path or selection[1]
                            if not selected_dir or vim.fn.isdirectory(selected_dir) ~= 1 then
                                return
                            end
                            actions.close(prompt_bufnr)
                            vim.api.nvim_set_current_dir(selected_dir)
                        end)
                        return true
                    end,
                })
            end

            vim.keymap.set("n", "<A-d>", search_and_scope_into_directory)
        end
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
                defaults = {
                    file_ignore_patterns = {
                        "node_modules", "build", "dist", "yarn.lock"
                    },
                    vimgrep_arguments = {
                        "rg",
                        "--follow",
                        "--hidden",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--glob=!**/.git/*",
                        "--glob=!**/.idea/*",
                        "--glob=!**/.vscode/*",
                        "--glob=!**/build/*",
                        "--glob=!**/dist/*",
                        "--glob=!**/yarn.lock",
                        "--glob=!**/package-lock.json",
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                        find_command = {
                            "rg",
                            "--files",
                            "--hidden",
                            "--glob=!**/.git/*",
                            "--glob=!**/.idea/*",
                            "--glob=!**/.vscode/*",
                            "--glob=!**/build/*",
                            "--glob=!**/dist/*",
                            "--glob=!**/yarn.lock",
                            "--glob=!**/package-lock.json",
                        },
                    },
                },
            })
            require("telescope").load_extension("ui-select")
            require("telescope").load_extension("fzf")
        end,
    },
}
