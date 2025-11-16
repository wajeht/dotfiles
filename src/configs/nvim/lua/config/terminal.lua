-- Create an augroup for terminal settings
local term_augroup = vim.api.nvim_create_augroup("CustomTerminal", { clear = true })

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_augroup,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local win = vim.api.nvim_get_current_win()

		-- Batch all buffer-local options
		vim.api.nvim_set_option_value("filetype", "terminal", { buf = buf })

		-- Batch all window-local options
		local win_opts = {
			number = false,
			relativenumber = false,
			scrolloff = 0,
			sidescrolloff = 0,
			winbar = "",
			signcolumn = "no",
			foldcolumn = "0",
			foldtext = "",
			colorcolumn = "",
			cursorline = false,
		}

		for opt, value in pairs(win_opts) do
			vim.api.nvim_set_option_value(opt, value, { win = win })
		end

		-- Defer insert mode to avoid blocking
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(buf) then
				vim.cmd("startinsert")
			end
		end)
	end,
})

-- Store the terminal buffer number
local terminal_buf = nil

-- Store terminal window for faster toggling
local terminal_win = nil

-- Toggle terminal with Cmd+J (open or close)
vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-j>", function()
	-- Fast close if terminal window exists
	if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
		vim.api.nvim_win_hide(terminal_win)
		terminal_win = nil
		return
	end

	-- Check if terminal buffer exists
	if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
		-- Reuse existing buffer
		vim.cmd("botright 15split")
		vim.api.nvim_win_set_buf(0, terminal_buf)
	else
		-- Create new terminal with optimized settings
		vim.cmd("botright 15split term://$SHELL")
		terminal_buf = vim.api.nvim_get_current_buf()
	end

	terminal_win = vim.api.nvim_get_current_win()
	vim.api.nvim_set_option_value("winfixheight", true, { win = terminal_win })

	-- Immediate insert mode
	vim.cmd("startinsert")
end)
