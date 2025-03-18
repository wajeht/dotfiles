return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local fmt = require("luasnip.extras.fmt").fmt

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Add custom snippets
    ls.add_snippets("javascript", {
      s("clg", fmt("console.log({});", {
        i(1, "")
      })),
    })

    ls.add_snippets("typescript", {
      s("clg", fmt("console.log({});", {
        i(1, "")
      })),
    })

    ls.add_snippets("javascriptreact", {
      s("clg", fmt("console.log({});", {
        i(1, "")
      })),
    })

    ls.add_snippets("typescriptreact", {
      s("clg", fmt("console.log({});", {
        i(1, "")
      })),
    })
  end,
}
