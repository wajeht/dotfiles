-- return {
--     {
--         "rockyzhang24/arctic.nvim",
--         name = "arctic",
--         branch = "v2",
--         dependencies = { "rktjmp/lush.nvim" },
--         priority = 1000,
--         lazy = false,
--         config = function()
--             vim.cmd("colorscheme arctic")

--             -- Custom statusline for terminal buffers
--             vim.cmd("set laststatus=3") -- Disable default statusline
--             vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

--             vim.cmd("hi StatusLine gui=NONE guibg=#181818 guifg=#333333") -- GUI background transparent
--             vim.cmd("hi StatusLineNC gui=NONE guibg=#181818 guifg=#333333") -- Inactive StatusLine transparent for GUI
--         end,
--     },
-- }

return {
    {
        "folke/tokyonight.nvim",
        name = "tokyonight",
        priority = 1000,
        lazy = false,
        config = function()
            vim.cmd("colorscheme tokyonight-night")

            -- Custom statusline for terminal buffers
            vim.cmd("set laststatus=0") -- Disable default statusline
            vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

            -- vim.cmd("hi StatusLine gui=NONE guibg=#NONE guifg=#3c425f") -- GUI background transparent
            -- vim.cmd("hi StatusLineNC gui=NONE guibg=#NONE guifg=#3c425f") -- Inactive StatusLine transparent for GUI
        end,
    },
}

-- return {
--     {
--         "EdenEast/nightfox.nvim",
--         name = "nightfox",
--         priority = 1000,
--         lazy = false,
--         config = function()
--             vim.cmd("colorscheme Terafox")

--             -- Custom statusline for terminal buffers
--             vim.cmd("set laststatus=0") -- Disable default statusline
--             vim.cmd("set statusline=%{repeat('─',winwidth('.'))}") -- Custom statusline (only a line of dashes)

--             vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#2b4046") -- GUI background transparent
--             vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#2b4046") -- Inactive StatusLine transparent for GUI
--         end,
--     }
-- }
