vim.pack.add({
	{ src = "https://github.com/windwp/nvim-autopairs" },
})

local autopairs = require("nvim-autopairs")

autopairs.setup({
	accept = { auto_brackets = { enabled = true } },
	check_ts = true, -- enable treesitter
})
