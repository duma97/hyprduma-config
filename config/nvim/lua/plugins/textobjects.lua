return {
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		config = function()
			local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

			local select_keymaps = {
				["af"] = { query = "@function.outer", desc = "Select around function" },
				["if"] = { query = "@function.inner", desc = "Select inside function" },
				["ac"] = { query = "@class.outer", desc = "Select around class" },
				["ic"] = { query = "@class.inner", desc = "Select inside class" },
				["aa"] = { query = "@parameter.outer", desc = "Select around argument" },
				["ia"] = { query = "@parameter.inner", desc = "Select inside argument" },
				["ai"] = { query = "@conditional.outer", desc = "Select around conditional" },
				["ii"] = { query = "@conditional.inner", desc = "Select inside conditional" },
				["al"] = { query = "@loop.outer", desc = "Select around loop" },
				["il"] = { query = "@loop.inner", desc = "Select inside loop" },
			}

			for key, mapping in pairs(select_keymaps) do
				vim.keymap.set({ "x", "o" }, key, function()
					require("nvim-treesitter-textobjects.select").select_textobject(mapping.query, "textobjects")
				end, { desc = mapping.desc })
			end

			local move_next = {
				["]f"] = { query = "@function.outer", desc = "Next function start" },
				["]c"] = { query = "@class.outer", desc = "Next class start" },
				["]a"] = { query = "@parameter.inner", desc = "Next argument" },
			}
			local move_next_end = {
				["]F"] = { query = "@function.outer", desc = "Next function end" },
				["]C"] = { query = "@class.outer", desc = "Next class end" },
			}
			local move_prev = {
				["[f"] = { query = "@function.outer", desc = "Previous function start" },
				["[c"] = { query = "@class.outer", desc = "Previous class start" },
				["[a"] = { query = "@parameter.inner", desc = "Previous argument" },
			}
			local move_prev_end = {
				["[F"] = { query = "@function.outer", desc = "Previous function end" },
				["[C"] = { query = "@class.outer", desc = "Previous class end" },
			}

			local move = require("nvim-treesitter-textobjects.move")

			for key, mapping in pairs(move_next) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_next_start(mapping.query, "textobjects")
				end, { desc = mapping.desc })
			end
			for key, mapping in pairs(move_next_end) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_next_end(mapping.query, "textobjects")
				end, { desc = mapping.desc })
			end
			for key, mapping in pairs(move_prev) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_previous_start(mapping.query, "textobjects")
				end, { desc = mapping.desc })
			end
			for key, mapping in pairs(move_prev_end) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_previous_end(mapping.query, "textobjects")
				end, { desc = mapping.desc })
			end

			local swap = require("nvim-treesitter-textobjects.swap")
			vim.keymap.set("n", "<leader>an", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap with next argument" })
			vim.keymap.set("n", "<leader>ap", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap with previous argument" })

			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
		end,
	},
}
