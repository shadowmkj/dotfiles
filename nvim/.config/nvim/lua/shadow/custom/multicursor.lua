local M = {}

local ns = vim.api.nvim_create_namespace("nvim.multicursor")
local state = {
	pattern = nil,
}

local function ensure_mc_enabled()
	pcall(function()
		require("vim._core.mcursor").enable(true)
	end)
end

function M.active()
	return #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { limit = 1 }) > 0
end

function M.clear()
	if M.active() then
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
	end
	state.pattern = nil
	vim.cmd("nohlsearch")
end

function M.add_word_or_next()
	ensure_mc_enabled()

	if not M.active() then
		-- First press: start session with word under cursor
		local word = vim.fn.expand("<cword>")
		if not word or word == "" then
			return
		end

		state.pattern = "\\<" .. vim.fn.escape(word, "\\/.*$^~[]") .. "\\>"

		-- Move cursor to start of current word
		vim.fn.search(state.pattern, "bcW")
		local cur_pos = vim.api.nvim_win_get_cursor(0)

		-- Place multicursor mark at original word
		vim.cmd("normal! 1Q")

		-- Jump to next occurrence
		local found = vim.fn.search(state.pattern, "W")
		if found == 0 then
			found = vim.fn.search(state.pattern, "w")
		end

		local new_pos = vim.api.nvim_win_get_cursor(0)
		if new_pos[1] == cur_pos[1] and new_pos[2] == cur_pos[2] then
			vim.notify("No other matches for '" .. word .. "'", vim.log.levels.INFO)
			vim.cmd("normal! 2Q")
			state.pattern = nil
			return
		end
	else
		-- Subsequent press: place cursor at current match, then jump to next
		if not state.pattern then
			local word = vim.fn.expand("<cword>")
			state.pattern = "\\<" .. vim.fn.escape(word, "\\/.*$^~[]") .. "\\>"
		end

		vim.cmd("normal! 1Q")

		local found = vim.fn.search(state.pattern, "W")
		if found == 0 then
			found = vim.fn.search(state.pattern, "w")
		end
	end
end

function M.add_visual_or_next()
	ensure_mc_enabled()

	-- Exit visual mode to set '< and '> marks
	vim.cmd("normal! \27")

	local s_pos = vim.fn.getpos("'<")
	local e_pos = vim.fn.getpos("'>")
	local lines = vim.api.nvim_buf_get_text(0, s_pos[2] - 1, s_pos[3] - 1, e_pos[2] - 1, e_pos[3], {})
	local text = table.concat(lines, "\n")
	if not text or text == "" then
		return
	end

	state.pattern = vim.fn.escape(text, "\\/.*$^~[]")

	-- Move cursor to start of visual selection
	vim.api.nvim_win_set_cursor(0, { s_pos[2], s_pos[3] - 1 })
	local cur_pos = vim.api.nvim_win_get_cursor(0)

	vim.cmd("normal! 1Q")

	local found = vim.fn.search(state.pattern, "W")
	if found == 0 then
		found = vim.fn.search(state.pattern, "w")
	end

	local new_pos = vim.api.nvim_win_get_cursor(0)
	if new_pos[1] == cur_pos[1] and new_pos[2] == cur_pos[2] then
		vim.notify("No other matches for selection", vim.log.levels.INFO)
		vim.cmd("normal! 2Q")
		state.pattern = nil
	end
end

function M.skip_next()
	if not M.active() or not state.pattern then
		return
	end

	local found = vim.fn.search(state.pattern, "W")
	if found == 0 then
		found = vim.fn.search(state.pattern, "w")
	end
end

return M
