return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
	config = function(_, _)
		require("oil").setup({
			use_default_keymaps = false,
			skip_confirm_for_simple_edits = true,
			delete_to_trash = true,
			columns = {
				{ "icon" },
				{
					"permissions",
					highlight = "Comment", -- Muted grey
				},
				{
					"size",
					highlight = "Special", -- Often cyan or orange depending on colorscheme
				},
				{
					"mtime",
					highlight = "Number", -- Often purple or yellow
				},
			},
			keymaps = {
				["g?"] = { "actions.show_help", mode = "n" },
				["<CR>"] = "actions.select",
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["gx"] = "actions.open_external",
				["g."] = { "actions.toggle_hidden", mode = "n" },
				["g\\"] = { "actions.toggle_trash", mode = "n" },
				["<C-p>"] = {
					"actions.preview",
					opts = {
						split = "belowright",
					},
				},
				["gd"] = {
					"Open Folder",
					callback = function()
						local oil = require("oil")
						local current_dir = oil.get_current_dir()
						require("fzf-lua").fzf_exec("fd --type d --type f --hidden --exclude .git", {
							cwd = current_dir,
							prompt = "Dirs> ",
							actions = {
								["default"] = function(selected)
									if selected and #selected > 0 then
										-- Strip fzf-lua markup or headers if present
										local path = require("fzf-lua.path").entry_to_file(selected[1]).path
										local target = vim.fs.normalize(current_dir .. "/" .. path)
										oil.open(target)
									end
								end,
								["ctrl-o"] = function()
									oil.open(current_dir)
								end,
							},
						})
					end,
				},
				["<C-f>"] = {
					desc = "Fuzzy search and open directory in Oil",
					callback = function()
						vim.ui.input({
							prompt = "Query: ",
							completion = "dir",
							default = "",
						}, function(input)
							local oil = require("oil")
							local handle = io.popen("zoxide query " .. input)
							if not handle then
								vim.notify("Error: failed to run zoxide")
								return
							end
							local result = handle:read("*a")
							handle:close()
							local dir = vim.trim(result)
							local current_dir = dir or oil.get_current_dir()
							require("fzf-lua").fzf_exec("fd --type d --type f --hidden --exclude .git", {
								cwd = current_dir,
								prompt = "Dirs> ",
								actions = {
									["default"] = function(selected)
										if selected and #selected > 0 then
											-- Strip fzf-lua markup or headers if present
											local path = require("fzf-lua.path").entry_to_file(selected[1]).path
											local target = vim.fs.normalize(current_dir .. "/" .. path)
											oil.open(target)
										end
									end,
									["ctrl-o"] = function()
										oil.open(current_dir)
									end,
								},
							})
						end)
					end,
				},
			},
		})
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
}
