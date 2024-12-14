vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

local keymap = vim.keymap -- for conciseness

-- General
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
keymap.set("n", "<D-s>", ":w!<CR>", { desc = "Save file (force write)" }) -- Cmd+s in normal mode
keymap.set("i", "<D-s>", "<Esc>:w!<CR>a", { desc = "Save file (force write) in insert mode" }) -- Cmd+s in insert mode
keymap.set("n", "<D-a>", "ggVG", { desc = "Select all" }) -- Cmd+a to select all text in normal mode

-- Save and Select All
keymap.set("n", "<D-s>", ":w!<CR>", { desc = "Save file (force write)" }) -- Cmd+s in normal mode
keymap.set("i", "<D-s>", "<Esc>:w!<CR>a", { desc = "Save file (force write) in insert mode" }) -- Cmd+s in insert mode
keymap.set("n", "<D-a>", "ggVG", { desc = "Select all" }) -- Cmd+a to select all text in normal mode

-- Window Management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Window Navigation
keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Tab Management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
