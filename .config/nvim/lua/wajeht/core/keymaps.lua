vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

local keymap = vim.keymap -- for conciseness

-- General
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Save and Select All
keymap.set("n", "<D-s>", ":wa!<CR>", { desc = "Save all files (force write)" })
keymap.set("i", "<D-s>", "<Esc>:wa!<CR>a", { desc = "Save all files in insert mode" })
keymap.set("n", "<D-a>", "ggVG", { desc = "Select all text in the buffer" })

-- Window Management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize split sizes" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Window Navigation
keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Focus window to the left" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Focus window to the right" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Focus window below" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Focus window above" })

-- Tab Management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open a new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close the current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Switch to the next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Switch to the previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in a new tab" })

-- File Navigation
keymap.set("n", "<leader>e", "<cmd>vertical rightbelow Lex 30<CR>", { desc = "Open file explorer on the right" })
keymap.set("n", "<D-b>", "<cmd>vertical rightbelow Lex 30<CR>", { desc = "Open file explorer [Cmd+B]" })

-- Buffers
keymap.set("n", "<leader>'", "<C-^>", { desc = "Switch to the last used buffer" })

-- Save
keymap.set("n", "<leader>w", "<cmd>wa!<CR>", { desc = "Save all open files" })

-- Quit
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit the current window" })

-- Save and Quit
keymap.set("n", "<leader>z", "<cmd>wa! | q<CR>", { desc = "Save all files and quit the current window" })
