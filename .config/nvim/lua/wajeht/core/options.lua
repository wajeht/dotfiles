-- Netrw settings
vim.cmd("let g:netrw_keepdir = 0")  -- Make Netrw change to the directory you are browsing
vim.cmd("let g:netrw_banner = 0")   -- Disable the banner at the top of Netrw
vim.cmd("let g:netrw_winsize = 30") -- Set the initial size of the Netrw window to 30% of the screen
vim.cmd("let g:netrw_liststyle = 3")-- Set the listing style to a tree-style view
vim.cmd("let g:netrw_altv = 1")     -- Open splits to the right

vim.cmd("setlocal laststatus=0") -- Hide the statusline for terminal buffers

vim.opt.relativenumber = true           -- Show relative line numbers
vim.opt.number = true                   -- Show absolute line numbers

-- Tabs & indentation
vim.opt.tabstop = 4                     -- 4 spaces for tabs
vim.opt.shiftwidth = 4                  -- 4 spaces for indent width
vim.opt.expandtab = true                -- Expand tab to spaces
vim.opt.autoindent = true               -- Copy indent from current line when starting new one
vim.opt.smarttab = true                 -- Make tabbing smarter
vim.opt.smartindent = true              -- Enable smart indentation
vim.opt.softtabstop = 4                 -- Set the number of spaces a tab counts for in insert mode

vim.opt.wrap = false                    -- Disable line wrapping

-- Search settings
vim.opt.ignorecase = true               -- Ignore case when searching
vim.opt.smartcase = true                -- If you include mixed case in your search, assumes you want case-sensitive
vim.opt.incsearch = true                -- Show search matches as you type
vim.opt.hlsearch = true                 -- Highlight search results

vim.opt.cursorline = true               -- Highlight the current line
vim.opt.cursorcolumn = true             -- Highlight the current column

-- Colors and appearance
vim.opt.termguicolors = true            -- Enable true color support
vim.opt.background = "dark"             -- Colorschemes that can be light or dark will be made dark
vim.opt.signcolumn = "yes"              -- Show sign column so that text doesn't shift

-- Backspace
vim.opt.backspace = "indent,eol,start"  -- Allow backspace on indent, end of line or insert mode start position

-- Clipboard
vim.opt.clipboard = "unnamedplus"       -- Use system clipboard as default register

-- Split windows
vim.opt.splitright = true               -- Split vertical window to the right
vim.opt.splitbelow = true               -- Split horizontal window to the bottom

-- Turn off swapfile
vim.opt.swapfile = false                -- Disable swap file creation

-- Other settings
vim.opt.breakindent = true              -- Enable break indent
vim.opt.inccommand = 'split'            -- Preview substitutions live, as you type!
vim.opt.mouse = "a"                     -- Enable mouse support in all modes
vim.opt.showmode = false                -- Don't show the mode, since it's already in the status line
vim.opt.shortmess:remove("S")           -- Show occurrence of search terms
vim.opt.scrolloff = 10                  -- Keep 10 lines visible above/below the cursor
vim.opt.colorcolumn = "100"             -- Highlight the 100th column
vim.opt.spelllang = "en_us"             -- Set the spell check language to US English
vim.opt.ttyfast = true                  -- Assume a fast terminal connection
vim.opt.ruler = true                    -- Show the line and column number of the cursor position
vim.opt.showmatch = true                -- Briefly jump to matching bracket if one is inserted
vim.opt.equalalways = true              -- Ensure all windows are always equally sized
vim.opt.cmdheight = 0                   -- hide command line when it is not actively used

-- Appearance
vim.opt.showcmd = true                  -- Display incomplete commands
vim.opt.wildmenu = true                 -- Visual autocomplete for command menu
vim.opt.wildmode = {"longest:full", "full"} -- Command-line completion mode
vim.opt.list = true                     -- Show some invisible characters
vim.opt.title = true                    -- Set the terminal's title to the file being edited
vim.opt.listchars = {
  tab = "▸ ",      -- Tab characters will appear as "▸ ".
  trail = "·",     -- Trailing spaces will appear as "·".
  precedes = "←",  -- "←" indicates hidden text to the left.
  extends = "→",   -- "→" indicates hidden text to the right.
  -- eol = "↲",       -- End-of-line characters will appear as "↲".
  nbsp = "␣",      -- Non-breaking spaces will appear as "␣".
  space = "·"      -- Regular spaces will appear as "·".
}

-- Editing
vim.opt.completeopt = {"menuone", "noselect"} -- Better autocompletion experience
vim.opt.conceallevel = 0                -- So that I can see `` in markdown files
vim.opt.history = 1000                  -- Store lots of :cmdline history
vim.opt.updatetime = 250                -- Faster completion (4000ms default)

-- Undo settings
vim.opt.undofile = true                 -- Save undo history to an undo file
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Set undo directory

-- Search
vim.opt.wrapscan = true                 -- Searches wrap around the end of the file

-- Performance
vim.opt.lazyredraw = true               -- Do not redraw while executing macros
vim.opt.timeoutlen = 300                -- Time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.ttimeoutlen = 50                -- Time to wait for a key code sequence to complete
