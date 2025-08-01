return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"nvim-telescope/telescope.nvim",
	},
	cmd = { "Neogit" },
	keys = {
		{ "<leader>gs", "<cmd>Neogit<cr>", desc = "Open Neogit" },
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
	},
	config = function()
		-- Neogit-specific styling
		vim.api.nvim_set_hl(0, "NeogitBranch", {
			fg = "#569cd6", -- VS Code blue for branch names
		})

		vim.api.nvim_set_hl(0, "NeogitRemote", {
			fg = "#9cdcfe", -- VS Code light blue for remotes
		})

		-- Darker diff colors for transparent background (these work for diffview)
		vim.api.nvim_set_hl(0, "DiffAdd", {
			bg = "#1a2e1a", -- Dark green background
			fg = "NONE",
		})

		vim.api.nvim_set_hl(0, "DiffDelete", {
			bg = "#2e1a1a", -- Dark red background
			fg = "#6b2c2c", -- Darker red text
		})

		vim.api.nvim_set_hl(0, "DiffChange", {
			bg = "#2e2a1a", -- Dark orange background
			fg = "NONE",
		})

		vim.api.nvim_set_hl(0, "DiffText", {
			bg = "#3e3a1a", -- Slightly lighter orange for actual changed text
			fg = "NONE",
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
				stashes = { folded = true },
				unpulled_upstream = { folded = true },
				unpulled_pushRemote = { folded = true },
				recent = { folded = true },
				rebase = { folded = true },
			},
		})
	end,
}
