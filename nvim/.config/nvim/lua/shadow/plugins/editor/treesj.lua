return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
	config = function()
		require("treesj").setup({ --[[ your config ]]
			use_default_keymaps = false,
		})

		-- treesj
		-- Remap split, join, or toggle to your preferred key sequences
		vim.keymap.set("n", "<leader>u", require("treesj").toggle)
	end,
}
