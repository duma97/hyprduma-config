local parsers = {
    "bash", "c", "cpp", "c_sharp", "css", "go", "html", "javascript", "json",
    "lua", "luadoc", "markdown", "markdown_inline", "python", "query", "regex",
    "rust", "tsx", "typescript", "vim", "vimdoc", "yaml",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
        local ts = require("nvim-treesitter")
        -- TSUpdate alone does not install parsers on a fresh machine.
        ts.install(parsers):wait(300000)
        ts.update():wait(300000)
    end,
    config = function()
        require("nvim-treesitter").setup({})
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
            callback = function(event)
                -- Keep the filetype's normal indentation when no parser is available.
                if pcall(vim.treesitter.start, event.buf) then
                    vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
