-- Run from the repo root with a temporary HOME/XDG tree:
-- nvim --headless -u NONE -l tests/check_nvim.lua
local function checks()
    local config = vim.fn.getcwd() .. "/config/nvim"
    vim.opt.rtp:prepend(config)
    vim.g.mapleader = " "
    for _, path in ipairs(vim.fn.glob(config .. "/**/*.lua", false, true)) do
        assert(loadfile(path), path)
    end

    -- Exercise the directory picker without requiring plugin downloads.
    local selection, accept, picker, closed
    package.loaded["telescope.builtin"] = {
        find_files = function(opts) picker = opts end,
        live_grep = function() end,
    }
    package.loaded["telescope.actions"] = {
        select_default = { replace = function(_, callback) accept = callback end },
        close = function() closed = true end,
    }
    package.loaded["telescope.actions.state"] = { get_selected_entry = function() return selection end }
    dofile(config .. "/lua/plugins/telescope.lua")[1].config()
    search_and_scope_into_directory()
    picker.attach_mappings(1)
    local original_cwd = vim.fn.getcwd()
    accept()
    assert(vim.fn.getcwd() == original_cwd and not closed, "Empty selection must be harmless")
    local directory = vim.fn.tempname() .. " # % | space"
    vim.fn.mkdir(directory, "p")
    selection = { path = directory }
    accept()
    assert(vim.uv.fs_realpath(vim.fn.getcwd()) == vim.uv.fs_realpath(directory) and closed,
        "Directory names must remain literal")
    vim.api.nvim_set_current_dir(original_cwd)
    vim.fn.delete(directory, "d")

    require("keymaps")
    local function callback(lhs)
        local mapping = vim.fn.maparg(lhs, "n", false, true)
        assert(mapping.callback, "Missing mapping " .. lhs)
        return mapping.callback
    end

    -- Closing terminals must not discard unsaved editing buffers.
    local text = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_lines(text, 0, -1, false, { "unsaved work" })
    local terminal = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_term(terminal, {})
    callback("<leader>tc")()
    assert(vim.api.nvim_buf_is_valid(text) and vim.bo[text].modified, "Edited file was discarded")
    assert(not vim.api.nvim_buf_is_valid(terminal), "Terminal was not closed")
    vim.api.nvim_buf_delete(text, { force = true })

    -- Running a file must pass an argument list, never interpolate a shell command.
    local script = vim.fn.tempname() .. " # % | $(literal).py"
    vim.api.nvim_buf_set_name(0, script)
    vim.bo.filetype = "python"
    local source_buffer = vim.api.nvim_get_current_buf()
    local script_path = vim.api.nvim_buf_get_name(source_buffer)
    local saved_jobstart = vim.fn.jobstart
    local argv, opts
    vim.fn.jobstart = function(args, options) argv, opts = args, options; return 1 end
    callback("<leader>rr")()
    vim.fn.jobstart = saved_jobstart
    assert(vim.deep_equal(argv, { "python3", script_path }) and opts.term, "Runner did not preserve literal path")
    assert(vim.api.nvim_get_current_buf() ~= source_buffer, "Runner must open a separate terminal buffer")
    vim.fn.delete(script)

    -- Parser failures must retain normal indentation; successful parsers enable TS.
    local installed, updated
    package.loaded["nvim-treesitter"] = {
        setup = function() end,
        install = function(parsers)
            installed = parsers
            return { wait = function() end }
        end,
        update = function() updated = true; return { wait = function() end } end,
    }
    local ts = dofile(config .. "/lua/plugins/treesitter.lua")
    ts.build()
    assert(vim.list_contains(installed, "c_sharp") and updated, "Fresh install must provision parsers")
    ts.config()
    local start = vim.treesitter.start
    vim.bo.indentexpr = ""
    vim.treesitter.start = function() error("No parser") end
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
    assert(vim.bo.indentexpr == "", "Missing parser replaced ordinary indentation")
    vim.treesitter.start = function() end
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
    assert(vim.bo.indentexpr:find("nvim-treesitter", 1, true), "Parser did not enable indentation")
    vim.treesitter.start = start

    -- Theme selection must persist without WezTerm/Ghostty being installed.
    local theme = require("theme-state")
    theme.write("token")
    assert(theme.read() == "token", "Theme state was not saved")
    theme.write("not-a-theme")
    assert(theme.read() == "token", "Invalid theme overwrote selection")
    vim.fn.delete(vim.fn.stdpath("state") .. "/current-theme")
    print("Neovim regression checks passed")
end

local ok, err = xpcall(checks, debug.traceback)
if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
end
vim.cmd("qa!")
