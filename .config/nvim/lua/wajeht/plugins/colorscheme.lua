return {
	{
		"Mofiqul/vscode.nvim",
		name = "vscode",
		priority = 1000,
		lazy = false,
		config = function()
			-- Set dark theme
			vim.o.background = "dark"

			require("vscode").setup({
				-- Enable transparent background
				transparent = true,

				-- Enable italic comment
				italic_comments = false,

				-- Underline `@markup.link.*` variants
				underline_links = true,

				-- Disable nvim-tree background color
				disable_nvimtree_bg = true,

				-- Apply theme colors to terminal
				terminal_colors = true,
			})

			-- Load the theme
			vim.cmd("colorscheme vscode")

			-- Custom statusline for terminal buffers
			vim.cmd("set laststatus=0") -- Disable default statusline
			vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

			vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#444444") -- GUI background transparent
			vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#444444") -- Inactive StatusLine transparent for GUI
		end,
	},
}
