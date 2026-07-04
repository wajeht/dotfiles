-- Diffview keymaps:
--   <leader>gd       - Toggle diffview (all changed files)
--   <leader>gh       - File history for current file
--
-- Inside diffview:
--   <tab> / <s-tab>  - Next/prev file
--   ]c / [c          - Next/prev hunk
--   q                - Close diffview

vim.pack.add({
	{ src = "https://github.com/dlyongemallo/diffview-plus.nvim" },
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

-- Tab to return to when toggling Diffview off
local return_tab = nil

-- Toggle Diffview
vim.keymap.set("n", "<leader>gd", function()
	local cur = vim.api.nvim_get_current_tabpage()
	if diffview_tab and vim.api.nvim_tabpage_is_valid(diffview_tab) then
		if diffview_tab == cur then
			-- Switch away instead of closing: a closed view is destroyed and
			-- re-fetches everything on reopen, a hidden one reopens instantly.
			if return_tab and vim.api.nvim_tabpage_is_valid(return_tab) and return_tab ~= cur then
				vim.api.nvim_set_current_tabpage(return_tab)
			elseif #vim.api.nvim_list_tabpages() > 1 then
				vim.cmd("tabprevious")
			else
				vim.cmd("DiffviewClose")
			end
		else
			return_tab = cur
			vim.api.nvim_set_current_tabpage(diffview_tab)
		end
	else
		return_tab = cur
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
	git_cmd = { "git", "--no-optional-locks" },
	watch_index = true,
	large_file_threshold = 5000,
	view = {
		default = { disable_diagnostics = true },
		file_history = { disable_diagnostics = true },
	},
	file_panel = {
		listing_style = "list",
		win_config = {
			position = "right",
			width = 40,
		},
	},
	hooks = {
		diff_buf_read = function(bufnr)
			vim.opt_local.foldmethod = "diff"
			vim.opt_local.foldexpr = ""
		end,
	},
})
