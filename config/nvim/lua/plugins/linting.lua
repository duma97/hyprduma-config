return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			python = { "ruff" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			lua = { "luacheck" },
			sh = { "shellcheck" },
		}

		local function try_lint()
			local ft = vim.bo.filetype
			local linters = lint.linters_by_ft[ft]
			if not linters then return end

			local available = {}
			for _, name in ipairs(linters) do
				if vim.fn.executable(name) == 1 then
					table.insert(available, name)
				end
			end
			if #available > 0 then
				lint.try_lint(available)
			end
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			callback = try_lint,
		})

		vim.keymap.set("n", "<leader>ll", try_lint, { desc = "Trigger linting" })
	end,
}
