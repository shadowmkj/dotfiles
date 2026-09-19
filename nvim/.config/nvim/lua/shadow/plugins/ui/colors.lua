return {
    {
        "erikbackman/brightburn.vim",
    },
    { "vague-theme/vague.nvim" },
    {
        "RRethy/base16-nvim",
        name = "New16",
        lazy = false,    -- Load it immediately
        priority = 1000, -- Load it before other plugins
    },
    {
        "shadowmkj/gruber-darker.nvim",
        branch = 'main'
    }
}
