return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPost", "BufNewFile" },
	main = "ibl",
	config = function()
		-- Set up highlight groups
		local hooks = require("ibl.hooks")
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#28292c" })
			vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#28292c" })
			vim.api.nvim_set_hl(0, "IblScope", { fg = "#5a5a5a" })
		end)

		require("ibl").setup({
			indent = {
				char = "┊",
				highlight = "IblIndent",
			},
			whitespace = {
				highlight = "IblWhitespace",
				remove_blankline_trail = false,
			},
			scope = {
				enabled = true,
				char = "┊",
				highlight = "IblScope",
				show_start = false,
				show_end = false,
				priority = 1,
			},
		})
	end,
}
