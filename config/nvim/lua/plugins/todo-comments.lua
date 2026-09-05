return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = "VeryLazy",
	opts = {},
	keys = {
		{ "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO comment" },
		{ "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" },
		{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs (Trouble)" },
		{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
	},
}
