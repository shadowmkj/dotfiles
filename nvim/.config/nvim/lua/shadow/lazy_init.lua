local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "shadow.plugins.ui" },
		{ import = "shadow.plugins.editor" },
		{ import = "shadow.plugins.lsp" },
		{ import = "shadow.plugins.git" },
		{ import = "shadow.plugins.lang" },
		{ import = "shadow.plugins.tools" },
	},
	change_detection = { notify = false },
})

