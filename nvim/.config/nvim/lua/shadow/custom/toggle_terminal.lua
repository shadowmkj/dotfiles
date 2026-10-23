local M = {}

function M.open_first_terminal_bottom(height)
	height = height or 12 -- customize split height in lines

	-- 1. If we are already in a terminal window, or a terminal window is already open in current tab:
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		local name = vim.api.nvim_buf_get_name(buf)
		if name:match("^term://") or vim.bo[buf].buftype == "terminal" then
			vim.api.nvim_set_current_win(win)
			vim.cmd("startinsert")
			return
		end
	end

	-- 2. Search all buffers for the first one starting with 'term://'
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			if name:match("^term://") or vim.bo[buf].buftype == "terminal" then
				-- Open a bottom split with that buffer
				vim.cmd(string.format("botright %dsplit", height))
				vim.api.nvim_set_current_buf(buf)
				vim.cmd("startinsert")
				return
			end
		end
	end

	-- 3. Fallback: if no terminal exists at all, spawn a fresh one at the bottom
	vim.cmd(string.format("botright %dsp | term", height))
	vim.cmd("startinsert")
end

return M
