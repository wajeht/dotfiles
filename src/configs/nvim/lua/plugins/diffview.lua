-- Diffview keymaps:
--   <leader>gd       - Toggle diffview (all changed files)
--   <leader>gh       - File history for current file
--
-- Inside diffview:
--   <tab> / <s-tab>  - Next/prev file
--   ]c / [c          - Next/prev hunk
--   q                - Close diffview

vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
})

-- Track Diffview tab for toggle behavior
local diffview_tab = nil

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "DiffviewFiles", "DiffviewFileHistory" },
	callback = function()
		diffview_tab = vim.api.nvim_get_current_tabpage()
	end,
})

vim.api.nvim_create_autocmd("TabClosed", {
	callback = function()
		if diffview_tab and not vim.api.nvim_tabpage_is_valid(diffview_tab) then
			diffview_tab = nil
		end
	end,
})

-- Toggle Diffview
vim.keymap.set("n", "<leader>gd", function()
	if diffview_tab and vim.api.nvim_tabpage_is_valid(diffview_tab) then
		if diffview_tab == vim.api.nvim_get_current_tabpage() then
			if #vim.api.nvim_list_tabpages() > 1 then
				vim.cmd("tabclose")
			else
				vim.cmd("DiffviewClose")
			end
		else
			vim.api.nvim_set_current_tabpage(diffview_tab)
		end
	else
		vim.cmd("DiffviewOpen")
	end
end, { desc = "Toggle Diffview" })

-- File history for current file
vim.keymap.set("n", "<leader>gh", function()
	vim.cmd("DiffviewFileHistory %")
end, { desc = "File history" })

require("diffview").setup({
	use_icons = false,
	show_help_hints = false,
	view = {
		default = { winbar_info = false },
		file_history = { winbar_info = false },
	},
	file_panel = {
		listing_style = "list",
		win_config = {
			position = "right",
			width = 40,
		},
	},
})
