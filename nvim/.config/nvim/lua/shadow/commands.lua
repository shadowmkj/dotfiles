vim.api.nvim_create_user_command("Conf", function()
	vim.cmd("tabnew")
	require("oil").open("~/.config/nvim")
	vim.cmd("tcd ~/.config/nvim")
end, { desc = "Open Neovim config in a new tab" })

local function close_matching_buffers(opts)
	local pattern = opts.args
	if pattern == "" then
		vim.notify("Pattern is required", vim.log.levels.WARN)
		return
	end

	local function matches(str, pat)
		local ok_reg, reg = pcall(vim.regex, pat)
		if ok_reg and reg then
			return reg:match_str(str) ~= nil
		end
		local ok_pat, matched = pcall(string.match, str, pat)
		return ok_pat and (matched ~= nil)
	end

	local count = 0
	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
			local name = vim.api.nvim_buf_get_name(buf)
			local tail = vim.fn.fnamemodify(name, ":t")
			if matches(name, pattern) or (tail ~= "" and matches(tail, pattern)) then
				local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = opts.bang })
				if ok then
					count = count + 1
				else
					vim.notify(
						string.format("Failed to close buffer %d (%s): %s", buf, name, err),
						vim.log.levels.ERROR
					)
				end
			end
		end
	end

	vim.notify(string.format("Closed %d buffer(s) matching '%s'", count, pattern), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("Bclose", close_matching_buffers, {
	nargs = 1,
	bang = true,
	desc = "Close buffers matching a regex pattern",
})

vim.api.nvim_create_user_command("BdeleteRegex", close_matching_buffers, {
	nargs = 1,
	bang = true,
	desc = "Close buffers matching a regex pattern",
})
