if true then
    return {}
end
return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        routes = {
            {
                -- This route catches all shell commands (!)
                -- and sends them to a "popup" view so you don't miss them.
                filter = {
                    event = "msg_show",
                    kind = "",
                    find = "!",
                },
                opts = { skip = false },
                view = "popup", -- or "split" if you prefer a bottom window
            },
        },
    },
}
