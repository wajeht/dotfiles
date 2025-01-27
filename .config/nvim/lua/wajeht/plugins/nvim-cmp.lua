return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
      "hrsh7th/cmp-buffer", -- source for text in buffer
      "hrsh7th/cmp-path", -- source for file system paths
      "onsails/lspkind.nvim", -- vs-code like pictograms
  },
  config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
          completion = {
              completeopt = "menu,menuone,preview,noselect",
          },
          mapping = cmp.mapping.preset.insert({
              ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
              ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
              ["<D-i>"] = cmp.mapping.complete(), -- trigger completion menu with Command + i
              ["<C-e>"] = cmp.mapping.abort(), -- close completion window
              ["<CR>"] = cmp.mapping.confirm({ select = false }),
              ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- confirm with Tab
          }),
          window = {
            completion = {
                border = "rounded",
                winhighlight = "Normal:NormalFloat,FloatBorder:CmpBorder",
            },
            documentation = {
                border = "rounded",
                winhighlight = "Normal:NormalFloat,FloatBorder:CmpBorder",
            },
          },
          -- sources for autocompletion
          sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "buffer" }, -- text within current buffer
              { name = "path" }, -- file system paths
          }),
          -- configure lspkind for vs-code like pictograms in completion menu
          formatting = {
              format = lspkind.cmp_format({
                  maxwidth = 50,
                  ellipsis_char = "...",
              }),
          },
      })
      -- Define a custom highlight group for the border
      vim.cmd([[ highlight CmpBorder guifg=#333333 guibg=NONE ]])
  end,
}