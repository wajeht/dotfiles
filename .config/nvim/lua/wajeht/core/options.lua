-- Netrw settings
vim.cmd("let g:netrw_keepdir = 0")  -- Make Netrw change to the directory you are browsing
vim.cmd("let g:netrw_banner = 0")   -- Disable the banner at the top of Netrw
vim.cmd("let g:netrw_winsize = 30") -- Set the initial size of the Netrw window to 30% of the screen
vim.cmd("let g:netrw_liststyle = 3")-- Set the listing style to a tree-style view
vim.cmd("let g:netrw_altv = 1")     -- Open splits to the right

vim.opt.relativenumber = true           -- Show relative line numbers
vim.opt.number = true                   -- Show absolute line numbers

-- tabs & indentation
vim.opt.tabstop = 2                     -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2                  -- 2 spaces for indent width
vim.opt.expandtab = true                -- expand tab to spaces
vim.opt.autoindent = true               -- copy indent from current line when starting new one

vim.opt.wrap = false                    -- Disable line wrapping

-- search settings
vim.opt.ignorecase = true               -- ignore case when searching
vim.opt.smartcase = true                -- if you include mixed case in your search, assumes you want case-sensitive

vim.opt.cursorline = true               -- Highlight the current line
vim.opt.cursorcolumn = true             -- Highlight the current column

-- turn on termguicolors for codedark colorscheme to work
vim.opt.termguicolors = true            -- Enable true color support
vim.opt.background = "dark"             -- colorschemes that can be light or dark will be made dark
vim.opt.signcolumn = "yes"              -- show sign column so that text doesn't shift

-- backspace
vim.opt.backspace = "indent,eol,start"  -- allow backspace on indent, end of line or insert mode start position

-- clipboard
vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
vim.opt.splitright = true               -- split vertical window to the right
vim.opt.splitbelow = true               -- split horizontal window to the bottom

-- turn off swapfile
vim.opt.swapfile = false                -- Disable swap file creation

-- Other settings
-- vim.opt.noerrorbells = true             -- Disable error bells
vim.opt.smarttab = true                 -- Make tabbing smarter
vim.opt.mouse = "a"                     -- Enable mouse support in all modes
vim.opt.tabstop = 4                     -- Set the width of a tab character to 4 spaces
vim.opt.shiftwidth = 4                  -- Set the number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 4                 -- Set the number of spaces a tab counts for in insert mode
vim.opt.smartindent = true              -- Enable smart indentation
vim.opt.shortmess:remove("S")           -- Show occurrence of search terms
vim.opt.expandtab = true                -- Convert tabs to spaces
vim.opt.incsearch = true                -- Show search matches as you type
vim.opt.hlsearch = true                 -- Highlight search results
vim.opt.scrolloff = 8                   -- Keep 8 lines visible above/below the cursor
vim.opt.colorcolumn = "100"             -- Highlight the 100th column
vim.opt.spelllang = "en_us"             -- Set the spell check language to US English
vim.opt.ttyfast = true                  -- Assume a fast terminal connection
-- vim.opt.nospell = true                  -- Disable spell checking
vim.opt.ruler = true                    -- Show the line and column number of the cursor position
vim.opt.showmatch = true                -- Briefly jump to matching bracket if one is inserted
-- vim.opt.nofoldenable = true             -- Disable code folding by default
vim.opt.equalalways = true              -- Ensure all windows are always equally sized

-- Appearance
vim.opt.showcmd = true                  -- Display incomplete commands
vim.opt.wildmenu = true                 -- Visual autocomplete for command menu
vim.opt.wildmode = {"longest:full", "full"} -- Command-line completion mode
vim.opt.list = true                     -- Show some invisible characters
vim.opt.listchars = { tab = "▸ ", trail = "·", precedes = "←", extends = "→", eol = "↲", nbsp = "␣", space = "·" } -- Customize how invisible characters are displayed
vim.opt.title = true                    -- Set the terminal's title to the file being edited

-- Editing
vim.opt.autoindent = true               -- Copy indent from current line when starting a new line
vim.opt.completeopt = {"menuone", "noselect"} -- Better autocompletion experience
vim.opt.conceallevel = 0                -- So that I can see `` in markdown files
vim.opt.history = 1000                  -- Store lots of :cmdline history
vim.opt.updatetime = 300                -- Faster completion (4000ms default)

-- undo settings
opt.undofile = true                     -- Save undo history to an undo file
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Set undo directory

-- Search
vim.opt.wrapscan = true                 -- Searches wrap around the end of the file
-- vim.opt.inccommand = "nosplit"        -- Uncomment to show effects of a command incrementally

-- Performance
vim.opt.lazyredraw = true               -- Do not redraw while executing macros
vim.opt.timeoutlen = 500                -- Time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.ttimeoutlen = 50                -- Time to wait for a key code sequence to complete
