return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")
		wk.setup({
			delay = 300,
		})
		wk.add({
			{ "<leader>c", group = "Colorscheme" },
			{ "<leader>d", group = "Debug/Delete" },
			{ "<leader>g", group = "Git" },
			{ "<leader>h", group = "Harpoon/Hunks" },
			{ "<leader>r", group = "Run" },
			{ "<leader>s", group = "Split/Scratch" },
			{ "<leader>u", group = "Toggle/Undo" },
			{ "<leader>l", group = "Lint/LSP" },
			{ "<leader>f", group = "Format/Find" },
			{ "<leader>x", group = "Trouble" },
			{ "<leader>a", group = "AI/Arguments" },
			{ "<leader>sn", group = "Noice" },
		})
	end,
}
