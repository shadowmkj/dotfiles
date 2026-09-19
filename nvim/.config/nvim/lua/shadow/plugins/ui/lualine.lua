return {
    "nvim-lualine/lualine.nvim",
    config = function()
        local ok, transparency = pcall(require, "shadow.transparency")
        if ok then
            transparency.apply_lualine(vim.g.transparent_enabled ~= false)
        else
            require("lualine").setup({
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename' },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                extensions = { "quickfix", "mason", "fzf" },
            })
        end
    end
}

