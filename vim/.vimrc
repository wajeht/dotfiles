" -----------------------------------------------------------------------------
" Basic Settings
" -----------------------------------------------------------------------------
set nocompatible             " Disable vi compatibility
syntax on                    " Enable syntax highlighting
set termguicolors            " Enable true color support
set background=dark          " Set background to dark
colorscheme slate            " Use a dark built-in colorscheme

" Line numbers
set number                   " Show absolute line numbers
set relativenumber           " Show relative line numbers

" Tabs & indentation
set tabstop=4                " 4 spaces for tabs
set shiftwidth=4             " 4 spaces for indent width
set softtabstop=4            " 4 spaces for tab in insert mode
set expandtab                " Convert tabs to spaces
set autoindent               " Copy indent from current line
set smartindent              " Enable smart indentation
set smarttab                 " Make tabbing smarter

" Search settings
set incsearch                " Show search matches as you type
set hlsearch                 " Highlight search results
set ignorecase               " Ignore case in searches
set smartcase                " Smart case matching in searches
set wrapscan                 " Searches wrap around end of file

" Appearance
set cursorline               " Highlight current line
set scrolloff=8              " Keep 8 lines visible above/below cursor
set colorcolumn=100          " Highlight 100th column
set showcmd                  " Display incomplete commands
set wildmenu                 " Visual autocomplete for command menu
set wildmode=longest:full,full " Command-line completion mode
set showmatch                " Briefly jump to matching bracket
set ruler                    " Show cursor position
set title                    " Set terminal title

" Performance & behavior
set noerrorbells             " Disable error bells
set noswapfile               " Disable swap files
set ttyfast                  " Assume fast terminal
set updatetime=300           " Faster completion
set timeoutlen=500           " Time to wait for mapped sequence
set ttimeoutlen=50           " Time to wait for key code sequence
set lazyredraw               " Don't redraw during macros
set mouse=a                  " Enable mouse support
set backspace=indent,eol,start " Allow backspace over everything
set clipboard=unnamedplus    " Use system clipboard

" Visual elements
set list                     " Show invisible characters
set listchars=tab:▸\ ,trail:·,precedes:←,extends:→,nbsp:␣
set nowrap                   " Disable line wrapping
set splitright               " Split vertical windows to right
set splitbelow               " Split horizontal windows below

" -----------------------------------------------------------------------------
" Key Mappings
" -----------------------------------------------------------------------------
let mapleader = " "          " Set leader key to space

" Clear search highlights
nnoremap <Esc> :nohlsearch<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Window management
nnoremap <leader>sv <C-w>v
nnoremap <leader>sh <C-w>s
nnoremap <leader>se <C-w>=
nnoremap <leader>sx :close<CR>

" Tab management
nnoremap <leader>to :tabnew<CR>
nnoremap <leader>tx :tabclose<CR>
nnoremap <leader>tn :tabn<CR>
nnoremap <leader>tp :tabp<CR>
nnoremap <Tab> :tabn<CR>
nnoremap <S-Tab> :tabp<CR>

" File operations
nnoremap <leader>w :wa!<CR>
nnoremap <leader>q :qall!<CR>
nnoremap <leader>z :wqall!<CR>

" Move lines in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Join lines without moving cursor
nnoremap J mzJ`z

" Paste without modifying clipboard in visual mode
xnoremap <leader>p "_dP

" Centering navigation
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap { {zz
nnoremap } }zz
nnoremap n nzz
nnoremap N Nzz
nnoremap G Gzz
nnoremap gg ggzz
nnoremap * *zz
nnoremap # #zz
nnoremap % %zz

" File explorer (using netrw)
nnoremap <leader>e :Vexplore<CR>

" Auto-pairs (manual implementation)
inoremap { {}<Esc>ha
inoremap ( ()<Esc>ha
inoremap [ []<Esc>ha
inoremap " ""<Esc>ha
inoremap ' ''<Esc>ha
inoremap ` ``<Esc>ha

" -----------------------------------------------------------------------------
" Netrw Settings (built-in file explorer)
" -----------------------------------------------------------------------------
let g:netrw_banner = 0       " Disable banner
let g:netrw_liststyle = 3    " Tree style
let g:netrw_winsize = 30     " 30% width
let g:netrw_altv = 1         " Open splits to right

" -----------------------------------------------------------------------------
" Auto Commands
" -----------------------------------------------------------------------------
if has("autocmd")
  " Remove trailing whitespace on save
  autocmd BufWritePre * %s/\s\+$//e

  " Return to last edit position
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" -----------------------------------------------------------------------------
" Status Line
" -----------------------------------------------------------------------------
set laststatus=2             " Always show status line
set statusline=%f            " File name
set statusline+=\ %h%m%r%w   " Flags
set statusline+=%=           " Right align
set statusline+=\ %y         " File type
set statusline+=\ %{&encoding}
set statusline+=\ %l,%c      " Line, column
set statusline+=\ %P         " Percentage
