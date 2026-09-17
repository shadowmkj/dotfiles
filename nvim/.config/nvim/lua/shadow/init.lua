require("shadow.remap")
require("shadow.set")
require("shadow.lazy_init")
require("shadow.theme")

local augroup = vim.api.nvim_create_augroup
local ShadowGroup = augroup("ShadowGroup", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
	require("plenary.reload").reload_module(name)
end

-- Helper function to filter out external library definitions
local function goto_definition()
	local client = vim.lsp.get_clients({ bufnr = 0 })[1]
	local offset_encoding = client and client.offset_encoding or "utf-16"
	local params = vim.lsp.util.make_position_params(0, offset_encoding)
	vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, config)
		if err then
			vim.notify("LSP definition error: " .. err.message)
			return
		end

		if result == nil or vim.tbl_isempty(result) then
			print("Definition not found")
			return
		end

		-- If there's only one result, just go there
		if not vim.islist(result) then
			vim.lsp.util.show_document(result, "utf-8")
			return
		end

		-- If multiple results, filter out .cargo and .rustup
		local filtered_result = {}
		for _, location in ipairs(result) do
			local uri = location.uri or location.targetUri
			if not string.match(uri, "%.cargo") and not string.match(uri, "%.rustup") then
				table.insert(filtered_result, location)
			end
		end

		-- If our filter found the local definition, jump to it
		if #filtered_result > 0 then
			vim.lsp.util.show_document(filtered_result[1], "utf-8")
		else
			-- If everything was filtered out (or it's actually a library item),
			-- fall back to showing the original list
			vim.lsp.util.show_document(result[1], "utf-8")
		end
	end)
end

vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

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

autocmd({ "BufWritePre" }, {
	group = ShadowGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

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

autocmd("FileType", {
	pattern = { "tex", "plaintex" },
	callback = function()
		-- Set auto-wrap column limit to match colorcolumn
		vim.opt_local.textwidth = 80
		vim.opt_local.colorcolumn = "80"

		-- Enable auto-wrapping of text using textwidth ('t')
		-- and auto-wrapping of comments ('c')
		vim.opt_local.formatoptions:append("tc")
	end,
})

autocmd("FileType", {
	pattern = "typst",
	callback = function(event)
		vim.keymap.set("n", "<leader>ll", "<cmd>TypstPreview<cr>", {
			buffer = event.buf,
			desc = "Start Typst Preview",
			silent = true,
		})
	end,
})

-- autocmd("BufWritePre", {
--     group = vim.api.nvim_create_augroup("RustFormat", { clear = true }),
--     buffer = bufnr,
--     callback = function()
--         vim.lsp.buf.format({ bufnr = bufnr })
--     end,
-- })

autocmd("LspAttach", {
	group = ShadowGroup,
	callback = function(e)
		-- LSP keybinds
		local opts = { buffer = e.buf }
		vim.keymap.set("n", "gd", function()
			goto_definition()
		end, opts)
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({
				border = "rounded",
			})
		end, opts)
		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, opts)
		vim.keymap.set("n", "<leader>e", function()
			vim.diagnostic.open_float()
		end, opts)
		vim.keymap.set("n", "<leader>vrr", function()
			vim.lsp.buf.references()
		end, opts)
		vim.keymap.set("n", "<leader>=", function()
			vim.lsp.buf.format({ async = false })
		end, opts)
		vim.keymap.set("i", "<C-h>", function()
			vim.lsp.buf.signature_help()
		end, opts)
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1 })
		end, opts)
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1 })
		end, opts)
		vim.keymap.set({ "n", "v" }, "<leader>a", function()
			vim.lsp.buf.code_action()
		end, { desc = "LSP Code Action" })

		-- vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
		-- vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
		-- vim.keymap.set('n', '<leader>wl', function()
		--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		-- end, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>xq", vim.diagnostic.setloclist, opts)

		-- Add border to lsp hover (K)

		-- Disable semantic tokens completely
		-- This is to stop rust_analyser from overriding color scheme
		local client = vim.lsp.get_client_by_id(e.data.client_id)
		if client ~= nil then
			client.server_capabilities.semanticTokensProvider = nil
		end
		-- if not client or client.name ~= "rust_analyzer" then
		--     return
		-- end
		-- client.server_capabilities.semanticTokensProvider = nil
	end,
})

vim.env.FZF_DEFAULT_COMMAND = "rg --hidden"
vim.cmd([[:Copilot disable]])

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- For rust the columns must be at 100
autocmd("Filetype", { pattern = { "rust" }, command = "set colorcolumn=100" })

-- For transparent line number column
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
