return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		--- Switch to a Harpoon slot; if it's a dead terminal, spawn a new one and update the slot
		local function harpoon_smart_switch(index)
			local list = harpoon:list()
			local item = list:get(index)
			if not item then
				return
			end

			local path = item.value or ""

			-- Check if this Harpoon slot is a terminal
			if path:match("^term://") then
				-- 1. Check if the terminal is already alive in current session
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == path then
						if vim.b[buf].terminal_job_id then
							vim.api.nvim_set_current_buf(buf)
							vim.cmd("startinsert")
							return
						end
					end
				end

				-- 2. It is a dead terminal from a previous session!
				-- Wipe the old zombie buffer from memory if it exists
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == path then
						pcall(vim.api.nvim_buf_delete, buf, { force = true })
					end
				end

				-- 3. Spawn a fresh terminal in the current window
				vim.cmd("enew | term")
				local new_buf = vim.api.nvim_get_current_buf()
				local new_name = vim.api.nvim_buf_get_name(new_buf)

				-- 4. Re-assign the new live terminal path to this Harpoon index
				list.items[index] = {
					value = new_name,
					context = { row = 1, col = 0 },
				}

				vim.cmd("startinsert")
				return
			end

			-- Regular files: normal Harpoon select
			list:select(index)
		end

		-- add current file
		vim.keymap.set("n", "<leader>ba", function()
			harpoon:list():add()
		end, { desc = "Harpoon add file" })

		-- open quick menu
		vim.keymap.set("n", "<leader>0", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon menu" })

		-- jump to files
		vim.keymap.set("n", "<leader>1", function()
			harpoon_smart_switch(1)
		end, { desc = "Harpoon slot 1" })
		vim.keymap.set("n", "<leader>2", function()
			harpoon_smart_switch(2)
		end, { desc = "Harpoon slot 2" })
		vim.keymap.set("n", "<leader>3", function()
			harpoon_smart_switch(3)
		end, { desc = "Harpoon slot 3" })
		vim.keymap.set("n", "<leader>4", function()
			harpoon_smart_switch(4)
		end, { desc = "Harpoon slot 4" })
	end,
}
