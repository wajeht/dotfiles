vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- General Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Save and Select All
vim.keymap.set("n", "<D-s>", ":w!<CR>", { desc = "Save file (force write)" }) -- Cmd+s in normal mode
vim.keymap.set("i", "<D-s>", "<Esc>:w!<CR>a", { desc = "Save file (force write) in insert mode" }) -- Cmd+s in insert mode
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all in normal mode" }) -- Cmd+a to select all text in normal mode
vim.keymap.set("i", "<D-a>", "<Esc>ggVG", { desc = "Select all in insert mode" }) -- Cmd+a to select all text in insert mode
vim.keymap.set("v", "<D-a>", "<Esc>ggVG", { desc = "Select all in visual mode" }) -- Cmd+a to select all text in visual mode

-- Window Management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Tab Management
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Quick File Navigation (netrw file explorer on the right)
vim.keymap.set("n", "<leader>e", "<cmd>vertical rightbelow Lex 30<CR>", { desc = "Open file explorer (right side)" }) -- Leader+e
vim.keymap.set("n", "<D-b>", "<cmd>vertical rightbelow Lex 30<CR>", { desc = "Open file explorer (right side)" }) -- Cmd+b

-- Save and Quit (with leader)
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Vim" })
vim.keymap.set("n", "<leader>z", "<cmd>wq<CR>", { desc = "Save and Quit" })
vim.keymap.set("n", "<leader>w", "<cmd>wa!<CR>", { desc = "Save all files" })

-- Move lines in visual mode
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line down" })

-- Join lines without moving the cursor
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without losing cursor position" })

-- Paste without modifying the clipboard in visual mode
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without modifying the clipboard" })

-- Centering the buffer while navigating
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "{", "{zz", { desc = "Go to previous block and center" })
vim.keymap.set("n", "}", "}zz", { desc = "Go to next block and center" })
vim.keymap.set("n", "N", "Nzz", { desc = "Search next and center" })
vim.keymap.set("n", "n", "nzz", { desc = "Search previous and center" })
vim.keymap.set("n", "G", "Gzz", { desc = "Go to the end of the file and center" })
vim.keymap.set("n", "gg", "ggzz", { desc = "Go to the start of the file and center" })
vim.keymap.set("n", "gd", "gdzz", { desc = "Go to definition and center" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Go to the jump list forward and center" })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Go to the jump list backward and center" })
vim.keymap.set("n", "%", "%zz", { desc = "Jump to matching parenthesis and center" })
vim.keymap.set("n", "*", "*zz", { desc = "Search for word under cursor and center" })
vim.keymap.set("n", "#", "#zz", { desc = "Search backward for word under cursor and center" })
