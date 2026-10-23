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

-- Quarto Files

-- Close output window easily with 'q'
vim.api.nvim_create_autocmd("FileType", {
	pattern = "molten_output",
	group = filetypes_group,
	callback = function(event)
		vim.keymap.set("n", "q", ":q<CR>", { buffer = event.buf, silent = true, desc = "Close output" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = filetypes_group,
	pattern = "qmd",
	callback = function(event)
		require("quarto").setup(opts)
		local runner = require("quarto.runner")
		vim.keymap.set("n", "<leader>ma", runner.run_above, { buffer = event.buf, desc = "Run cell and above" })
		vim.keymap.set("n", "<leader>mb", runner.run_below, { buffer = event.buf, desc = "Run cell and below" })
		vim.keymap.set("n", "<leader>mA", runner.run_all, { buffer = event.buf, desc = "Run all cells" })
		-- Molten
		vim.keymap.set("n", "<leader>mm", "<cmd>:MoltenInit<CR>", { buffer = event.buf, desc = "Toggle image display" })
		vim.keymap.set(
			"n",
			"<localleader>E",
			":MoltenEvaluateOperator<CR>",
			{ silent = true, buffer = event.buf, desc = "run operator selection" }
		)
		vim.keymap.set(
			"n",
			"<localleader>md",
			":MoltenDelete<CR>",
			{ silent = true, buffer = event.buf, desc = "molten delete cell" }
		)
		vim.keymap.set(
			"n",
			"<localleader>ms",
			":MoltenShowOutput<CR>",
			{ silent = true, buffer = event.buf, desc = "Show output window" }
		)
		vim.keymap.set(
			"n",
			"<leader>me",
			":noautocmd MoltenEnterOutput<CR>",
			{ silent = true, buffer = event.buf, desc = "Focus output window" }
		)
		vim.keymap.set(
			"n",
			"<leader>mo",
			":MoltenHideOutput<CR>",
			{ silent = true, buffer = event.buf, desc = "Hide output window" }
		)
		vim.keymap.set("n", "<leader>mi", "<cmd>ImageToggle<CR>", { buffer = event.buf, desc = "Toggle image display" })

		local toggle = require("shadow.custom.toggle_quatro") -- adjust path to where you saved the module
		-- Toggle the output of the current cell
		vim.keymap.set("n", "<leader>mh", toggle.toggle_cell, { buffer = event.buf, desc = "Toggle cell output" })

		-- Toggle all outputs across the whole buffer
		vim.keymap.set("n", "<leader>mH", toggle.toggle_all, { buffer = event.buf, desc = "Toggle all outputs" })

		-- Toggle plot images via image.nvim
		vim.keymap.set("n", "<leader>mp", "<cmd>ImageToggle<CR>", { buffer = event.buf, desc = "Toggle plot images" })
	end,
})

-- Markdown Files
vim.api.nvim_create_autocmd("FileType", {
	group = filetypes_group,
	pattern = "markdown",
	callback = function(event)
		vim.keymap.set(
			"n",
			"<leader>m",
			"<cmd>RenderMarkdown toggle<CR>",
			{ buffer = event.buf, desc = "Toggle Markdown Rendering" }
		)
		vim.keymap.set(
			"n",
			"<leader>M",
			"<cmd>MarkdownPreview<CR>",
			{ buffer = event.buf, desc = "Toggle Markdown Rendering" }
		)
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
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

-- Clean up dead/zombie terminal buffers on startup
autocmd("VimEnter", {
	group = terminal_group,
	pattern = "*",
	desc = "Wipe out stale zombie terminal buffers on startup",
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf) then
				local name = vim.api.nvim_buf_get_name(buf)
				-- If it has a term:// name but no active channel or terminal job
				if name:match("^term://") and (vim.bo[buf].buftype ~= "terminal" or not vim.b[buf].terminal_job_id) then
					pcall(vim.api.nvim_buf_delete, buf, { force = true })
				end
			end
		end
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
