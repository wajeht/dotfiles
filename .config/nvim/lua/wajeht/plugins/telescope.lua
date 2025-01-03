return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "master",
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
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<C-x>"] = actions.delete_buffer,
                        },
                    },
                    file_ignore_patterns = {
                        "node_modules",
                        "vendor",
                        "yarn.lock",
                        ".git",
                        ".sl",
                        "_build",
                        ".next",
                    },
                    hidden = true,
                    path_display = {
                        "filename_first",
                    },
                },
            })

            -- Enable telescope fzf native, if installed
            pcall(require("telescope").load_extension, "fzf")

            -- set keymaps
            local keymap = vim.keymap -- for conciseness

            local function toggle_telescope_git_files()
                -- Check if a Telescope prompt window is open
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "TelescopePrompt" then
                        -- Close Telescope by simulating Esc
                        vim.api.nvim_input("<Esc><Esc>")
                        return
                    end
                end

                -- Open Telescope picker
                vim.cmd("Telescope git_files")
            end

            -- Map <cmd>+P for all modes
            keymap.set({ "n", "i", "v", "t", "c" }, "<D-p>", toggle_telescope_git_files, { desc = "Toggle Telescope git_files" })
            keymap.set("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Fuzzy find git files" })
            keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
            keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
            keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
            keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
        end,
    },
}
