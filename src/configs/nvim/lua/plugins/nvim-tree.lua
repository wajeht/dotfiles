vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
})

-- Keymaps
vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeToggle<CR>", { desc = "Toggle file explorer (right side)" })
require("config.cmdmap")("n", "b", "<CMD>NvimTreeToggle<CR>", { desc = "Toggle file explorer (right side)" })

require("nvim-tree").setup({
	-- Disable automatic opening of nvim-tree when starting with directory
	hijack_directories = {
		enable = false, -- Disable hijacking of netrw when opening directories
		auto_open = false, -- Don't auto open when starting with directory
	},
	update_focused_file = {
		enable = true, -- Automatically update the focused file
	},
	view = {
		side = "right", -- Open on the right side
		width = {
			min = 40, -- Adaptive width with a 40-column minimum
		},
	},
	renderer = {
		root_folder_label = false, -- Hide the root folder path at the top
		add_trailing = true, -- Add trailing slash to folders
		indent_markers = {
			enable = true, -- Show indent markers
			icons = {
				-- Use the same character as indent-blankline
				edge = "┊",
				item = "┊",
			},
		},
		icons = {
			show = {
				file = false,
				folder = false,
				git = false,
			},
		},
		highlight_git = "name",
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
	filters = {
		git_ignored = false, -- Show gitignored files
	},
	-- Minimal on_attach to disable live filter
	on_attach = function(bufnr)
		local api = require("nvim-tree.api")

		-- Apply all default mappings
		api.map.on_attach.default(bufnr)

		-- Override 'f' key to do nothing (disable live filter)
		vim.keymap.set("n", "f", function() end, {
			buffer = bufnr,
			noremap = true,
			silent = true,
			desc = "Disabled live filter",
		})

		if vim.fn.has("mac") == 1 then
			vim.keymap.set("n", "s", function()
				local node = api.tree.get_node_under_cursor()
				if node then
					vim.system({ "open", "-R", node.link_to or node.absolute_path })
				end
			end, {
				buffer = bufnr,
				noremap = true,
				silent = true,
				desc = "Reveal in Finder",
			})
		end
	end,
})

-- Automatically open file upon creation
-- Usage: Press 'a' in nvim-tree to create a new file, it will automatically open after creation
local api = require("nvim-tree.api")
api.events.subscribe(api.events.Event.FileCreated, function(file)
	vim.cmd("edit " .. vim.fn.fnameescape(file.fname))
end)
