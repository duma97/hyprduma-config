return {
	"nvim-treesitter/nvim-treesitter-context",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "VeryLazy",
	opts = {
		enable = true,
		max_lines = 3,
		min_window_height = 0,
		line_numbers = true,
		multiline_threshold = 20,
		trim_scope = "outer",
		mode = "cursor",
	},
	keys = {
		{
			"[x",
			function() require("treesitter-context").go_to_context(vim.v.count1) end,
			desc = "Jump to context",
			silent = true,
		},
	},
}
