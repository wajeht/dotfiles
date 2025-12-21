-- Load VSCode-inspired colorscheme
vim.o.background = "dark"
vim.cmd("colorscheme vscode")

-- Custom statusline for terminal buffers
vim.cmd("set laststatus=0") -- Disable default statusline
vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)
