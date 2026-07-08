-- Seamless Ctrl-h/j/k/l between nvim splits and tmux panes: at the edge of
-- nvim's splits the key hands off to the adjacent tmux pane (and back). Outside
-- tmux it just moves between nvim windows. The tmux side lives in tmux.conf.
vim.g.tmux_navigator_no_mappings = 1 -- define our own below (normal + terminal)

local ok = pcall(vim.pack.add, {
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
})

-- If the plugin loaded, map to its boundary-crossing commands; if it didn't
-- (not fetched yet / offline / clone failed), fall back to native window nav so
-- Ctrl-h/j/k/l always at least move between nvim splits.
local nav = ok and vim.fn.exists(":TmuxNavigateLeft") == 2
local dirs = { h = "Left", j = "Down", k = "Up", l = "Right" }
for key, dir in pairs(dirs) do
	local lhs, low = "<C-" .. key .. ">", dir:lower()
	if nav then
		vim.keymap.set(
			"n",
			lhs,
			"<CMD>TmuxNavigate" .. dir .. "<CR>",
			{ desc = "Navigate " .. low .. " (nvim split / tmux pane)" }
		)
		vim.keymap.set(
			"t",
			lhs,
			"<C-\\><C-N><CMD>TmuxNavigate" .. dir .. "<CR>",
			{ desc = "Navigate " .. low .. " (nvim split / tmux pane)" }
		)
	else
		vim.keymap.set("n", lhs, "<C-w>" .. key, { desc = "Move focus " .. low .. " (native fallback)" })
		vim.keymap.set("t", lhs, "<C-\\><C-N><C-w>" .. key, { desc = "Move focus " .. low .. " (native fallback)" })
	end
end
