-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("t", "<Esc><Esc>", "<c-\\><c-n>") -- Easily hit escape in terminal mode.
vim.keymap.set({ "n", "v", "i" }, "<D-f>", "/", { desc = "Start search and replace" })

-- Comment Toggle (Normal and Visual Mode)
vim.keymap.set({ "n", "i", "v" }, "<D-/>", "gcc", { remap = true, desc = "Toggle comment with Cmd+/" })

-- Save and Select All
vim.keymap.set({ "n", "v", "i" }, "<D-s>", "<cmd>w!<CR>", { desc = "Save file (force write)" }) -- Cmd+s in any mode
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all in normal mode" }) -- Cmd+a to select all text in normal mode
vim.keymap.set("i", "<D-a>", "<Esc>ggVG", { desc = "Select all in insert mode" }) -- Cmd+a to select all text in insert mode
vim.keymap.set("v", "<D-a>", "<Esc>ggVG", { desc = "Select all in visual mode" }) -- Cmd+a to select all text in visual mode

-- Window Management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window (Normal mode)" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window (Normal mode)" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window (Normal mode)" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window (Normal mode)" })

vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Move focus to the left window (Terminal mode)" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Move focus to the lower window (Terminal mode)" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Move focus to the upper window (Terminal mode)" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Move focus to the right window (Terminal mode)" })

-- Tab Management
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
vim.keymap.set("n", "<S-Tab>", "<cmd>tabp<CR>", { desc = "Go to previous tab with Shift-Tab" })
vim.keymap.set("n", "<Tab>", "<cmd>tabn<CR>", { desc = "Go to next tab with Tab" })

-- Quick File Navigation (netrw file explorer on the right)
-- vim.keymap.set({"n", "v"}, "<leader>e", "<cmd>vertical rightbelow Lex 30<CR>", { desc = "Open file explorer (right side)" }) -- Leader+e
-- vim.keymap.set({"n", "v"}, "<D-b>", "<cmd>vertical rightbelow Lex 30<CR>", { desc = "Open file explorer (right side)" }) -- Cmd+b

-- Save and Quit (with leader)
vim.keymap.set({ "n", "v" }, "<leader>q", "<cmd>qall!<CR>", { desc = "Quit all windows" })
vim.keymap.set({ "n", "v" }, "<leader>z", "<cmd>wqall!<CR>", { desc = "Save all and quit" })
vim.keymap.set({ "n", "v" }, "<leader>w", function()
	-- Only save if buffer is modified
	if vim.bo.buftype == "" and vim.bo.modifiable and vim.bo.modified and vim.api.nvim_buf_get_name(0) ~= "" then
		vim.cmd("w!") -- Force save current buffer
	end

	-- Check if we're in a Diffview tab - simplified detection
	local bufname = vim.api.nvim_buf_get_name(0)
	local is_diffview = bufname:match("DiffviewFilePanel")
		or bufname:match("DiffviewFiles")
		or bufname:match("NeogitStatus")

	if is_diffview then
		-- Only close tab if we have multiple tabs
		if #vim.api.nvim_list_tabpages() > 1 then
			vim.cmd("tabclose")
		end
		return
	end

	-- Then follow hierarchy: split panes → tabs → just save
	local win_count = #vim.api.nvim_tabpage_list_wins(0)
	local tab_count = #vim.api.nvim_list_tabpages()

	if win_count > 1 then
		-- Multiple split panes: close current pane
		vim.cmd("close")
	elseif tab_count > 1 then
		-- Multiple tabs (no splits): close current tab
		vim.cmd("tabclose")
	else
		-- Last tab, no splits: already saved if needed
	end
end, { desc = "Save if modified, then close split/tab hierarchy" })

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

-- copy and paste
vim.keymap.set({ "n", "v", "i" }, "<D-c>", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set({ "n", "v", "i", "t" }, "<D-v>", '"+p', { desc = "Paste from clipboard" })

-- Spell checking keymaps
vim.keymap.set("n", "<leader>ss", function()
	vim.opt.spell = not vim.opt.spell:get()
	print("Spell checking " .. (vim.opt.spell:get() and "enabled" or "disabled"))
end, { desc = "Toggle spell checking" })
vim.keymap.set("n", "]s", "]szz", { desc = "Next misspelled word" })
vim.keymap.set("n", "[s", "[szz", { desc = "Previous misspelled word" })
vim.keymap.set("n", "zg", "zg", { desc = "Add word to dictionary" })
vim.keymap.set("n", "zw", "zw", { desc = "Mark word as wrong" })
vim.keymap.set("n", "zug", "zug", { desc = "Remove word from dictionary" })
vim.keymap.set("n", "zuw", "zuw", { desc = "Remove word from wrong list" })

-- Quickfix list keymaps
--
-- QUICKFIX WORKFLOW WITH FZF-LUA:
-- 1. Search with <leader>fs (live grep)
-- 2. Select multiple entries with Tab
-- 3. Send to quickfix with Alt-q (M-q)
--
-- SEARCH & REPLACE ACROSS QUICKFIX:
-- Interactive (with confirmation):
--   :cfdo %s/old/new/gc | update    - Replace in all files, save after
--   :cdo s/old/new/gc                - Replace only on quickfix lines
--
-- Non-interactive:
--   :cfdo %s/old/new/g | update      - Replace in all files
--
-- SAVE AFTER REPLACEMENTS:
--   :cfdo update                     - Save all modified files
--   :wall                            - Save all modified buffers
--
-- CONFIRMATION FLAGS (when using 'c'):
--   y - replace this match           n - skip this match
--   a - replace all remaining        q - quit substitution
--   l - replace this and quit        ^E/^Y - scroll up/down
--
vim.keymap.set("n", "<leader>cc", function()
	local qf_exists = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win["quickfix"] == 1 then
			qf_exists = true
		end
	end
	if qf_exists == true then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end, { desc = "Toggle quickfix list" })
vim.keymap.set("n", "<leader>cx", function()
	vim.fn.setqflist({})
	vim.cmd("cclose")
	print("Quickfix list cleared and closed")
end, { desc = "Clear and close quickfix list" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>zz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]Q", "<cmd>clast<cr>zz", { desc = "Last quickfix item" })
vim.keymap.set("n", "[Q", "<cmd>cfirst<cr>zz", { desc = "First quickfix item" })
