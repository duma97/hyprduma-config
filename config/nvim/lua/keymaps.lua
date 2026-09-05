local keymap = vim.keymap

keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

keymap.set("n", "<leader>d", '"_d', { desc = "Delete to void register" })
keymap.set("v", "<leader>d", '"_d', { desc = "Delete to void register" })

keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlighting" })

keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })

keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })

local theme_bg = {
	nightfox = "#192330",
	tokyonight = "#1a1b26",
	gruvbox = "#1d2021",
	token = "#262624",
	ultraviolet = "#111115",
}

local function set_theme(nvim_scheme, theme_name)
	vim.cmd.colorscheme(nvim_scheme)
	require("theme-state").write(theme_name)

	local f = io.open(require("theme-state").config_path("wezterm/current_theme.txt"), "w")
	if f then
		f:write(theme_name .. "\n")
		f:close()
	end

	local bg = theme_bg[theme_name]
	if bg then
		local ghostty_path = require("theme-state").config_path("ghostty/config")
		local gf = io.open(ghostty_path, "r")
		if gf then
			local content = gf:read("*all")
			gf:close()
			content = content:gsub("background = #%x+", "background = " .. bg)
			local wf = io.open(ghostty_path, "w")
			if wf then
				wf:write(content)
				wf:close()
			end
		end
	end
end

keymap.set("n", "<leader>cg", function() set_theme("gruvbox", "gruvbox") end, { desc = "Theme: Gruvbox" })
keymap.set("n", "<leader>ct", function() set_theme("tokyonight", "tokyonight") end, { desc = "Theme: Tokyo Night" })
keymap.set("n", "<leader>cn", function() set_theme("nightfox", "nightfox") end, { desc = "Theme: Nightfox" })
keymap.set("n", "<leader>cf", function()
	vim.o.background = "dark"
	set_theme("token", "token")
end, { desc = "Theme: Token" })
keymap.set("n", "<leader>cu", function() set_theme("ultraviolet", "ultraviolet") end, { desc = "Theme: Ultraviolet" })
keymap.set("n", "<leader>cb", function()
	local colors = require("custom-colors")
	colors.transparent = not colors.transparent
	colors.apply()
	if not colors.transparent then
		vim.cmd.colorscheme(vim.g.colors_name)
	end
	print("Transparency: " .. (colors.transparent and "ON" or "OFF"))
end, { desc = "Toggle transparent background" })

keymap.set("n", "<leader>cB", function()
	local colors = require("custom-colors")
	colors.bold = not colors.bold
	vim.cmd.colorscheme(vim.g.colors_name)
	print("Bold: " .. (colors.bold and "ON" or "OFF"))
end, { desc = "Toggle bold text" })

keymap.set("n", "<leader>rr", function()
    local commands = { python = "python3", javascript = "node", sh = "bash" }
    local filetype = vim.bo.filetype
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        vim.notify("Save the file before running it.", vim.log.levels.WARN)
        return
    end
    if filetype == "lua" then
        vim.cmd.write()
        dofile(path)
    elseif commands[filetype] then
        vim.cmd.write()
        vim.cmd.new()
        -- An argument list preserves spaces and shell metacharacters in filenames.
        vim.fn.jobstart({ commands[filetype], path }, { term = true })
    else
        vim.notify("No run command configured for filetype: " .. filetype)
    end
end, { desc = "Run current file" })

keymap.set("v", "<leader>rs", function()
	local filetype = vim.bo.filetype
	if filetype == "python" then
		vim.cmd("'<,'>w !python3")
	elseif filetype == "javascript" then
		vim.cmd("'<,'>w !node")
	elseif filetype == "sh" then
		vim.cmd("'<,'>w !bash")
	else
		print("No run command configured for filetype: " .. filetype)
	end
end, { desc = "Run selected code" })

keymap.set("n", "<leader>rl", function()
	local filetype = vim.bo.filetype
	if filetype == "python" then
		vim.cmd(".w !python3")
	elseif filetype == "javascript" then
		vim.cmd(".w !node")
	else
		print("No run command configured for filetype: " .. filetype)
	end
end, { desc = "Run current line" })

keymap.set("n", "<leader>rp", ":split | terminal python3<CR>i", { desc = "Open Python REPL" })

keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap.set("t", "<C-q>", "<C-\\><C-n>:q<CR>", { desc = "Close terminal quickly" })
keymap.set("n", "<leader>tc", function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end, { desc = "Close all terminals" })
