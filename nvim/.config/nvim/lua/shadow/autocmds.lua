local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- =============================================================================
-- Helpers & Filetype Detection
-- =============================================================================

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

-- =============================================================================
-- Autocommand Groups
-- =============================================================================

local editor_group = augroup("ShadowEditor", { clear = true })
local filetypes_group = augroup("ShadowFileTypes", { clear = true })
local terminal_group = augroup("ShadowTerminal", { clear = true })

-- -----------------------------------------------------------------------------
-- General Editor Behavior (ShadowEditor)
-- -----------------------------------------------------------------------------

-- Highlight briefly on yank
autocmd("TextYankPost", {
	group = editor_group,
	pattern = "*",
	desc = "Briefly highlight yanked text",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- Strip trailing whitespace on save
autocmd("BufWritePre", {
	group = editor_group,
	pattern = "*",
	desc = "Remove trailing whitespace on save",
	command = [[%s/\s\+$//e]],
})

-- Restore cursor position when opening a file (skip git commit messages)
autocmd("BufReadPost", {
	group = editor_group,
	pattern = "*",
	desc = "Restore last cursor position on file open",
	callback = function()
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
			if not vim.fn.expand("%:p"):find(".git", 1, true) then
				vim.cmd('exe "normal! g\'\\""')
			end
		end
	end,
})

-- Disable automatic comment continuation when pressing 'o' or Enter
autocmd("FileType", {
	group = editor_group,
	pattern = "*",
	desc = "Disable automatic comment continuation on Enter or 'o'",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- -----------------------------------------------------------------------------
-- Language / Filetype Specific (ShadowFileTypes)
-- -----------------------------------------------------------------------------

-- LaTeX text wrapping and colorcolumn
autocmd("FileType", {
	group = filetypes_group,
	pattern = { "tex", "plaintex" },
	desc = "Configure LaTeX textwidth and colorcolumn",
	callback = function()
		vim.opt_local.textwidth = 80
		vim.opt_local.colorcolumn = "80"
		vim.opt_local.formatoptions:append("tc")
	end,
})

-- Rust column rule
autocmd("FileType", {
	group = filetypes_group,
	pattern = "rust",
	desc = "Set 100-character line guide for Rust",
	callback = function()
		vim.opt_local.colorcolumn = "100"
	end,
})

-- -----------------------------------------------------------------------------
-- Terminal Behavior (ShadowTerminal)
-- -----------------------------------------------------------------------------

-- Automatically exit insert mode when a terminal process completes
autocmd("TermClose", {
	group = terminal_group,
	pattern = "*",
	desc = "Stop insert mode when terminal process exits",
	callback = function()
		vim.cmd("stopinsert")
	end,
})

-- =============================================================================
-- Global Defaults & Tool Settings
-- =============================================================================

-- FZF defaults
vim.env.FZF_DEFAULT_COMMAND = "rg --hidden"

-- Disable Copilot by default if loaded
pcall(vim.cmd, "Copilot disable")

-- Netrw settings
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Transparent line numbers
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
