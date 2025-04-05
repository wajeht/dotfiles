return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Optional, for file icons
	},
	config = function()
		require("nvim-tree").setup({
			auto_reload_on_write = true,
			update_focused_file = {
				enable = true, -- Automatically update the focused file
				update_cwd = true, -- Update the root directory of the tree to the parent directory of the file
			},
			view = {
				side = "right", -- Open on the right side
				width = 40, -- Set the width of the nvim-tree window
			},
			renderer = {
				indent_markers = {
					enable = true, -- Show indent markers
					inline_arrows = true,
					icons = {
						corner = "└",
						bottom = "─",
						none = " ",
						-- Use the same character as indent-blankline
						edge = "┊",
						item = "┊",
					},
				},
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
				},
			},
			-- disable window_picker for
			-- explorer to work well with
			-- window splits
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
				},
			},
			git = {
				ignore = false,
			},
			filters = {
				dotfiles = false, -- Show dotfiles
				git_ignored = false, -- Show gitignored files
			},
		})

		-- Keybindings to open nvim-tree on the right side
		vim.keymap.set(
			{ "n", "v" },
			"<leader>e",
			"<CMD>NvimTreeToggle<CR>",
			{ desc = "Toggle file explorer (right side)" }
		) -- Leader+e
		vim.keymap.set({ "n", "v" }, "<D-b>", "<CMD>NvimTreeToggle<CR>", { desc = "Toggle file explorer (right side)" }) -- Cmd+b
	end,
}
