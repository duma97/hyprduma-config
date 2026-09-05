if vim.fn.has("nvim-0.12") == 0 then
    error("This configuration requires Neovim 0.12 or newer.")
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local output = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Could not install lazy.nvim:\n" .. output)
    end
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")

require("keymaps")

require("lazy").setup("plugins")

require("custom-colors")
