return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"nvim-telescope/telescope.nvim",
	},
	cmd = { "Neogit" },
	keys = {
		{
			"<leader>gs",
			function()
				-- Check if Neogit is open by looking for Neogit buffers
				local neogit_open = false
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local name = vim.api.nvim_buf_get_name(buf)
					if name:match("NeogitStatus") then
						neogit_open = true
						break
					end
				end

				if neogit_open then
					-- Close the tab if Neogit is open
					vim.cmd("tabclose")
				else
					-- Open Neogit
					vim.cmd("Neogit")
				end
			end,
			desc = "Toggle Neogit",
		},
		{
			"<leader>gd",
			function()
				-- Check if Diffview is open
				local diffview_open = false
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local name = vim.api.nvim_buf_get_name(buf)
					if name:match("DiffviewFilePanel") or name:match("Diffview://") then
						diffview_open = true
						break
					end
				end

				if diffview_open then
					vim.cmd("DiffviewClose")
				else
					vim.cmd("DiffviewOpen")
				end
			end,
			desc = "Toggle Diffview",
		},
	},
	config = function()
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

			-- UI preferences
			disable_hint = false,
			-- disable_status_hints = false,
			notification_icon = "󰊢",

			-- Console settings
			console_timeout = 2000,
			auto_show_console = false, -- Don't auto-show console for faster operations
			auto_close_console = true,

			-- Integrations
			integrations = {
				telescope = true,
				diffview = true,
			},

			-- View configurations (only non-defaults)
			commit_editor = {
				show_staged_diff = true,
				spell_check = true,
			},

			-- Section folding preferences
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
	end,
}
