-- Seamless Ctrl-h/j/k/l between nvim splits and tmux panes: at the edge of
-- nvim's splits the key hands off to the adjacent tmux pane (and back). Outside
-- tmux it just moves between nvim windows. The tmux side lives in tmux.conf.
vim.g.tmux_navigator_no_mappings = 1 -- define our own below (normal + terminal)

local ok = pcall(vim.pack.add, {
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
})

-- Resolve the target at keypress time, NOT here: vim.pack.add doesn't guarantee
-- :TmuxNavigate* is registered by the next line (with other plugins loading and
-- the module cache on, it usually isn't yet), so gating on vim.fn.exists() here
-- would wire the native fallback on every startup and never cross into tmux.
-- Deferring the check means the plugin's command is used once it exists, and we
-- still fall back to plain window nav if it genuinely failed to load.
local dirs = { h = "Left", j = "Down", k = "Up", l = "Right" }
for key, dir in pairs(dirs) do
	local lhs, low = "<C-" .. key .. ">", dir:lower()
	local navigate = function()
		if ok and vim.fn.exists(":TmuxNavigate" .. dir) == 2 then
			vim.cmd("TmuxNavigate" .. dir)
		else
			vim.cmd.wincmd(key) -- native fallback: move between nvim splits only
		end
	end
	vim.keymap.set("n", lhs, navigate, { desc = "Navigate " .. low .. " (nvim split / tmux pane)" })
	vim.keymap.set("t", lhs, function()
		vim.cmd("stopinsert") -- leave terminal-job mode, then navigate
		navigate()
	end, { desc = "Navigate " .. low .. " (nvim split / tmux pane)" })
end
