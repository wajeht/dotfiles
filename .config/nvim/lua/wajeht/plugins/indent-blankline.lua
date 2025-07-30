return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPost", "BufNewFile" },
	main = "ibl",
	config = function()
		require("ibl").setup({
			indent = { char = "┊" },
			whitespace = {
				remove_blankline_trail = false,
			},
			scope = {
				enabled = true,
				char = "┊", -- Same as regular indentation
				show_start = false,
				show_end = false,
				priority = 1, -- Same priority as regular indentation
			},
		})
	end,
}
