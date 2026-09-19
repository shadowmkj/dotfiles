return {
    {
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        opts = {},

    },
    {
        "folke/todo-comments.nvim",
        lazy = false,
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
        },
        keys = {
            { "<leader>st", function() require("todo-comments.fzf").todo() end,                                          desc = "Todo" },
            { "<leader>sT", function() require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
        },
        config = function()
            require('todo-comments').setup({
                keywords = {
                    IMP = {
                        icon = "",
                        color = "error",
                        alt = { "IMPORTANT" }
                    }
                }
            })
        end
    }
}
