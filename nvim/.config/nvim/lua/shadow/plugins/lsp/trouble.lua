return {
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = {},
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Toggle Trouble"
            },

            {
                "<leader>j",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Toggle Trouble Diag for buffer"
            },

            {
                "<leader>xk",
                "<cmd>Trouble quickfix toggle<cr>",
                desc = "Toggle Trouble Quickfix"
            },

            {
                "<leader>xl",
                "<cmdTrouble lsp_definitions toggle<cr>",
                desc = "Toggle Go to Definition"
            },

            {
                "<leader>L",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            { "[t", "<cmdTroublePrevious<cr>", desc = "Previous Trouble Item" },
            { "]t", "<cmd>TroubleNext<cr>",    desc = "Next Trouble Item" },
        },
    },
}
