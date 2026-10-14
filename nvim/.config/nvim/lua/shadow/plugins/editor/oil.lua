-- ==============================================================================
-- Oil.nvim Configuration
-- ==============================================================================
-- Oil is a file explorer that lets you edit your filesystem like a normal buffer.
-- This configuration sets up a clean column view with metadata highlights, custom
-- fuzzy finding via fzf-lua, and zoxide integration for rapid jumping.

-- ==============================================================================
-- Fuzzy Navigation Helpers
-- ==============================================================================

--- Run fzf-lua against a target directory using fd, then open the chosen item in Oil.
--- Also allows pressing <Ctrl-o> to immediately open the root directory in Oil.
---@param base_dir? string Directory to search inside (defaults to current Oil directory)
---@param prompt? string Prompt title for the fzf picker
local function find_and_open_in_oil(base_dir, prompt)
	local oil = require("oil")
	local fzf = require("fzf-lua")
	local path_util = require("fzf-lua.path")

	if not base_dir or base_dir == "" then
		base_dir = oil.get_current_dir()
	end

	if not base_dir then
		return
	end

	fzf.fzf_exec("fd --type d --type f --hidden --exclude .git", {
		cwd = base_dir,
		prompt = prompt or "Dirs> ",
		actions = {
			["default"] = function(selected)
				if selected and #selected > 0 then
					-- Strip fzf-lua markup or headers to get the relative path
					local entry_path = path_util.entry_to_file(selected[1]).path
					local target = vim.fs.normalize(base_dir .. "/" .. entry_path)
					oil.open(target)
				end
			end,
			["ctrl-o"] = function()
				oil.open(base_dir)
			end,
		},
	})
end

--- Query zoxide for a matching directory path.
--- Returns nil if zoxide is unavailable, input is blank, or no match is found.
---@param input? string Search term passed to zoxide
---@return string? resolved_dir
local function resolve_zoxide_dir(input)
	local query = vim.trim(input or "")
	if query == "" then
		return nil
	end

	if vim.fn.executable("zoxide") ~= 1 then
		vim.notify("Oil: zoxide is not installed or not in PATH", vim.log.levels.WARN)
		return nil
	end

	local words = vim.split(query, "%s+", { trimempty = true })
	if #words == 0 then
		return nil
	end

	local cmd = vim.list_extend({ "zoxide", "query", "--" }, words)
	local obj = vim.system(cmd, { text = true }):wait()
	if obj.code == 0 and obj.stdout then
		local dir = vim.trim(obj.stdout)
		if dir ~= "" and vim.fn.isdirectory(dir) == 1 then
			return dir
		end
	end

	return nil
end

-- ==============================================================================
-- Plugin Specification
-- ==============================================================================

return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	-- Lazy loading is not recommended by oil.nvim authors because it is tricky to handle directory hijack correctly.
	lazy = false,

	config = function(_, _)
		require("oil").setup({
			-- --------------------------------------------------------------------------
			-- General Settings
			-- --------------------------------------------------------------------------
			use_default_keymaps = false,
			skip_confirm_for_simple_edits = true,
			delete_to_trash = true,
			view_options = {
				show_hidden = true,
			},

			-- --------------------------------------------------------------------------
			-- Column Layout & Highlighting
			-- --------------------------------------------------------------------------
			columns = {
				{ "icon" },
				{
					"permissions",
					highlight = "Comment", -- Muted grey
				},
				{
					"size",
					highlight = "Special", -- Distinguishable size metadata
				},
				{
					"mtime",
					highlight = "Number", -- Readable timestamp
				},
			},

			-- --------------------------------------------------------------------------
			-- Buffer Keymaps
			-- --------------------------------------------------------------------------
			keymaps = {
				-- Information & Actions
				["g?"] = { "actions.show_help", mode = "n" },
				["<CR>"] = "actions.select",
				["gx"] = "actions.open_external",

				-- Navigation
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },

				-- Toggles & View Controls
				["gs"] = { "actions.change_sort", mode = "n" },
				["g."] = { "actions.toggle_hidden", mode = "n" },
				["g\\"] = { "actions.toggle_trash", mode = "n" },
				["<C-p>"] = {
					"actions.preview",
					opts = { split = "belowright" },
				},
				["go"] = {
					desc = "Open file in desktop app",
					callback = function()
						local oil = require("oil")
						local entry = oil.get_cursor_entry()
						if not entry then
							return
						end
						local dir = oil.get_current_dir()
						if not dir then
							return
						end
						local path = vim.fs.joinpath(dir, entry.name)

						local cmd
						if vim.fn.has("mac") == 1 then
							cmd = { "open", path }
						elseif vim.fn.has("unix") == 1 then
							cmd = { "xdg-open", path }
						elseif vim.fn.has("win32") == 1 then
							cmd = { "cmd", "/c", "start", "", path }
						else
							vim.notify("System open not supported on this OS", vim.log.levels.WARN)
							return
						end

						vim.system(cmd, { detach = true })
					end,
				},

				-- Fuzzy Find in Current Oil Directory
				["gd"] = {
					desc = "Fuzzy search folder/files in current Oil directory",
					callback = function()
						local oil = require("oil")
						find_and_open_in_oil(oil.get_current_dir(), "Dirs> ")
					end,
				},
				["<C-f>"] = {
					desc = "Jump to dir using Zoxide in Oil",
					callback = function()
						vim.ui.input({
							prompt = "Query: ",
							completion = "dir",
							default = "",
						}, function(input)
							if input == nil then
								return -- User cancelled input prompt
							end

							local oil = require("oil")
							local current_dir = oil.get_current_dir()
							local target_dir = resolve_zoxide_dir(input) or current_dir
							oil.open(target_dir)
						end)
					end,
				},

				-- Jump via Zoxide then Fuzzy Find
				["gf"] = {
					desc = "Fuzzy search directory via Zoxide in Oil",
					callback = function()
						vim.ui.input({
							prompt = "Query: ",
							completion = "dir",
							default = "",
						}, function(input)
							if input == nil then
								return -- User cancelled input prompt
							end

							local oil = require("oil")
							local current_dir = oil.get_current_dir()
							local target_dir = resolve_zoxide_dir(input) or current_dir

							find_and_open_in_oil(target_dir, "Dirs> ")
						end)
					end,
				},
			},
		})

		-- Global mapping to open Oil at the parent directory of current buffer
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
}
