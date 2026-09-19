local augroup = vim.api.nvim_create_augroup
local ShadowGroup = augroup("ShadowGroup", {})
local yank_group = augroup("HighlightYank", {})
local autocmd = vim.api.nvim_create_autocmd

-- Helper function to reload plenary modules during dev
function R(name)
	require("plenary.reload").reload_module(name)
end

-- Custom filetype detection
vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- Strip trailing whitespace on save
autocmd({ "BufWritePre" }, {
	group = ShadowGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- Restore cursor position when opening a file
autocmd("BufReadPost", {
	pattern = "*",
	callback = function(_)
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
			if not vim.fn.expand("%:p"):find(".git", 1, true) then
				vim.cmd('exe "normal! g\'\\""')
			end
		end
	end,
})

-- LaTeX text wrapping and colorcolumn
autocmd("FileType", {
	pattern = { "tex", "plaintex" },
	callback = function()
		vim.opt_local.textwidth = 80
		vim.opt_local.colorcolumn = "80"
		vim.opt_local.formatoptions:append("tc")
	end,
})

-- Rust column rule
autocmd("FileType", {
	pattern = { "rust" },
	command = "set colorcolumn=100",
})

-- Global tool defaults
vim.env.FZF_DEFAULT_COMMAND = "rg --hidden"
pcall(vim.cmd, "Copilot disable")

-- Netrw settings
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Transparent line numbers
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
