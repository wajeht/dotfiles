vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
})

-- Keymaps
vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeToggle<CR>", { desc = "Toggle file explorer (right side)" })
vim.keymap.set("n", "<D-b>", "<CMD>NvimTreeToggle<CR>", { desc = "Toggle file explorer (right side)" })

require("nvim-tree").setup({
	auto_reload_on_write = true,
	-- Disable automatic opening of nvim-tree when starting with directory
	hijack_directories = {
		enable = false, -- Disable hijacking of netrw when opening directories
		auto_open = false, -- Don't auto open when starting with directory
	},
	update_focused_file = {
		enable = true, -- Automatically update the focused file
		update_cwd = false, -- Don't update the root directory when focusing files
	},
	view = {
		side = "right", -- Open on the right side
		width = 40, -- Set the width of the nvim-tree window
		adaptive_size = true, -- Adaptive size of the nvim-tree window
	},
	renderer = {
		root_folder_label = false, -- Hide the root folder path at the top
		add_trailing = true, -- Add trailing slash to folders
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
				file = false,
				folder = false,
				folder_arrow = true,
				git = false,
			},
		},
		highlight_git = true,
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
	-- Open files in Finder on macOS (reveal in Finder instead of opening in TextEdit)
	-- Usage: Press 's' on a file in nvim-tree to reveal it in Finder
	system_open = vim.fn.has("mac") == 1 and {
		cmd = "open",
		args = { "-R" },
	} or nil,
	-- Minimal on_attach to disable live filter
	on_attach = function(bufnr)
		local api = require("nvim-tree.api")

		-- Apply all default mappings
		api.config.mappings.default_on_attach(bufnr)

		-- Override 'f' key to do nothing (disable live filter)
		vim.keymap.set("n", "f", function() end, {
			buffer = bufnr,
			noremap = true,
			silent = true,
			desc = "Disabled live filter",
		})
	end,
})

-- Automatically open file upon creation
-- Usage: Press 'a' in nvim-tree to create a new file, it will automatically open after creation
local api = require("nvim-tree.api")
api.events.subscribe(api.events.Event.FileCreated, function(file)
	vim.cmd("edit " .. vim.fn.fnameescape(file.fname))
end)
