vim.pack.add({
	{ src = "https://github.com/williamboman/mason.nvim" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
})

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"vtsls",
		"vue-language-server",
		"html",
		"cssls",
		"tailwindcss",
		"lua_ls",
		"emmet_language_server",
		"intelephense",
		"gopls",
	},
})
