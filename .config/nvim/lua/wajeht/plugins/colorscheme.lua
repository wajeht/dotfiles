return {
	{
		"Mofiqul/vscode.nvim",
		name = "vscode",
		priority = 1000,
		lazy = false,
		config = function()
			vim.o.background = "dark"

			require("vscode").setup({
				transparent = true,

				italic_comments = false,

				underline_links = true,

				disable_nvimtree_bg = true,

				terminal_colors = true,
			})

			-- Load the theme
			vim.cmd("colorscheme vscode")

			-- Custom statusline for terminal buffers
			vim.cmd("set laststatus=0") -- Disable default statusline
			vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

			vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#444444") -- GUI background transparent
			vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#444444") -- Inactive StatusLine transparent for GUI

			-- Tab customization for transparent background
			vim.cmd("hi TabLine gui=NONE guibg=NONE guifg=#444444") -- Inactive tabs transparent
			vim.cmd("hi TabLineFill gui=NONE guibg=NONE") -- Empty tabline area transparent
			vim.cmd("hi TabLineSel gui=NONE guibg=NONE guifg=#ffffff") -- Active tab transparent with white text
		end,
	},
}
