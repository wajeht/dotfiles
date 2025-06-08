return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration
		"nvim-telescope/telescope.nvim", -- optional - for telescope integration
	},
	cmd = { "Neogit" },
	keys = {
		{ "<leader>gg", "<cmd>Neogit kind=floating<cr>", desc = "Open Neogit (floating)" },
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
	},
	config = function()
		-- Custom highlight groups for neogit floating window
		vim.api.nvim_set_hl(0, "FloatBorder", {
			fg = "#444444", -- Border color (matches your VSCode theme statusline)
			bg = "NONE", -- Transparent background
		})

		vim.api.nvim_set_hl(0, "NormalFloat", {
			bg = "#1e1e1e", -- Dark background (VSCode theme)
		})

		-- Neogit-specific styling
		vim.api.nvim_set_hl(0, "NeogitBranch", {
			fg = "#569cd6", -- VS Code blue for branch names
		})

		vim.api.nvim_set_hl(0, "NeogitRemote", {
			fg = "#9cdcfe", -- VS Code light blue for remotes
		})

		-- Diff view colors - more subtle and transparent
		vim.api.nvim_set_hl(0, "NeogitDiffAdd", {
			bg = "#1a3d1a", -- Dark green, subtle
			fg = "#90ee90", -- Light green text
		})

		vim.api.nvim_set_hl(0, "NeogitDiffDelete", {
			bg = "#3d1a1a", -- Dark red, subtle
			fg = "#ff6b6b", -- Light red text
		})

		vim.api.nvim_set_hl(0, "NeogitDiffChange", {
			bg = "#2d2d1a", -- Dark yellow, subtle
			fg = "#ffd700", -- Light yellow text
		})

		-- Make diff context more transparent
		vim.api.nvim_set_hl(0, "NeogitDiffContext", {
			bg = "NONE", -- Transparent background
			fg = "#8a8a8a", -- Subtle gray text
		})

		require("neogit").setup({
			-- Core settings
			kind = "floating",
			graph_style = "ascii",

			-- Floating window configuration
			floating = {
				relative = "editor",
				width = 0.85,
				height = 0.85,
				style = "minimal",
				border = "rounded",
			},

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

			preview_buffer = {
				kind = "floating",
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
