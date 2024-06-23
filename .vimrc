" -----------------------------------------------------------------------------
" Netrw
" -----------------------------------------------------------------------------
let g:netrw_keepdir = 0
let g:netrw_banner = 0
let g:netrw_winsize = 30
let g:netrw_liststyle = 3

" -----------------------------------------------------------------------------
" Basic
" -----------------------------------------------------------------------------
colorscheme codedark

syntax on
set termguicolors
set noerrorbells
set noswapfile
set smartcase
set smarttab
set cursorline
set number
set mouse=a
set background=dark
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smartindent
set expandtab
set relativenumber
set nu
set nowrap
set incsearch
set hlsearch
set ignorecase
set incsearch
set scrolloff=8
set colorcolumn=100
set spelllang=en_us
set ttyfast
set nospell
set ruler
set showmatch
set nofoldenable

" -----------------------------------------------------------------------------
" Remap
" -----------------------------------------------------------------------------
let mapleader = " "

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
