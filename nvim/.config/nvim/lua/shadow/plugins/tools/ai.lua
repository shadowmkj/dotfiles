return {
	{
		"folke/sidekick.nvim",
		opts = {
			cli = {
				tools = {
					antigravity = {
						cmd = { "agy" },
					},
				},
			},
		},
		keys = {
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "Sidekick Toggle CLI",
			},
		},
	},
	{
		"shadowmkj/review.nvim",
		dir = "~/Documents/Desk/Apps/review.nvim",
		dev = true,
		dependencies = {
			"esmuellert/codediff.nvim",
			"MunifTanjim/nui.nvim",
		},
		cmd = { "Review" },
		keys = {
			{ "<leader>rv", "<cmd>Review<cr>", desc = "Review Diff" },
			{ "<leader>rq", "<cmd>Review qc<cr>", mode = { "n", "v" }, desc = "Review QuickComment" },
			{ "<leader>rp", "<cmd>Review qp<cr>", desc = "Review QuickPanel" },
			{ "<leader>re", "<cmd>Review export<cr>", desc = "Review Export" },
			{ "<leader>rc", "<cmd>Review clear<cr>", desc = "Review Clear" },
			{ "<leader>rs", "<cmd>Review send<cr>", desc = "Review Send" },
		},
		opts = {
			tmux = {
				auto_enter = true,
			},
			ui = {
				panels = {
					"file_tree",
					"comment_list",
				},
			},
		},
	},
}
