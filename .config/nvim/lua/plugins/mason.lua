return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		require("mason").setup()
		local mason_lspconfig = require("mason-lspconfig")
		mason_lspconfig.setup({
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
	end,
}
