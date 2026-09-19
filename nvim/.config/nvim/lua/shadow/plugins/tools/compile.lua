return {
	{
		"shadowmkj/compile-mode.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "m00qek/baleia.nvim", tag = "v1.3.0" },
		},
		config = function()
			---@type CompileModeOpts
			vim.g.compile_mode = {
				input_word_completion = true,
				recompile_no_fail = true,
				baleia_setup = true,
				bang_expansion = true,
				use_pseudo_terminal = true, -- forces CLI tools to output ANSI colors
				environment = {
					FORCE_COLOR = "1",
					CLICOLOR_FORCE = "1",
					CARGO_TERM_COLOR = "always",
				},
				default_command = {
					python = "python3 %",
					lua = "lua %",
					javascript = "bun %",
					typescript = "bun %",
					c = "gcc -o %:r % && ./%:r",
					cpp = "gcc -std=c++23 -o %:r % && ./%:r",
					java = "javac % && java %:r",
					go = "go run %",
					rust = "cargo run",
				},
			}
			-- Default compilation split window to open at the bottom with a compact height
			local utils = require("compile-mode.utils")
			local orig_split_unless_open = utils.split_unless_open
			utils.split_unless_open = function(opts, smods, count)
				smods = smods or {}
				if not smods.split or smods.split == "" then
					smods.split = "belowright"
				end
				if not count or count == 0 then
					count = 8
				end
				return orig_split_unless_open(opts, smods, count)
			end

			vim.keymap.set("n", "<leader>cc", "<cmd>Recompile<CR>", { desc = "Recompile" })
		end,
	},
}
