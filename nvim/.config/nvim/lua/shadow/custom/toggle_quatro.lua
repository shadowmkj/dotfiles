local M = {}

local hidden_cell_outputs = {} -- stashes hidden extmarks per cell

-- Find Molten's internal extmark namespace
local function get_molten_ns()
	for name, id in pairs(vim.api.nvim_get_namespaces()) do
		if name:match("molten") then
			return id
		end
	end
	return nil
end

-- Detect current cell start and end lines (supports Quarto and Python # %%)
local function get_cell_range()
	local bufnr = 0
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local total_lines = vim.api.nvim_buf_line_count(bufnr)
	local is_quarto = vim.bo.filetype == "quarto" or vim.bo.filetype == "markdown"

	local start_line = 1
	local end_line = total_lines

	if is_quarto then
		for l = cursor_line, 1, -1 do
			local line = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
			if line:match("^```%{[^}]+%}") then
				start_line = l
				break
			end
		end
		for l = cursor_line, total_lines do
			local line = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
			if line:match("^```%s*$") and l >= start_line then
				end_line = l
				break
			end
		end
	else
		for l = cursor_line, 1, -1 do
			local line = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
			if line:match("^# %%%%") then
				start_line = l
				break
			end
		end
		for l = cursor_line + 1, total_lines do
			local line = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
			if line:match("^# %%%%") then
				end_line = l - 1
				break
			end
		end
	end

	return start_line, end_line
end

-- Toggle virtual output for the cell under the cursor
function M.toggle_cell()
	local bufnr = vim.api.nvim_get_current_buf()
	local ns_id = get_molten_ns()
	if not ns_id then
		return
	end

	local start_line, end_line = get_cell_range()
	local key = bufnr .. ":" .. start_line

	if hidden_cell_outputs[key] then
		-- RESTORE: Re-apply stashed extmarks
		for _, mark in ipairs(hidden_cell_outputs[key]) do
			vim.api.nvim_buf_set_extmark(bufnr, ns_id, mark.row, mark.col, {
				id = mark.id,
				virt_lines = mark.details.virt_lines,
				virt_text = mark.details.virt_text,
				virt_text_pos = mark.details.virt_text_pos,
				virt_lines_above = mark.details.virt_lines_above,
				priority = mark.details.priority,
			})
		end
		hidden_cell_outputs[key] = nil
	else
		-- HIDE: Stash and remove extmarks in the current cell
		local marks = vim.api.nvim_buf_get_extmarks(
			bufnr,
			ns_id,
			{ math.max(0, start_line - 1), 0 },
			{ math.min(end_line, vim.api.nvim_buf_line_count(bufnr) - 1), -1 },
			{ details = true }
		)

		if #marks == 0 then
			return
		end

		local stashed = {}
		for _, m in ipairs(marks) do
			table.insert(stashed, { id = m[1], row = m[2], col = m[3], details = m[4] })
			vim.api.nvim_buf_del_extmark(bufnr, ns_id, m[1])
		end
		hidden_cell_outputs[key] = stashed
	end
end

-- Toggle all virtual outputs in the current buffer
function M.toggle_all()
	local bufnr = vim.api.nvim_get_current_buf()
	local ns_id = get_molten_ns()
	if not ns_id then
		return
	end

	local key_all = bufnr .. ":all"

	if hidden_cell_outputs[key_all] then
		for _, mark in ipairs(hidden_cell_outputs[key_all]) do
			vim.api.nvim_buf_set_extmark(bufnr, ns_id, mark.row, mark.col, {
				id = mark.id,
				virt_lines = mark.details.virt_lines,
				virt_text = mark.details.virt_text,
				virt_text_pos = mark.details.virt_text_pos,
				virt_lines_above = mark.details.virt_lines_above,
				priority = mark.details.priority,
			})
		end
		hidden_cell_outputs[key_all] = nil
	else
		local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns_id, 0, -1, { details = true })
		if #marks == 0 then
			return
		end

		local stashed = {}
		for _, m in ipairs(marks) do
			table.insert(stashed, { id = m[1], row = m[2], col = m[3], details = m[4] })
			vim.api.nvim_buf_del_extmark(bufnr, ns_id, m[1])
		end
		hidden_cell_outputs[key_all] = stashed
	end
end

return M
