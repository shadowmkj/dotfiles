-- ==============================================================================
-- Universal Theming & Highlight Configuration for Neovim
-- ==============================================================================

local M = {}

-- ------------------------------------------------------------------------------
-- Theme Defaults & Tinty Integration
-- ------------------------------------------------------------------------------

local default_theme = "base16-gruvbox-dark-hard"

-- ------------------------------------------------------------------------------
-- Comment Highlight Configuration
-- ------------------------------------------------------------------------------
-- Comments are styled with a highlighted, vibrant color instead of a muted gray.
-- You can easily change this color by updating `fg` below, selecting a preset,
-- or running the `:CommentColor <preset|hex>` command inside Neovim.

M.presets = {
	orange = "#fe8019", -- Bright Gruvbox Orange (Warm, high contrast, vibrant)
	yellow = "#fabd2f", -- Bright Gruvbox Yellow / Gold
	amber = "#ff9e3b", -- Electric Warm Amber
	green = "#b8bb26", -- Vivid Lime / Neon Green
	cyan = "#7dcfff", -- Vibrant Electric Cyan
	pink = "#d3869b", -- Vivid Magenta / Pink
	white = "#fbf1c7", -- High-contrast Bright Ivory
}

M.comment_config = {
	fg = M.presets.amber, -- Highlighted color for comments (change hex or preset here)
	italic = true, -- Italicize comments (true / false)
	bold = false, -- Bold comments (true / false)
}

--- Apply the configured comment highlight style across all comment groups.
function M.apply_comments()
	local hl = {
		fg = M.comment_config.fg,
		italic = M.comment_config.italic,
		bold = M.comment_config.bold,
	}

	-- Apply to standard Vim comments and Treesitter comment syntax groups
	local comment_groups = {
		"Comment",
		"@comment",
		"@comment.line",
		"@comment.block",
		"@comment.documentation",
		"SpecialComment",
	}

	for _, group in ipairs(comment_groups) do
		vim.api.nvim_set_hl(0, group, hl)
	end
end

--- Dynamically change the comment color and immediately apply it.
--- @param color string|table Either a hex code ("#fabd2f"), a preset name ("yellow"), or a config table
function M.set_comment_color(color)
	if type(color) == "table" then
		M.comment_config = vim.tbl_deep_extend("force", M.comment_config, color)
	elseif type(color) == "string" then
		local hex = M.presets[color:lower()] or color
		M.comment_config.fg = hex
	end
	M.apply_comments()
end

--- Register user commands for inspecting and changing comment colors on the fly.
function M.setup_user_commands()
	vim.api.nvim_create_user_command("CommentColor", function(opts)
		local arg = vim.trim(opts.args or "")
		if arg == "" then
			local current = M.comment_config.fg
			local preset_list = {}
			for name, hex in pairs(M.presets) do
				table.insert(preset_list, string.format("  • %s: %s", name, hex))
			end
			table.sort(preset_list)
			vim.notify(
				string.format(
					"Current comment color: %s\n\nPresets available:\n%s\n\nUsage: :CommentColor <hex|preset>",
					current,
					table.concat(preset_list, "\n")
				),
				vim.log.levels.INFO,
				{ title = "Comment Highlight" }
			)
			return
		end

		M.set_comment_color(arg)
		vim.notify("Comment color set to " .. M.comment_config.fg, vim.log.levels.INFO, { title = "Comment Highlight" })
	end, {
		desc = "Inspect or change comment highlight color (:CommentColor <hex|preset>)",
		nargs = "?",
		complete = function(arg_lead)
			local matches = {}
			for name, _ in pairs(M.presets) do
				if name:lower():find(arg_lead:lower(), 1, true) == 1 then
					table.insert(matches, name)
				end
			end
			table.sort(matches)
			return matches
		end,
	})
end

local function get_tinty_theme()
	local theme_name = vim.fn.system("MISE_QUIET=1 tinty current 2>/dev/null")
	theme_name = vim.trim(theme_name)

	if vim.v.shell_error ~= 0 or theme_name == "" then
		return default_theme
	else
		local lines = vim.split(theme_name, "\n", { trimempty = true })
		return lines[#lines] or default_theme
	end
end

local function main()
	vim.o.termguicolors = true
	vim.g.tinted_colorspace = 256
	local current_theme_name = get_tinty_theme()

	if current_theme_name == "base16-vague" then
		current_theme_name = "vague"
	end

	if current_theme_name == "gruber-darker" then
		current_theme_name = "base16-gruber-darker"
	end

	vim.cmd("colorscheme " .. current_theme_name)
	require("shadow.transparency").setup()
	M.apply_comments()
	M.setup_user_commands()
end

main()

return M
