vim.pack.add({
	{ src = "https://github.com/NeogitOrg/neogit" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
})

-- State tracking (O(1) lookup instead of iterating tabs/windows)
local neogit_tab = nil
local diffview_tab = nil

-- Track Neogit tab via autocmds
vim.api.nvim_create_autocmd("FileType", {
	pattern = "NeogitStatus",
	callback = function()
		neogit_tab = vim.api.nvim_get_current_tabpage()
	end,
})

vim.api.nvim_create_autocmd("TabClosed", {
	callback = function()
		if neogit_tab and not vim.api.nvim_tabpage_is_valid(neogit_tab) then
			neogit_tab = nil
		end
		if diffview_tab and not vim.api.nvim_tabpage_is_valid(diffview_tab) then
			diffview_tab = nil
		end
	end,
})

-- Track Diffview tab via autocmds
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "DiffviewFiles", "DiffviewFileHistory" },
	callback = function()
		diffview_tab = vim.api.nvim_get_current_tabpage()
	end,
})

-- Keymaps
vim.keymap.set("n", "<leader>gs", function()
	if neogit_tab and vim.api.nvim_tabpage_is_valid(neogit_tab) then
		if neogit_tab == vim.api.nvim_get_current_tabpage() then
			-- On Neogit tab -> close it
			if #vim.api.nvim_list_tabpages() > 1 then
				vim.cmd("tabclose")
			else
				vim.cmd("Neogit close")
			end
		else
			-- Neogit open elsewhere -> switch to it
			vim.api.nvim_set_current_tabpage(neogit_tab)
		end
	else
		-- Not open -> open it
		vim.cmd("Neogit")
	end
end, { desc = "Toggle Neogit" })

vim.keymap.set("n", "<leader>gd", function()
	if diffview_tab and vim.api.nvim_tabpage_is_valid(diffview_tab) then
		if diffview_tab == vim.api.nvim_get_current_tabpage() then
			-- On Diffview tab -> close it
			if #vim.api.nvim_list_tabpages() > 1 then
				vim.cmd("tabclose")
			else
				vim.cmd("DiffviewClose")
			end
		else
			-- Diffview open elsewhere -> switch to it
			vim.api.nvim_set_current_tabpage(diffview_tab)
		end
	else
		-- Not open -> open it
		vim.cmd("DiffviewOpen")
	end
end, { desc = "Toggle Diffview" })

-- Neogit-specific styling
vim.api.nvim_set_hl(0, "NeogitBranch", {
	fg = "#569cd6", -- VS Code blue for branch names
})

vim.api.nvim_set_hl(0, "NeogitRemote", {
	fg = "#9cdcfe", -- VS Code light blue for remotes
})

-- Brighter diff colors for better visibility with transparent background
vim.api.nvim_set_hl(0, "DiffAdd", {
	bg = "#2d4a2d", -- Brighter green background
	fg = "#a8e4a0", -- Light green text
})

vim.api.nvim_set_hl(0, "DiffDelete", {
	bg = "#4a2d2d", -- Brighter red background
	fg = "#ff7b72", -- Bright red text
})

vim.api.nvim_set_hl(0, "DiffChange", {
	bg = "#4a402d", -- Brighter orange background
	fg = "#ffa657", -- Orange text
})

vim.api.nvim_set_hl(0, "DiffText", {
	bg = "#5a4a2d", -- Even brighter orange for actual changed text
	fg = "#ffb86c", -- Bright orange text
})

-- Essential Neogit highlight groups to fix gray backgrounds
vim.api.nvim_set_hl(0, "NeogitHunkHeader", {
	bg = "NONE", -- Remove gray background
	fg = "#c586c0", -- Purple text
})

vim.api.nvim_set_hl(0, "NeogitHunkHeaderHighlight", {
	bg = "NONE", -- Remove gray background
	fg = "#c586c0",
})

vim.api.nvim_set_hl(0, "NeogitDiffContext", {
	bg = "NONE", -- Remove gray background
	fg = "#808080", -- Muted gray text
})

vim.api.nvim_set_hl(0, "NeogitDiffContextHighlight", {
	bg = "NONE", -- Remove gray background
	fg = "#808080",
})

-- Make Neogit diff colors match Diffview colors (preserve syntax highlighting)
vim.api.nvim_set_hl(0, "NeogitDiffAdd", {
	link = "DiffAdd",
})

vim.api.nvim_set_hl(0, "NeogitDiffDelete", {
	link = "DiffDelete",
})

vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", {
	link = "DiffAdd",
})

vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", {
	link = "DiffDelete",
})

require("neogit").setup({
	-- Core settings
	kind = "tab",
	graph_style = "ascii",

	-- Performance optimizations
	disable_line_numbers = true,
	remember_settings = true,
	use_per_project_settings = true,
	fetch_after_checkout = false, -- Don't auto-fetch (slow on large repos)
	process_spinner = false, -- Disable spinner for faster perceived performance

	-- UI preferences
	disable_hint = true, -- Disable hints for cleaner UI
	notification_icon = "󰊢",

	-- Console settings
	console_timeout = 2000,
	auto_show_console = false,
	auto_close_console = true,

	-- Integrations
	integrations = {
		telescope = false, -- Disable telescope integration (use fzf-lua)
		diffview = true,
		fzf_lua = true, -- Enable fzf-lua instead
	},

	-- Commit editor
	commit_editor = {
		show_staged_diff = false, -- Disable for faster commit opening
		spell_check = true,
	},

	-- Section folding - hide more sections for faster loading
	sections = {
		head = { folded = true, hidden = true },
		push = { folded = true, hidden = true },
		untracked = { folded = false },
		unstaged = { folded = false },
		staged = { folded = false },
		stashes = { folded = true, hidden = true },
		unpulled_upstream = { folded = true, hidden = true },
		unmerged_upstream = { folded = true, hidden = true },
		unpulled_pushRemote = { folded = true, hidden = true },
		unmerged_pushRemote = { folded = true, hidden = true },
		recent = { folded = true, hidden = true },
		rebase = { folded = true, hidden = true },
	},
})
