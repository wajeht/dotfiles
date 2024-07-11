" -----------------------------------------------------------------------------
" Netrw
" -----------------------------------------------------------------------------
let g:netrw_keepdir = 0      " Make Netrw change to the directory you are browsing
let g:netrw_banner = 0       " Disable the banner at the top of Netrw
let g:netrw_winsize = 30     " Set the initial size of the Netrw window to 30% of the screen
let g:netrw_liststyle = 3    " Set the listing style to a tree-style view
let g:netrw_altv=1           " open splits to the right

" -----------------------------------------------------------------------------
" Basic
" -----------------------------------------------------------------------------
colorscheme codedark         " Set the colorscheme to 'codedark'

syntax on                    " Enable syntax highlighting
set termguicolors            " Enable true color support
set noerrorbells             " Disable error bells
set noswapfile               " Disable swap file creation
set smartcase                " Enable smart case matching in searches
set smarttab                 " Make tabbing smarter
set cursorline               " Highlight the current line
set cursorcolumn             " Highlight the current column
set number                   " Show line numbers
set mouse=a                  " Enable mouse support in all modes
set background=dark          " Set the background to dark
set tabstop=4                " Set the width of a tab character to 4 spaces
set shiftwidth=4             " Set the number of spaces to use for each step of (auto)indent
set softtabstop=4            " Set the number of spaces a tab counts for in insert mode
set smartindent              " Enable smart indentation
set shortmess-=S             " Show occurrence of search terms
set expandtab                " Convert tabs to spaces
set relativenumber           " Show relative line numbers
set nu                       " Show absolute line numbers
set nowrap                   " Disable line wrapping
set incsearch                " Show search matches as you type
set hlsearch                 " Highlight search results
set ignorecase               " Ignore case in searches
set scrolloff=8              " Keep 8 lines visible above/below the cursor
set colorcolumn=100          " Highlight the 100th column
set spelllang=en_us          " Set the spell check language to US English
set ttyfast                  " Assume a fast terminal connection
set nospell                  " Disable spell checking
set ruler                    " Show the line and column number of the cursor position
set showmatch                " Briefly jump to matching bracket if one is inserted
set nofoldenable             " Disable code folding by default
set equalalways              " Ensure all windows are always equally sized
" set autochdir                " Change directory to the current buffer when opening files.

" Appearance
set showcmd                  " Display incomplete commands
set wildmenu                 " Visual autocomplete for command menu
set wildmode=longest:full,full " Command-line completion mode
set list                     " Show some invisible characters (tabs, trailing spaces)
set listchars=tab:▸\ ,trail:·,precedes:←,extends:→,eol:↲,nbsp:␣,space:· " Customize how invisible characters are displayed
set title                    " Set the terminal's title to the file being edited

" Editing
set autoindent               " Copy indent from current line when starting a new line
set backspace=indent,eol,start " Allow backspacing over everything in insert mode
set clipboard=unnamedplus    " Use the system clipboard
set completeopt=menuone,noselect " Better autocompletion experience
set conceallevel=0           " So that I can see `` in markdown files
set history=1000             " Store lots of :cmdline history
set updatetime=300           " Faster completion (4000ms default)
set undofile                 " Save undo history to an undo file

" Search
set wrapscan                 " Searches wrap around the end of the file
" set inccommand=nosplit       " Show effects of a command incrementally

" Performance
set lazyredraw               " Do not redraw while executing macros
set timeoutlen=500           " Time to wait for a mapped sequence to complete (in milliseconds)
set ttimeoutlen=50           " Time to wait for a key code sequence to complete

" -----------------------------------------------------------------------------
" Remap
" -----------------------------------------------------------------------------
let mapleader = " "          " Set the leader key to space

nnoremap <C-J> <C-W><C-J>    " Remap Ctrl+J to switch to the window below
nnoremap <C-K> <C-W><C-K>    " Remap Ctrl+K to switch to the window above
nnoremap <C-L> <C-W><C-L>    " Remap Ctrl+L to switch to the window to the right
nnoremap <C-H> <C-W><C-H>    " Remap Ctrl+H to switch to the window to the left

" Insert paired curly braces and place cursor inside
inoremap { {}<Esc>ha
" Insert paired parentheses and place cursor inside
inoremap ( ()<Esc>ha
" Insert paired square brackets and place cursor inside
inoremap [ []<Esc>ha
" Insert paired double quotes and place cursor inside
inoremap " ""<Esc>ha
" Insert paired single quotes and place cursor inside
inoremap ' ''<Esc>ha
" Insert paired backticks and place cursor inside
inoremap ` ``<Esc>ha

" Cursor shape
if &termguicolors
  let &t_SI = "\e[5 q"       " Cursor shape for insert mode: vertical bar (I)
  let &t_EI = "\e[1 q"       " Cursor shape for normal mode: block
endif

" -----------------------------------------------------------------------------
" Plugins
" -----------------------------------------------------------------------------
call plug#begin('~/.vim/pluged')
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'tomasiser/vim-code-dark'
call plug#end()
