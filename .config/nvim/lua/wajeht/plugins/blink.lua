return {
  'saghen/blink.cmp',
  enabled = true,
  lazy = true,
  dependencies = 'rafamadriz/friendly-snippets',
  version = '1.*',
  opts = {
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono',
      },
      completion = {
          menu = {
            border = 'single',
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
            window = { border = 'single' },
          },
          accept = {
            auto_brackets = {
              enabled = true,
            },
          },
          ghost_text = {
            enabled = true,
          },
      },
      signature = {
          enabled = true,
          window = {
            border = 'single',
          },
      },
      keymap = {
        preset = 'default',
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<D-i>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_and_accept", "fallback" },
      },
      sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      cmdline = {
          completion = {
              list = {
                  selection = {
                      preselect = false,
                      auto_insert = true,
                  },
              },
              menu = {
                  auto_show = true,
              },
              ghost_text = { enabled = true },
          },
      },
  },
  opts_extend = { 'sources.default' },
}
