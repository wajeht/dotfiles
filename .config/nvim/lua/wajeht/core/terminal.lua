-- Create an augroup for terminal settings
local term_augroup = vim.api.nvim_create_augroup("CustomTerminal", { clear = true })

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_augroup,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local win = vim.api.nvim_get_current_win()

		-- Batch all buffer-local options
		vim.api.nvim_buf_set_option(buf, "filetype", "terminal")

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
			vim.api.nvim_win_set_option(win, opt, value)
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

-- Toggle terminal with Cmd+J (open or close)
vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-j>", function()
	-- Check if the terminal buffer is valid and visible
	if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
		-- Find the window displaying the terminal buffer
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == terminal_buf then
				-- Hide the terminal window if it's open
				vim.api.nvim_win_hide(win)
				return
			end
		end
		-- Open the terminal buffer in a new split if it's not visible
		vim.cmd("split")
		vim.api.nvim_win_set_buf(0, terminal_buf)
	else
		-- Create a new terminal if no valid buffer exists
		vim.cmd("split")
		vim.cmd("terminal")
		terminal_buf = vim.api.nvim_get_current_buf() -- Store the buffer number
	end

	-- Batch window adjustments for better performance
	local win = vim.api.nvim_get_current_win()
	vim.cmd("wincmd J") -- Move the terminal window to the bottom
	vim.api.nvim_win_set_height(win, 15) -- Set a fixed height for the terminal
	vim.api.nvim_win_set_option(win, "winfixheight", true) -- Fix the height of the terminal window

	-- Schedule insert mode to avoid blocking
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.cmd("startinsert")
		end
	end)
end)
