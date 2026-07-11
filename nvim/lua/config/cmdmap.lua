-- tmux can't forward the cmd/super modifier (tmux/tmux#3335), so Ghostty
-- translates cmd+<key> to ESC <key> (meta) via `keybind = cmd+X=esc:X`.
-- Map both <D-key> (direct Ghostty, GUI nvim) and <M-key> (through tmux)
-- so cmd keys work everywhere. Add the Ghostty keybind when adding a key.
return function(modes, key, rhs, opts)
	vim.keymap.set(modes, "<D-" .. key .. ">", rhs, opts)
	vim.keymap.set(modes, "<M-" .. key .. ">", rhs, opts)
end
