-- Create an augroup for terminal settings
local term_augroup = vim.api.nvim_create_augroup("CustomTerminal", { clear = true })

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_augroup,
  callback = function()
    -- Disable line numbers and relative numbers
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false

    -- Remove padding around the cursor
    vim.opt_local.scrolloff = 0
    vim.opt_local.sidescrolloff = 0

    -- Set filetype to 'terminal'
    vim.bo.filetype = "terminal"

    -- Remove unnecessary UI elements
    vim.wo.winbar = ""        -- Remove winbar
    vim.wo.signcolumn = "no"  -- Remove sign column
    vim.wo.foldcolumn = "0"   -- Remove fold column
    vim.wo.colorcolumn = ""   -- Remove color column
    vim.wo.cursorline = false -- Disable cursor line

    -- Set terminal background color to #181818
    vim.api.nvim_set_hl(0, 'TerminalNormal', { bg = '#16161d' })
    vim.api.nvim_win_set_option(0, 'winhighlight', 'Normal:TerminalNormal')

    -- Move cursor to the bottom and start in insert mode
    vim.cmd("normal! G")
    vim.cmd("startinsert")
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
    vim.cmd("split | buffer " .. terminal_buf)
  else
    -- Create a new terminal if no valid buffer exists
    vim.cmd("split | term")
    terminal_buf = vim.api.nvim_get_current_buf() -- Store the buffer number
  end

  -- Adjust window settings
  vim.cmd("wincmd J")                -- Move the terminal window to the bottom
  vim.api.nvim_win_set_height(0, 15) -- Set a fixed height for the terminal
  vim.wo.winfixheight = true         -- Fix the height of the terminal window
  vim.cmd("startinsert")             -- Ensure the terminal is in insert mode
end)
