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
--     },
--     -- {
--     -- 	"rockyzhang24/arctic.nvim",
--     -- 	dependencies = { "rktjmp/lush.nvim" },
--     -- 	name = "arctic",
--     -- 	branch = "v2",
--     -- },
-- }
--
return {
    {
        "rockyzhang24/arctic.nvim",
        dependencies = { "rktjmp/lush.nvim" },
        name = "arctic",
        branch = "v2",
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
