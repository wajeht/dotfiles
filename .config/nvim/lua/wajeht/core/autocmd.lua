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
