return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		config = function()
			-- Close output window easily with 'q'
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "molten_output",
				callback = function(event)
					vim.keymap.set("n", "q", ":q<CR>", { buffer = event.buf, silent = true, desc = "Close output" })
				end,
			})
		end,
		init = function()
			local python_host = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")
			if vim.fn.filereadable(python_host) == 1 then
				vim.g.python3_host_prog = python_host
			end

			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = false

			-- this guide will be using image.nvim
			-- Don't forget to setup and install the plugin if you want to view image outputs
			vim.g.molten_image_provider = "image.nvim"

			-- optional, I like wrapping. works for virt text and the output window
			vim.g.molten_wrap_output = true

			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			vim.g.molten_virt_text_output = true

			-- this will make it so the output shows up below the ``` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true

			vim.g.molten_output_win_max_height = 20

			-- Open and enter output window in a single keystroke
			vim.g.molten_enter_output_behavior = "open_and_enter"

			-- Show indicator in footer when output exceeds window height
			vim.g.molten_output_show_more = true
		end,
	},
	{
		"GCBallesteros/jupytext.nvim",
		config = true,
		-- Depending on your nvim distro or config you may need to make the loading not lazy
		-- lazy=false,
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			"benlubas/molten-nvim",
		},
		ft = { "quarto", "markdown" },
		opts = {
			lspFeatures = {
				enabled = true,
				chunks = "curly", -- targets ```{python} blocks
				languages = { "python" },
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			codeRunner = {
				enabled = true,
				default_method = "molten",
				never_run = { "yaml" },
			},
		},
		config = function(_, opts)
			require("quarto").setup(opts)

			local runner = require("quarto.runner")

			vim.keymap.set("n", "<leader>mc", runner.run_cell, { desc = "Run cell" })
			vim.keymap.set("n", "<leader>ma", runner.run_above, { desc = "Run cell and above" })
			vim.keymap.set("n", "<leader>mb", runner.run_below, { desc = "Run cell and below" })
			vim.keymap.set("n", "<leader>mA", runner.run_all, { desc = "Run all cells" })
		end,
	},
}
