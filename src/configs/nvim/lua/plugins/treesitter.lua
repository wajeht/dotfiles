vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("nvim-treesitter.configs").setup({
	sync_install = false, -- Sync install to avoid race conditions
	auto_install = true, -- Prevent parser installation errors

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false, -- Disable vim regex highlighting
	},
	-- enable indentation
	indent = { enable = true },
	-- enable autotagging (w/ nvim-ts-autotag plugin)
	autotag = {
		enable = true,
	},
	ensure_installed = {
		"json",
		"javascript",
		"typescript",
		"tsx",
		"vue",
		"yaml",
		"html",
		"css",
		-- "prisma",
		"markdown",
		"markdown_inline",
		"php",
		"bash",
		"lua",
		"vim",
		"go",
		"dockerfile",
		"gitignore",
		"sql",
		"vimdoc",
		"embedded_template", -- EJS, ERB, etc.
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = false,
			node_decremental = "<bs>",
		},
	},
	modules = {},
	ignore_install = {},
})

-- Fold settings using treesitter with error handling
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- Disable folding at startup

-- Filetype detection for template languages
vim.filetype.add({
	extension = {
		ejs = "embedded_template",
		html = "embedded_template",
	},
})
