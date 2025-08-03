return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				php = { "pint" },
				lua = { "stylua" },
			},
			-- format_on_save = {
			-- lsp_fallback = true,
			-- async = false, -- Must be false for save
			-- timeout_ms = 1000, -- Reasonable timeout
			-- },
		})

		vim.keymap.set({ "n", "v" }, "<leader>mf", function()
			conform.format({
				lsp_fallback = true,
				async = true,
				timeout_ms = 0,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
