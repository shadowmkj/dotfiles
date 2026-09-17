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
			vim.keymap.set("n", "<leader>cc", "<cmd>below Recompile 10<CR>")
		end,
	},
}
