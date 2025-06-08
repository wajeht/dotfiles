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
	opts = {
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
		auto_show_console = true,
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
	},
}
