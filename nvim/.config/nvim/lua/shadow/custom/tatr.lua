local M = {}

--- Opens the TASK.md file corresponding to the provided HUID using `tatr find`.
--- If no HUID is provided, attempts to grab one from under the cursor or prompts the user.
--- @param huid? string
function M.open(huid)
	if not huid or huid == "" then
		local cword = vim.fn.expand("<cWORD>")
		local match = cword:match("%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d[%-%w]*")
		if match then
			huid = match
		else
			vim.ui.input({ prompt = "Task HUID: " }, function(input)
				if input and input ~= "" then
					M.open(input)
				end
			end)
			return
		end
	end

	huid = vim.trim(tostring(huid))

	if vim.fn.executable("tatr") ~= 1 then
		vim.notify("tatr executable not found in PATH", vim.log.levels.ERROR)
		return
	end

	local obj = vim.system({ "tatr", "find", huid, "-path-only" }, { text = true }):wait()
	if obj.code ~= 0 then
		local err = vim.trim(obj.stderr ~= "" and obj.stderr or obj.stdout)
		vim.notify(err ~= "" and err or ("Failed to find task with HUID: " .. huid), vim.log.levels.ERROR)
		return
	end

	local path = vim.trim(obj.stdout)
	local clean_path = path:match("^([^:]+)") or path
	if clean_path == "" then
		vim.notify("No path returned for task with HUID: " .. huid, vim.log.levels.ERROR)
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(clean_path))
end

function M.fzf(opts)
	opts = opts or {}
	if vim.fn.executable("tatr") ~= 1 then
		vim.notify("tatr executable not found in PATH", vim.log.levels.ERROR)
		return
	end

	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		vim.notify("fzf-lua is required for Tatr fzf", vim.log.levels.ERROR)
		return
	end

	-- Quick pre-check to give a friendly notification if tasks/ folder doesn't exist
	local check = vim.system({ "tatr", "ls" }, { text = true }):wait()
	if check.code ~= 0 then
		local err = vim.trim(check.stderr ~= "" and check.stderr or check.stdout)
		vim.notify(err ~= "" and err or "No tasks found or tasks/ directory missing", vim.log.levels.WARN)
		return
	end

	if vim.trim(check.stdout) == "" then
		vim.notify("No tasks found in current repository", vim.log.levels.INFO)
		return
	end

	local cmd = "tatr ls"
	if opts.args and opts.args ~= "" then
		cmd = cmd .. " " .. opts.args
	end

	fzf.fzf_exec(cmd, {
		prompt = "Tatr Tasks> ",
		actions = fzf.defaults.actions.files,
		previewer = "builtin",
		fzf_opts = {
			["--header"] = ":: <CR> open | <C-v> vsplit | <C-s> split | <C-t> tab",
		},
	})
end

function M.get_tatr_huid(opts)
	local arg = opts and opts.args and vim.trim(opts.args) or nil
	if arg and arg ~= "" then
		if arg == "fzf" or arg:match("^fzf%s*") then
			local fzf_args = arg:match("^fzf%s+(.*)$") or ""
			M.fzf({ args = fzf_args })
		else
			M.open(arg)
		end
	else
		M.open()
	end
end

--- Checks if cursor is currently over a HUID wrapped in brackets: (huid) or [huid].
--- @return string? huid
function M.get_huid_at_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed

	local patterns = {
		"%(%s*(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d[%w%-_]*)%s*%)",
		"%[%s*(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d[%w%-_]*)%s*%]",
	}

	for _, pat in ipairs(patterns) do
		local s = 1
		while true do
			local start_idx, end_idx, huid = line:find(pat, s)
			if not start_idx then
				break
			end
			if col >= start_idx and col <= end_idx then
				return huid:gsub("%-+$", "")
			end
			s = end_idx + 1
		end
	end

	return nil
end

--- Tries to open a task by HUID without throwing errors if not found.
--- @param huid string
--- @return boolean success
function M.try_open(huid)
	if vim.fn.executable("tatr") ~= 1 then
		return false
	end

	local obj = vim.system({ "tatr", "find", huid, "-path-only" }, { text = true }):wait()
	if obj.code ~= 0 then
		return false
	end

	local path = vim.trim(obj.stdout)
	local clean_path = path:match("^([^:]+)") or path
	if clean_path == "" then
		return false
	end

	vim.cmd.edit(vim.fn.fnameescape(clean_path))
	return true
end

--- Opens tatr task if cursor is on a HUID, otherwise falls back to default `gf`.
function M.open_or_gf()
	local huid = M.get_huid_at_cursor()
	if huid then
		local ok = M.try_open(huid)
		if ok then
			return
		end
	end

	-- Fallback to native unmapped gf
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gf", true, false, true), "n", false)
end

return M
