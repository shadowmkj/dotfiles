return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = function()
        pcall(vim.cmd, "TSUpdate")
    end,
    lazy = false,
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter").setup({
            highlight = {
                enable = true,
                disable = { "rust", "tex" }, -- Disable treesitter for rust and tex
            },
        })

        local parsers = {
            "vimdoc",
            "javascript",
            "typescript",
            "c",
            "cpp",
            "lua",
            "python",
            "bash",
            "markdown",
            "markdown_inline",
            "rust",
        }

        require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                -- Disable treesitter for rust if desired
                if vim.bo[args.buf].filetype == "rust" then
                    return
                end

                -- Try starting treesitter; if the parser isn't ready yet,
                -- it won't crash your editor.
                local success = pcall(vim.treesitter.start, args.buf)
                if success then
                    -- Optional: Enable Treesitter indentation only if treesitter started successfully
                    vim.bo[args.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                end
            end,
        })
    end,
}
