return {
	{
		"lervag/vimtex",
		lazy = false, -- VimTeX recommends not lazy-loading
		init = function()
			-- VimTeX core settings
			vim.g.vimtex_view_method = "skim" -- Use "skim" on macOS, "zathura" on Linux
			vim.g.vimtex_compiler_method = "latexmk"

			-- Live preview / continuous compilation
			vim.g.vimtex_compiler_latexmk = {
				build_dir = "build", -- Optional: keeps root directory clean
				callback = 1,
				continuous = 1,
				executable = "latexmk",
				hooks = {},
				options = {
					"-verbose",
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",
				},
			}

			-- Quickfix window behavior on warnings/errors
			vim.g.vimtex_quickfix_mode = 0 -- 0: don't open, 1: open on errors, 2: open on errors/warnings
		end,
	},
}
