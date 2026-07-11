-- Whitespace view toggle (absorbs the old native-indent guide logic).
--
-- All whitespace display is owned here — options.lua sets nothing. Off by
-- default: nothing is shown until you press <leader>l (or :WhitespaceToggle),
-- which reveals every marker at once — tabs, trailing/inline/non-breaking
-- spaces, end-of-line, the off-screen precedes/extends arrows, and a live indent
-- guide that follows each buffer's shiftwidth. Toggle again to hide everything.

vim.opt.list = false -- start hidden

local on = false

-- "┆" + dots to fill one indent level of the current buffer.
local function indent_guide()
	local sw = vim.bo.shiftwidth
	if sw == 0 then
		sw = vim.bo.tabstop
	end
	return "┆" .. ("·"):rep(sw - 1)
end

-- The full marker set shown while the view is on.
local function chars()
	return {
		tab = "▸ ", -- tab characters
		trail = "·", -- trailing spaces
		nbsp = "␣", -- non-breaking spaces
		space = "·", -- every inline space
		eol = "↲", -- end of line
		precedes = "←", -- hidden text off-screen left (nowrap)
		extends = "→", -- hidden text off-screen right (nowrap)
		leadmultispace = indent_guide(), -- indent guide, per shiftwidth
	}
end

local function toggle()
	on = not on
	if on then
		vim.opt.listchars = chars()
		vim.opt.list = true
	else
		vim.opt.list = false -- list off hides every marker
	end
	vim.notify("Whitespace: " .. (on and "on" or "off"))
end

-- Keep the indent guide synced to the active buffer while the view is on.
local augroup = vim.api.nvim_create_augroup("whitespace_indent", { clear = true })

local function sync_indent()
	if not on then
		return
	end
	vim.opt.listchars:append({ leadmultispace = indent_guide() })
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, { group = augroup, callback = sync_indent })
vim.api.nvim_create_autocmd("OptionSet", { group = augroup, pattern = "shiftwidth", callback = sync_indent })

vim.api.nvim_create_user_command("WhitespaceToggle", toggle, { desc = "Toggle whitespace view" })
vim.keymap.set("n", "<leader>l", toggle, { desc = "Toggle whitespace view" })
