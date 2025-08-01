return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		dependencies = "rafamadriz/friendly-snippets",
		version = "1.*",
		opts = {
			keymap = {
				preset = "default",
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<D-i>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_and_accept", "fallback" },
			},

			completion = {
				documentation = {
					auto_show = false,
					auto_show_delay_ms = 0,
				},
				-- ghost_text = { enabled = true },
			},

			appearance = {
				-- use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			sources = {
				default = {
					"lsp",
					-- "buffer",
					"snippets",
					"path",
				},
			},

			signature = { enabled = true },
		},
	},
}
