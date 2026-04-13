vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})

local conform = require("conform")
local has = function(cmd)
	return vim.fn.executable(cmd) == 1
end

local formatters_by_ft = {
	lua = { "stylua" },
}

if has("prettier") then
	formatters_by_ft.javascript = { "prettier" }
	formatters_by_ft.typescript = { "prettier" }
	formatters_by_ft.javascriptreact = { "prettier" }
	formatters_by_ft.typescriptreact = { "prettier" }
	formatters_by_ft.vue = { "prettier" }
	formatters_by_ft.css = { "prettier" }
	formatters_by_ft.html = { "prettier" }
	formatters_by_ft.json = { "prettier" }
	formatters_by_ft.yaml = { "prettier" }
	formatters_by_ft.markdown = { "prettier" }
end

if has("pint") then
	formatters_by_ft.php = { "pint" }
end

conform.setup({
	formatters_by_ft = formatters_by_ft,
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
		timeout_ms = 5000,
	})
end, { desc = "Format file or range (in visual mode)" })
