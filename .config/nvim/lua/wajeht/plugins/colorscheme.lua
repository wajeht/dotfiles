return {
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		priority = 1000,
		lazy = false,
		config = function()
			vim.cmd("colorscheme tokyonight-night")

			-- Custom statusline for terminal buffers
			vim.cmd("set laststatus=0") -- Disable default statusline
			vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

			vim.cmd("hi StatusLine gui=NONE guibg=#16161d guifg=#16161d") -- GUI background transparent
			vim.cmd("hi StatusLineNC gui=NONE guibg=#16161d guifg=#16161d") -- Inactive StatusLine transparent for GUI
		end,
	},
}
