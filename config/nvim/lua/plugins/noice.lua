return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		{ "rcarriga/nvim-notify", opts = { background_colour = "#000000" } },
	},
	opts = {
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
					},
				},
				view = "mini",
			},
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = false,
		},
	},
	keys = {
		{ "<leader>sn", "", desc = "+Noice" },
		{ "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
		{ "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
		{ "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
		{ "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
		{ "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
	},
}
