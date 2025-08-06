vim.pack.add({
	{ src = "https://github.com/windwp/nvim-autopairs" },
})

local autopairs = require("nvim-autopairs")

autopairs.setup({
	accept = { auto_brackets = { enabled = true } },
	check_ts = true, -- enable treesitter
	ts_config = {
		lua = { "string" }, -- don't add pairs in lua string treesitter nodes
		javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
	},
})
