return {
	-- see the image.nvim readme for more information about configuring this plugin
	"3rd/image.nvim",
	opts = {
		backend = "kitty", -- whatever backend you would like to use
		-- max_width = 100,
		-- max_height = 12,
		max_height_window_percentage = math.huge,
		max_width_window_percentage = math.huge,
		window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
		tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown", "vimwiki", "quarto" }, -- include quarto here
				-- Set your desired limits here:
				max_width = 120, -- max width in columns/cells
				max_height = 24, -- max height in rows/lines
				-- Or use percentage of window:
				max_width_window_percentage = math.huge,
				max_height_window_percentage = math.huge,
				tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window
			},
		},
	},
	config = function(_, opts)
		require("image").setup(opts)

		-- Define ImageToggle command so <leader>mi / <leader>mp works
		vim.api.nvim_create_user_command("ImageToggle", function()
			local image = require("image")
			if image.is_enabled() then
				image.disable()
			else
				image.enable()
			end
		end, { desc = "Toggle image display" })
	end,
}
