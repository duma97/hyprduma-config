local M = {}

M.transparent = true
M.bold = true

-- Делает жирными все highlight-группы (не зависит от шрифта терминала).
M.apply_bold = function()
	if not M.bold then
		return
	end
	for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
		if not hl.link and not hl.bold then
			hl.bold = true
			pcall(vim.api.nvim_set_hl, 0, name, hl)
		end
	end
end

M.apply = function()
	if M.transparent then
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })
		vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none", fg = "none" })
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#9AA1AB", bg = "none" })
		vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
		vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
		vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
		vim.api.nvim_set_hl(0, "TabLineSel", { bg = "none" })

		local modes = { "normal", "insert", "visual", "replace", "command", "inactive", "terminal" }
		local sections = { "a", "b", "c", "x", "y", "z" }
		for _, mode in ipairs(modes) do
			for _, section in ipairs(sections) do
				local name = "lualine_" .. section .. "_" .. mode
				local ok, current = pcall(vim.api.nvim_get_hl, 0, { name = name })
				local fg = (ok and current.fg) or nil

				if ok and current.bg and (section == "a" or section == "z") then
					fg = current.bg
				end

				if not fg or fg < 0x444444 then
					fg = 0xbbbbbb
				end
				vim.api.nvim_set_hl(0, name, { fg = fg, bg = "none", bold = section == "a" or section == "z" })
			end
		end

		local all_hls = vim.api.nvim_get_hl(0, {})
		for name, hl in pairs(all_hls) do
			if name:match("^lualine_transitional") then
				vim.api.nvim_set_hl(0, name, { bg = "none", fg = "none" })
			elseif name:match("^DevIcon") or name:match("^lualine_.*DevIcon") or name:match("^lualine_.*filetype") then
				vim.api.nvim_set_hl(0, name, { fg = hl.fg, bg = "none" })
			end
		end

		vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
		vim.api.nvim_set_hl(0, "TabLineSel", { bg = "none", bold = true })

		vim.api.nvim_set_hl(0, "tabline_a_normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "tabline_b_normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "tabline_b_normal_bold", { bg = "none", bold = true })
		vim.api.nvim_set_hl(0, "tabline_b_normal_italic", { bg = "none", italic = true })
		vim.api.nvim_set_hl(0, "tabline_b_normal_bold_italic", { bg = "none", bold = true, italic = true })
		vim.api.nvim_set_hl(0, "tabline_a_normal_bold", { bg = "none", bold = true })
		vim.api.nvim_set_hl(0, "tabline_a_normal_italic", { bg = "none", italic = true })
		vim.api.nvim_set_hl(0, "tabline_a_normal_bold_italic", { bg = "none", bold = true, italic = true })
		vim.api.nvim_set_hl(0, "tabline_a_to_b", { bg = "none" })
		vim.api.nvim_set_hl(0, "tabline_a_to_c", { bg = "none" })

		vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none", fg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeStatusLine", { bg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeTabInactive", { bg = "none" })
		vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", { bg = "none" })
	end

	vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })

	if M.transparent then
		vim.opt.fillchars:append({ vert = "┃", horiz = "━", vertleft = "┫", vertright = "┣", verthoriz = "╋" })
	else
		vim.opt.fillchars:append({ vert = "▐", horiz = "▄", vertleft = "▐", vertright = "▐", verthoriz = "▐" })
	end

	M.apply_bold()
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		M.apply()
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = function()
		M.apply()
	end,
})

return M
