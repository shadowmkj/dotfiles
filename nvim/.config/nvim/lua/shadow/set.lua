vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- vim.opt.guifont = "Iosevka Nerd Font:h14"

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.g.base16colorspace = 256
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	float = { border = "rounded" },
})

require("vim._core.ui2").enable()

-- Disable built-in regex-based LaTeX syntax & ftplugin
vim.g.loaded_syntax = 1
vim.g.loaded_matchit = 1

-- Enable conceallevel in .tex buffers
vim.opt.conceallevel = 1
vim.g.tex_conceal = "abdmg"
