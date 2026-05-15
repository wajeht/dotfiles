-- Netrw settings
vim.g.loaded_netrw = 1 -- disable netrw
vim.g.loaded_netrwPlugin = 1 -- disable netrw plugin

-- Filetype detection needed by LSP/Treesitter for custom extensions and filenames.
vim.filetype.add({
	extension = {
		ejs = "embedded_template",
		gotmpl = "gotmpl",
		tmpl = "gotmpl",
		tpl = "gotmpl",
	},
})

-- vim.cmd("let g:netrw_keepdir = 0")  -- Make Netrw change to the directory you are browsing
-- vim.cmd("let g:netrw_banner = 0")   -- Disable the banner at the top of Netrw
-- vim.cmd("let g:netrw_winsize = 30") -- Set the initial size of the Netrw window to 30% of the screen
-- vim.cmd("let g:netrw_liststyle = 3")-- Set the listing style to a tree-style view
-- vim.cmd("let g:netrw_altv = 1")     -- Open splits to the right

local opt = vim.opt

-- UI
opt.number = true -- Show absolute line numbers
opt.relativenumber = true -- Show relative line numbers
opt.cursorline = true -- Highlight the current line number
opt.cursorlineopt = "number" -- Only highlight the current line number
opt.signcolumn = "yes" -- Show sign column so that text doesn't shift
opt.termguicolors = true -- Enable true color support
opt.winborder = "rounded" -- Border style for floating windows
opt.pumborder = "rounded" -- Border style for completion menu
opt.pumheight = 10 -- Limit completion menu height
opt.pummaxwidth = 80 -- Keep completion popups readable on long LSP labels
opt.pumblend = 10 -- Slight transparency for popup menu
opt.cmdheight = 0 -- Hide command line when it is not actively used

-- Custom statusline for terminal buffers
opt.laststatus = 0 -- Disable default statusline
opt.statusline = "%{repeat('─',winwidth('.'))}" -- Custom statusline (only a line of dashes)

opt.ruler = false -- Hide ruler
opt.showmode = false -- Don't show the mode, since it's already in the status line
opt.title = true -- Set the terminal's title to the file being edited
opt.fillchars:append({ eob = " " }) -- Remove ~ from buffer

-- Text layout
opt.wrap = false -- Disable line wrapping
opt.linebreak = true -- Break lines at word boundaries
opt.showbreak = "↪ " -- Show line breaks
opt.breakindent = true -- Enable break indent
opt.scrolloff = 8 -- Keep 8 lines visible above/below the cursor
opt.sidescrolloff = 8 -- Keep 8 columns visible left/right of cursor

-- Indentation
opt.tabstop = 4 -- 4 spaces for tabs
opt.shiftwidth = 4 -- 4 spaces for indent width
opt.softtabstop = 4 -- Set the number of spaces a tab counts for in insert mode
opt.expandtab = true -- Expand tab to spaces
opt.smartindent = true -- Enable smart indentation

-- Search
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true -- If you include mixed case in your search, assumes you want case-sensitive

-- Editing
opt.clipboard = "unnamedplus" -- Use the system clipboard
opt.inccommand = "split" -- Preview substitutions live, as you type!
opt.mouse = "a" -- Enable mouse support in all modes
opt.spelllang = "en_us" -- Set the spell check language to US English
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = { "longest:full", "full" } -- Command-line completion mode
opt.completeopt:append({ "menuone", "noselect", "fuzzy", "nearest" }) -- Keep 0.12 defaults and add better completion behavior
opt.iskeyword:append("-") -- Include hyphens in keywords
opt.shortmess:remove("S") -- Show occurrence of search terms

-- Use OSC 52 over SSH (copy syncs to local clipboard, paste uses Neovim registers)
if os.getenv("SSH_TTY") then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = function()
				return vim.fn.getreg("0")
			end,
			["*"] = function()
				return vim.fn.getreg("0")
			end,
		},
	}
end

-- Splits and files
opt.splitright = true -- Split vertical window to the right
opt.splitbelow = true -- Split horizontal window to the bottom
opt.swapfile = false -- Disable swap file creation
opt.writebackup = false -- Disable backup before overwriting file

-- Whitespace
opt.list = true -- Show some invisible characters
opt.listchars = {
	tab = "▸ ", -- Tab characters will appear as "▸ ".
	trail = "·", -- Trailing spaces will appear as "·".
	precedes = "←", -- "←" indicates hidden text to the left.
	extends = "→", -- "→" indicates hidden text to the right.
	eol = "↲", -- End-of-line characters will appear as "↲".
	nbsp = "␣", -- Non-breaking spaces will appear as "␣".
	space = "·", -- Regular spaces will appear as "·".
	leadmultispace = ".", -- Leading spaces will appear as ".".
}

-- Undo
opt.undofile = true -- Save undo history to an undo file
local undodir = os.getenv("HOME") .. "/.vim/undodir"
if not vim.fn.isdirectory(undodir) then
	vim.fn.mkdir(undodir, "p")
end
opt.undodir = undodir -- Set undo directory

-- Diff and responsiveness
opt.diffopt:append("algorithm:patience") -- Cleaner diffs on refactored code
opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete
opt.updatetime = 50 -- Faster completion
