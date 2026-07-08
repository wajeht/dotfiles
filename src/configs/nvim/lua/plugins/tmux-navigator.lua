-- Seamless Ctrl-h/j/k/l between nvim splits and tmux panes: at the edge of
-- nvim's splits the key hands off to the adjacent tmux pane (and back). Outside
-- tmux it just moves between nvim windows. The tmux side lives in tmux.conf.
vim.g.tmux_navigator_no_mappings = 1 -- define our own below (normal + terminal)

vim.pack.add({
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
})

local map = vim.keymap.set
map("n", "<C-h>", "<CMD>TmuxNavigateLeft<CR>", { desc = "Navigate left (nvim split / tmux pane)" })
map("n", "<C-j>", "<CMD>TmuxNavigateDown<CR>", { desc = "Navigate down (nvim split / tmux pane)" })
map("n", "<C-k>", "<CMD>TmuxNavigateUp<CR>", { desc = "Navigate up (nvim split / tmux pane)" })
map("n", "<C-l>", "<CMD>TmuxNavigateRight<CR>", { desc = "Navigate right (nvim split / tmux pane)" })

-- terminal mode: drop to normal first, then navigate
map("t", "<C-h>", "<C-\\><C-N><CMD>TmuxNavigateLeft<CR>", { desc = "Navigate left (nvim split / tmux pane)" })
map("t", "<C-j>", "<C-\\><C-N><CMD>TmuxNavigateDown<CR>", { desc = "Navigate down (nvim split / tmux pane)" })
map("t", "<C-k>", "<C-\\><C-N><CMD>TmuxNavigateUp<CR>", { desc = "Navigate up (nvim split / tmux pane)" })
map("t", "<C-l>", "<C-\\><C-N><CMD>TmuxNavigateRight<CR>", { desc = "Navigate right (nvim split / tmux pane)" })
