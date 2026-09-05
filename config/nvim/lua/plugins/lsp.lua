return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					"ts_ls",
					"html",
					"cssls",
					"tailwindcss",
					"jsonls",
					"bashls",
				},
				automatic_enable = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})
			vim.lsp.enable("lua_ls")

			vim.lsp.config("pyright", { capabilities = capabilities })
			vim.lsp.enable("pyright")

			vim.lsp.config("ts_ls", { capabilities = capabilities })
			vim.lsp.enable("ts_ls")

			vim.lsp.config("html", { capabilities = capabilities })
			vim.lsp.enable("html")

			vim.lsp.config("cssls", { capabilities = capabilities })
			vim.lsp.enable("cssls")

			vim.lsp.config("tailwindcss", { capabilities = capabilities })
			vim.lsp.enable("tailwindcss")

			vim.lsp.config("jsonls", { capabilities = capabilities })
			vim.lsp.enable("jsonls")

			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.enable("bashls")

			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation" })
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to Definition" })
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to Declaration" })
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Go to Implementation" })
			vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP: Go to References" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename" })
			vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "LSP: Type Definition" })
			vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "LSP: Previous Diagnostic" })
			vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "LSP: Next Diagnostic" })
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "LSP: Show Diagnostic" })

			vim.diagnostic.config({
				virtual_text = false,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = true,
					header = "",
					prefix = "",
				},
			})
		end,
	},
}
