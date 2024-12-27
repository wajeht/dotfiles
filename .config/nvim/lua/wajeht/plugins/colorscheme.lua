return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha"  -- Set Mocha as the flavor
    })
    vim.cmd.colorscheme "catppuccin"
  end
}
