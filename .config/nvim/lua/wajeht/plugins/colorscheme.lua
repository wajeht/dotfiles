return {
 "rockyzhang24/arctic.nvim",
  branch = "v2",
  dependencies = { "rktjmp/lush.nvim" },
  priority = 1000,
  config = function()
    vim.cmd("colorscheme arctic")
    -- Custom statusline for terminal buffers
    vim.cmd("set laststatus=0")  -- Disable default statusline
    vim.cmd("set statusline=%{repeat('─',winwidth('.'))}")  -- Custom statusline (only a line of dashes)

    vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#333333")  -- GUI background transparent
    vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#333333")  -- Inactive StatusLine transparent for GUI
  end,
}
