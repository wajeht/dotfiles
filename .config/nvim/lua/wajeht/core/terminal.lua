-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", {}),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
    vim.bo.filetype = "terminal"
    vim.cmd("normal! G") -- Move the cursor to the bottom of the terminal
    vim.cmd("startinsert") -- Ensure terminal starts in insert mode
  end,
})

-- Store the terminal buffer number
local terminal_buf = nil

-- Toggle terminal with Cmd+J (open or close)
vim.keymap.set({"n", "i", "v", "c", "t"}, "<D-j>", function()
  -- Check if the terminal buffer is valid
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
    vim.cmd("split | b" .. terminal_buf)
  else
    -- Create a new terminal if no valid buffer exists
    vim.cmd("split | term")
    terminal_buf = vim.api.nvim_get_current_buf() -- Store the buffer number
  end

  -- Adjust window settings
  vim.cmd("wincmd J")  -- Move the new window to the bottom
  vim.api.nvim_win_set_height(0, 15)  -- Set a fixed height for the terminal
  vim.wo.winfixheight = true  -- Fix the height of the terminal window
  vim.cmd("startinsert")  -- Ensure the terminal is in insert mode after opening
end)
