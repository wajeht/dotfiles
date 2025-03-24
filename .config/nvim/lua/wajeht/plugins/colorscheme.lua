return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				background = {
					light = "latte",
					dark = "mocha",
				},
				transparent_background = true,
				show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
				term_colors = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					telescope = true,
					treesitter = true,
				},
			})

			vim.cmd("colorscheme catppuccin")

			-- Custom statusline for terminal buffers
			vim.cmd("set laststatus=0") -- Disable default statusline
			vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

			vim.cmd("hi StatusLine gui=NONE guibg=#181823 guifg=#181823") -- GUI background transparent
			vim.cmd("hi StatusLineNC gui=NONE guibg=#181823 guifg=#181823") -- Inactive StatusLine transparent for GUI

			-- Terminal background color
			vim.api.nvim_create_autocmd("TermOpen", {
				callback = function()
					vim.api.nvim_set_hl(0, 'Terminal', { bg = '#181823' })
					vim.api.nvim_win_set_option(0, 'winhighlight', 'Normal:Terminal')
				end,
			})
		end,
	},
}
