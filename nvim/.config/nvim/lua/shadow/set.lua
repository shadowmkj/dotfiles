vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
-- vim.opt.guifont = "Iosevka Nerd Font:h14"

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.vb = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.wildmode = "list:longest"
vim.opt.wildignore = ".hg,.svn,*~,*.png,*.jpg,*.gif,*.min.js,*.swp,*.o,vendor,dist,_site"

vim.g.base16colorspace = 256
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	float = { border = "rounded" },
})

vim.opt.cmdheight = 1

-- Disable built-in regex-based LaTeX syntax & ftplugin
vim.g.loaded_syntax = 1
vim.g.loaded_matchit = 1

vim.opt.conceallevel = 0
vim.opt.splitbelow = true

-- Python 3 provider for remote plugins (e.g. Molten)
local python3_host = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")
if vim.fn.filereadable(python3_host) == 1 then
	vim.g.python3_host_prog = python3_host
end
