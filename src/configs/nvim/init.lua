if vim.loader and vim.loader.enable then
	vim.loader.enable()
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.terminal")
require("config.whitespace")

require("plugins.autopairs")
require("plugins.colorscheme")
require("plugins.fff")
require("plugins.gitsigns")
require("plugins.mason")
require("plugins.lsp")
require("plugins.nvim-tree")
require("plugins.diffview")
require("plugins.treesitter")
