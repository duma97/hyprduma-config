return {

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			require("dap-python").setup("python3")

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set("n", "<leader>db", function()
				require("dap").toggle_breakpoint()
			end, { desc = "Debug: Toggle Breakpoint" })

			vim.keymap.set("n", "<leader>dc", function()
				require("dap").continue()
			end, { desc = "Debug: Continue" })

			vim.keymap.set("n", "<leader>di", function()
				require("dap").step_into()
			end, { desc = "Debug: Step Into" })

			vim.keymap.set("n", "<leader>do", function()
				require("dap").step_over()
			end, { desc = "Debug: Step Over" })

			vim.keymap.set("n", "<leader>dO", function()
				require("dap").step_out()
			end, { desc = "Debug: Step Out" })

			vim.keymap.set("n", "<leader>dr", function()
				require("dap").repl.open()
			end, { desc = "Debug: Open REPL" })

			vim.keymap.set("n", "<leader>dl", function()
				require("dap").run_last()
			end, { desc = "Debug: Run Last" })

			vim.keymap.set("n", "<leader>dt", function()
				require("dapui").toggle()
			end, { desc = "Debug: Toggle UI" })

			vim.keymap.set("n", "<leader>dx", function()
				require("dap").terminate()
			end, { desc = "Debug: Terminate" })
		end,
	},
}
