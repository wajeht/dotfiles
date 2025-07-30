-- Netrw settings
vim.g.loaded_netrw = 1 -- disable nerd tree
vim.g.loaded_netrwPlugin = 1 -- disable nerd tree
-- vim.cmd("let g:netrw_keepdir = 0")  -- Make Netrw change to the directory you are browsing
-- vim.cmd("let g:netrw_banner = 0")   -- Disable the banner at the top of Netrw
-- vim.cmd("let g:netrw_winsize = 30") -- Set the initial size of the Netrw window to 30% of the screen
-- vim.cmd("let g:netrw_liststyle = 3")-- Set the listing style to a tree-style view
-- vim.cmd("let g:netrw_altv = 1")     -- Open splits to the right

vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.number = true -- Show absolute line numbers

-- Tabs & indentation
vim.opt.tabstop = 4 -- 4 spaces for tabs
vim.opt.shiftwidth = 4 -- 4 spaces for indent width
vim.opt.expandtab = true -- Expand tab to spaces
vim.opt.autoindent = true -- Copy indent from current line when starting new one
vim.opt.smarttab = true -- Make tabbing smarter
vim.opt.smartindent = true -- Enable smart indentation
vim.opt.softtabstop = 4 -- Set the number of spaces a tab counts for in insert mode

vim.opt.wrap = false -- Disable line wrapping

-- Remove ~ from buffer
vim.opt.fillchars:append({ eob = " " })

-- Search settings
vim.opt.ignorecase = true -- Ignore case when searching
vim.opt.smartcase = true -- If you include mixed case in your search, assumes you want case-sensitive
vim.opt.incsearch = true -- Show search matches as you type
vim.opt.hlsearch = true -- Highlight search results
vim.opt.magic = true -- Use extended regular expressions
vim.opt.wrapscan = true -- Searches wrap around the end of the file

vim.opt.cursorline = false -- Highlight the current line
vim.opt.cursorcolumn = false -- Highlight the current column

-- Colors and appearance
vim.opt.termguicolors = true -- Enable true color support
vim.opt.background = "dark" -- Colorschemes that can be light or dark will be made dark
vim.opt.signcolumn = "yes" -- Show sign column so that text doesn't shift

-- Backspace
vim.opt.backspace = "indent,eol,start" -- Allow backspace on indent, end of line or insert mode start position

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- Use system clipboard as default register

-- Split windows
vim.opt.splitright = true -- Split vertical window to the right
vim.opt.splitbelow = true -- Split horizontal window to the bottom

-- Turn off swapfile
vim.opt.swapfile = false -- Disable swap file creation
vim.opt.backup = false -- Disable backup files
vim.opt.writebackup = false -- Disable backup before overwriting file

-- Other settings
vim.opt.breakindent = true -- Enable break indent
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!
vim.opt.mouse = "a" -- Enable mouse support in all modes
vim.opt.showmode = false -- Don't show the mode, since it's already in the status line
vim.opt.shortmess:remove("S") -- Show occurrence of search terms
vim.opt.scrolloff = 8 -- Keep 8 lines visible above/below the cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible left/right of cursor
-- vim.opt.colorcolumn = "80" -- Highlight the 80th column
vim.opt.spelllang = "en_us" -- Set the spell check language to US English
vim.opt.ttyfast = true -- Assume a fast terminal connection
-- vim.opt.showmatch = true                -- Briefly jump to matching bracket if one is inserted
-- vim.opt.matchtime = 0                   -- Make the jump shorter (0.2 seconds)
vim.opt.equalalways = true -- Ensure all windows are always equally sized
vim.opt.ruler = false -- hide ruler
vim.opt.cmdheight = 0 -- hide command line when it is not actively used

-- Appearance
vim.opt.linebreak = true -- Break lines at word boundaries
vim.opt.showbreak = "↪ " -- Show line breaks
vim.opt.pumheight = 10 -- Limit completion menu height
vim.opt.pumblend = 10 -- Slight transparency for popup menu
vim.opt.showcmd = true -- Display incomplete commands
vim.opt.wildmenu = true -- Visual autocomplete for command menu
vim.opt.wildmode = { "longest:full", "full" } -- Command-line completion mode
vim.opt.list = true -- Show some invisible characters
vim.opt.title = true -- Set the terminal's title to the file being edited
vim.opt.listchars = {
	tab = "▸ ", -- Tab characters will appear as "▸ ".
	trail = "·", -- Trailing spaces will appear as "·".
	precedes = "←", -- "←" indicates hidden text to the left.
	extends = "→", -- "→" indicates hidden text to the right.
	-- eol = "↲",       -- End-of-line characters will appear as "↲".
	nbsp = "␣", -- Non-breaking spaces will appear as "␣".
	-- space = "·", -- Regular spaces will appear as "·".
}

-- Editing
vim.opt.completeopt = { "menuone", "noselect" } -- Better autocompletion experience
vim.opt.conceallevel = 0 -- So that I can see `` in markdown files
vim.opt.history = 100 -- Store lots of :cmdline history
vim.opt.updatetime = 50 -- Faster completion

-- Undo settings
vim.opt.undofile = true -- Save undo history to an undo file
local undodir = os.getenv("HOME") .. "/.vim/undodir"
if not vim.fn.isdirectory(undodir) then
	vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir -- Set undo directory

-- Performance optimizations
vim.opt.lazyredraw = true -- Do not redraw while executing macros
vim.opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete (reduced from 400ms)
vim.opt.ttimeoutlen = 0 -- Instant key code recognition
vim.opt.updatetime = 250 -- Balanced update time
vim.opt.redrawtime = 1500 -- Time in milliseconds for redrawing the display (default: 2000)
vim.opt.synmaxcol = 120 -- Only highlight the first 120 columns for better performance
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.regexpengine = 1 -- Use old regex engine for better performance

-- Custom statusline for terminal buffers
-- vim.cmd("set laststatus=0")  -- Disable default statusline
-- vim.cmd("set statusline=%{repeat('─',winwidth('.'))}")  -- Custom statusline (only a line of dashes)

-- vim.cmd("hi StatusLine gui=NONE guibg=NONE guifg=#2d4f56")  -- GUI background transparent
-- vim.cmd("hi StatusLineNC gui=NONE guibg=NONE guifg=#2d4f56")  -- Inactive StatusLine transparent for GUI
