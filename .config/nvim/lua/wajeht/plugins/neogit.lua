return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration
		"nvim-telescope/telescope.nvim", -- optional - for telescope integration
	},
	cmd = { "Neogit" },
	keys = {
		{ "<leader>gs", "<cmd>Neogit<cr>", desc = "Open Neogit" },
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

		require("neogit").setup({
			-- Core settings
			kind = "tab",
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
