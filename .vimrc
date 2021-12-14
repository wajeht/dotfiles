" theme
colorscheme onedark 

" my settings
syntax on
set termguicolors
set noerrorbells
set noswapfile
set smartcase
set cursorline
set number
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
set scrolloff=8
set colorcolumn=100

" netrw stuff
let g:netrw_banner = 0
" let g:netrw_browse_split = 2 
" let g:netrw_keepdir = 0
" let g:netrw_winsize = 25

" enable js doc syntx highlight
let g:javascript_plugin_jsdoc = 1

" plugin
call plug#begin('~/.vim/pluged')
    Plug 'Valloric/YouCompleteMe'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
call plug#end()

