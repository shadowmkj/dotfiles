vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
--
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-w><", function()
	local count = vim.v.count > 0 and vim.v.count or 10
	vim.cmd("vertical resize -" .. count)
end)

vim.keymap.set("n", "<C-w>>", function()
	local count = vim.v.count > 0 and vim.v.count or 10
	vim.cmd("vertical resize +" .. count)
end)

-- Quick Save
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>q", "<cmd>:q<CR>")

-- Copy/Paste from/to clipboard
vim.keymap.set("x", "<leader>p", [["_dhp]])
vim.keymap.set("n", "<leader>P", [[ve"_dhp]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>K", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>J", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Move to beginning / end using homerow
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

vim.keymap.set("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Change till next _
-- vim.keymap.set("n", "<leader>m", "ct_")

-- Misc
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>")
vim.keymap.set("n", "<leader>ls", "<cmd>!leetrs submit %<CR>") -- submit to leetcode
vim.keymap.set("n", "<leader>lt", "<cmd>!leetrs test %<CR>") -- submit test to leetcode
vim.keymap.set("n", "<leader>tt", "<cmd>:Themery<CR>")
vim.keymap.set("n", "<leader>lr", "<cmd>:LiveRun<CR>")
vim.keymap.set("n", "<leader>o", "<C-w>o", { desc = "Close all windows except active" })

-- Toggle Github Copilot
-- vim.keymap.set("n", "<leader>cc", function()
--     local status = vim.g.copilot_enabled
--     vim.g.copilot_enabled = not status
--     print("Github Copilot: " .. (vim.g.copilot_enabled and "Enabled" or "Disabled"))
-- end)

-- wrap
vim.keymap.set("n", "<leader>uw", function()
	vim.wo.wrap = not vim.wo.wrap
end)

vim.keymap.set("i", "jk", "<Esc>")

-- let the left and right arrows be useful: they can switch buffers
-- vim.keymap.set("i", "<right>", "<nop>")
-- vim.keymap.set("i", "<left>", "<nop>")
-- vim.keymap.set("n", "<left>", ":bp<cr>")
-- vim.keymap.set("n", "<right>", ":bn<cr>")

-- Simple Zoom
vim.keymap.set("n", "<localleader>z", ":SimpleZoomToggle<CR>")

-- Tab navigation
vim.keymap.set("n", "<leader><Tab>", "<cmd>tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><S-Tab>", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })

-- Terminal command shortcut with Fish shell completion
local function fish_complete(arglead, cmdline, _)
	local shell_cmd = cmdline:gsub("^%s*T%s*", "")
	if shell_cmd == "" then
		shell_cmd = arglead
	end

	local handle = io.popen(string.format("fish -c 'complete -C %q' 2>/dev/null", shell_cmd))
	if not handle then
		return {}
	end
	local output = handle:read("*a")
	handle:close()

	local results = {}
	for line in output:gmatch("[^\r\n]+") do
		local candidate = line:match("^[^\t]+")
		if candidate and candidate ~= "" then
			table.insert(results, candidate)
		end
	end
	return results
end

vim.api.nvim_create_user_command("T", function(opts)
	vim.cmd("terminal " .. opts.args)
end, { nargs = "*", complete = fish_complete, desc = "Run terminal command with Fish completions" })

vim.cmd([[
  cnoreabbrev <expr> t (getcmdtype() == ':' && getcmdline() ==# 't') ? 'T' : 't'
]])

vim.keymap.set("n", "<leader>;", ":T ", { desc = "Terminal command" })
vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select all" })
