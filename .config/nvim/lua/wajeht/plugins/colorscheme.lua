return {
    {
        "rockyzhang24/arctic.nvim",
        name = "arctic",
        branch = "v2",
        dependencies = { "rktjmp/lush.nvim" },
        priority = 1000,
        lazy = false,
        config = function()
            vim.cmd("colorscheme arctic")

            -- Custom statusline for terminal buffers
            vim.cmd("set laststatus=0") -- Disable default statusline
            vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

            vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#333333") -- GUI background transparent
            vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#333333") -- Inactive StatusLine transparent for GUI
        end,
    },
}

-- return {
--     {
--         "bluz71/vim-nightfly-colors",
--         name = "nightfly",
--         priority = 1000,
--         lazy = false,
--         config = function()
--             -- Nightfly options
--             vim.g.nightflyCursorColor = true                -- Enable cursor color
--             vim.g.nightflyItalics = true                    -- Enable italics for comments and HTML elements
--             vim.g.nightflyNormalFloat = true               -- Use nightfly background in floating windows
--             vim.g.nightflyTerminalColors = true            -- Enable terminal colors
--             vim.g.nightflyTransparent = false              -- Don't use transparent background
--             vim.g.nightflyUndercurls = true                -- Use undercurls for spelling and errors
--             vim.g.nightflyUnderlineMatchParen = false      -- Don't underline matching parentheses
--             vim.g.nightflyVirtualTextColor = true          -- Use colors for virtual text
--             vim.g.nightflyWinSeparator = 2                 -- Use line separators for windows
--
--             -- Set thicker characters for the separators to improve appearance with line separators
--             vim.opt.fillchars = {
--                 horiz = '━',
--                 horizup = '┻',
--                 horizdown = '┳',
--                 vert = '┃',
--                 vertleft = '┫',
--                 vertright = '┣',
--                 verthoriz = '╋',
--             }
--
--             -- Set up nice borders for floating windows (especially for LSP)
--             vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
--                 vim.lsp.handlers.hover, {
--                     border = "single"
--                 }
--             )
--             vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
--                 vim.lsp.handlers.signatureHelp, {
--                     border = "single"
--                 }
--             )
--             vim.diagnostic.config({ float = { border = "single" } })
--
--             -- Apply the colorscheme
--             vim.cmd("colorscheme nightfly")
--
--             -- Custom statusline for terminal buffers
--             vim.cmd("set laststatus=0") -- Disable default statusline
--             vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)
--
--             vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#2d4f56") -- GUI background transparent
--             vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#2d4f56") -- Inactive StatusLine transparent for GUI
--         end,
--     },
-- }

-- return {
--     {
--         "rebelot/kanagawa.nvim",
--         name = "kanagawa",
--         priority = 1000,
--         lazy = false,
--         config = function()
--             require("kanagawa").setup({
--                 compile = false,            -- Enable compiling the colorscheme
--                 undercurl = true,           -- Enable undercurls
--                 commentStyle = { italic = true },
--                 functionStyle = {},
--                 keywordStyle = { italic = true },
--                 statementStyle = {},
--                 typeStyle = {},
--                 transparent = false,        -- Do not set background color
--                 dimInactive = false,        -- Dim inactive windows
--                 terminalColors = true,      -- Define terminal colors
--                 colors = {                  -- Custom overrides
--                     palette = {},
--                     theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
--                 },
--                 overrides = function(colors) -- Add/modify highlights
--                     return {}
--                 end,
--                 theme = "wave",            -- Load "wave" theme when 'background' option is not set
--                 background = {             -- Map the value of 'background' option to a theme
--                     dark = "wave",         -- 'wave' when background is 'dark'
--                     light = "lotus"        -- 'lotus' when background is 'light'
--                 },
--             })
--
--             vim.cmd("colorscheme kanagawa")
--
--             -- Custom statusline for terminal buffers
--             vim.cmd("set laststatus=0") -- Disable default statusline
--             vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)
--
--             vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#2d4f56") -- GUI background transparent
--             vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#2d4f56") -- Inactive StatusLine transparent for GUI
--         end,
--     },
-- }

-- return {
--     {
--         "EdenEast/nightfox.nvim",
--         name = "nightfox",
--         priority = 1000,
--         lazy = false,
--         config = function()
--             vim.cmd("colorscheme Terafox")
--
--             -- Custom statusline for terminal buffers
--             vim.cmd("set laststatus=0") -- Disable default statusline
--             vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)
--
--             vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#2d4f56") -- GUI background transparent
--             vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#2d4f56") -- Inactive StatusLine transparent for GUI
--         end,
--     }
-- }
