return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		cmd = "Telescope",
		keys = {
			{
				"<D-p>",
				"<cmd>Telescope git_files<cr>",
				desc = "Toggle Telescope git_files",
				mode = { "n", "i", "v", "t", "c" },
			},
			{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Fuzzy find git files" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Fuzzy find files in cwd" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Fuzzy find recent files" },
			{ "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find string in cwd" },
			{ "<leader>fc", "<cmd>Telescope grep_string<cr>", desc = "Find string under cursor in cwd" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find keymaps" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
				cond = vim.fn.executable("cmake") == 1,
			},
		},
		config = function()
			local actions = require("telescope.actions")

			require("telescope").setup({
				defaults = {
					sorting_strategy = "ascending", -- display results top->bottom
					layout_config = {
						prompt_position = "top", -- search bar at the top
						height = 0.5, -- 50% of screen height
						width = 0.6, -- 60% of screen width
					},
					preview = {
						hide_on_startup = true, -- disable preview pane by default
					},
					-- Custom function to ensure files open in non-terminal windows
					get_selection_window = function()
						local wins = vim.api.nvim_list_wins()
						for _, win in ipairs(wins) do
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].buftype ~= "terminal" then
								return win
							end
						end
						-- If all windows are terminals, create a new split
						vim.cmd("vsplit")
						return vim.api.nvim_get_current_win()
					end,
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-x>"] = actions.delete_buffer,
							["<M-p>"] = require("telescope.actions.layout").toggle_preview,
						},
					},
					file_ignore_patterns = {
						"node_modules",
						"vendor",
						"yarn.lock",
						"package-lock.json",
						"composer.lock",
						".git",
						"storage/logs/*",
						"storage/framework/*",
						"bootstrap/cache/*",
						"public/build/*",
						"public/hot",
						"*.min.js",
						"*.min.css",
						".DS_Store",
					},
					hidden = true, -- show hidden files
					path_display = {
						"filename_first",
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
		end,
	},
}
