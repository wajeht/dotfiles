-- Auto-save on focus lost
vim.api.nvim_create_autocmd({"FocusLost"}, {
  pattern = "*",
  command = "silent! wa",
  desc = "Automatically save all buffers when losing focus"
})

-- Auto-reload files changed outside of Vim
vim.opt.autoread = true
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  command = "if mode() != 'c' | checktime | endif",
  desc = "Automatically check and reload files changed outside of Vim"
})

-- Auto-remove trailing whitespace on save
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = "*",
  callback = function()
      local save_cursor = vim.fn.getpos(".")
      vim.cmd([[%s/\s\+$//e]])
      vim.fn.setpos(".", save_cursor)
  end,
  desc = "Remove trailing whitespace on save"
})

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd({"TextYankPost"}, {
  pattern = "*",
  callback = function()
      vim.highlight.on_yank({higroup="IncSearch", timeout=150})
  end,
  desc = "Briefly highlight yanked text"
})

-- Automatically create parent directories when saving a file
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  callback = function(event)
      if event.match:match("^%w%w+://") then
          return
      end
      local file = vim.uv.fs_realpath(event.match) or event.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Automatically create parent directories when saving a file"
})

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

-- Toggle terminal with Cmd+J (open or close)
vim.keymap.set({"n", "i", "v", "c", "t"}, "<D-j>", function()
  local term_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(buf):match('^term://') then
      term_buf = buf
      break
    end
  end

  -- If a terminal is open, close it
  if term_buf then
    vim.cmd("bdelete! " .. term_buf)  -- Close the terminal buffer
  else
    -- If no terminal is open, create a new one
    vim.cmd("split")  -- Open a new split window
    vim.cmd("wincmd J")  -- Move the new window to the bottom
    vim.api.nvim_win_set_height(0, 15)  -- Set a fixed height for the terminal
    vim.wo.winfixheight = true  -- Fix the height of the terminal window
    vim.cmd("term")  -- Start the terminal
    vim.cmd("startinsert")  -- Ensure the terminal is in insert mode after opening
  end
end)
