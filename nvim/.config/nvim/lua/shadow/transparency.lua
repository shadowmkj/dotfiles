local M = {}

local state_file = vim.fn.stdpath("state") .. "/transparency_state"

local function read_saved_state()
    local f = io.open(state_file, "r")
    if f then
        local content = f:read("*all")
        f:close()
        return vim.trim(content) == "true"
    end
    return true
end

local function save_state(enabled)
    local f = io.open(state_file, "w")
    if f then
        f:write(enabled and "true" or "false")
        f:close()
    end
end

M.enabled = read_saved_state()
vim.g.transparent_enabled = M.enabled

-- Highlight groups cleared when editor transparency is ON
local transparent_editor_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "LineNr",
    "CursorLineNr",
    "FoldColumn",
    "Folded",
    "StatusLine",
    "StatusLineNC",
    "EndOfBuffer",
    "WinSeparator",
    "VertSplit",
}

function M.apply_lualine(is_transparent)
    local ok, lualine = pcall(require, "lualine")
    if not ok then return end

    package.loaded["lualine.themes.auto"] = nil
    local auto_theme_ok, auto_theme = pcall(require, "lualine.themes.auto")
    if not auto_theme_ok then return end

    local theme = vim.deepcopy(auto_theme)

    if is_transparent then
        for _, mode_table in pairs(theme) do
            if type(mode_table) == "table" then
                if mode_table.b then mode_table.b.bg = "NONE" end
                if mode_table.c then mode_table.c.bg = "NONE" end
                if mode_table.x then mode_table.x.bg = "NONE" end
                if mode_table.y then mode_table.y.bg = "NONE" end
            end
        end
    end

    lualine.setup({
        options = { theme = theme },
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

function M.apply()
    local is_transparent = vim.g.transparent_enabled

    -- Reload colorscheme highlights so ColorColumn inherits the active theme's native color dynamically
    local colorscheme = vim.g.colors_name
    if colorscheme then
        vim.cmd("colorscheme " .. colorscheme)
    end

    if is_transparent then
        for _, group in ipairs(transparent_editor_groups) do
            vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
        end
    end

    -- SignColumn must ALWAYS have full transparency
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE", ctermbg = "NONE" })

    -- ColorColumn naturally retains the active theme's dynamic background highlight!

    -- Re-apply custom comment highlights so they are preserved after colorscheme reloads
    local theme_ok, theme = pcall(require, "shadow.theme")
    if theme_ok and theme.apply_comments then
        theme.apply_comments()
    end

    M.apply_lualine(is_transparent)
end

function M.toggle()
    vim.g.transparent_enabled = not vim.g.transparent_enabled
    M.enabled = vim.g.transparent_enabled
    save_state(M.enabled)
    M.apply()

    local status = vim.g.transparent_enabled and "ENABLED" or "DISABLED"
    vim.notify("Neovim transparency: " .. status, vim.log.levels.INFO, { title = "Transparency" })
end

function M.setup()
    vim.api.nvim_create_user_command("TransparencyToggle", function()
        M.toggle()
    end, { desc = "Toggle Neovim editor transparency" })

    vim.keymap.set("n", "<leader>ut", function()
        M.toggle()
    end, { desc = "Toggle Transparency (Editor & Lualine)" })

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            M.apply()
        end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            M.apply()
        end,
    })

    M.apply()
end

return M
