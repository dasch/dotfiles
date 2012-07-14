set runtimepath+=~/Projects/dotfiles/.vim

call pathogen#infect()

set nocompatible

syntax on
filetype on
filetype indent on
filetype plugin on

set number
set hidden
set showcmd
set hlsearch incsearch ignorecase smartcase
set nofoldenable
set laststatus=2
set statusline=\ %f%=Line:\ %03l\ \ Column:\ %03c\ \   
set path=$PWD/**
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*.so,*/vendor/*,*/doc/*,*/tmp/*

set tabstop=2 softtabstop=2
set expandtab shiftwidth=2

" Add some padding to the left
set foldcolumn=1

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=

abbrev serach search

" Enable cursorline for the current window.
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline

if has("gui_running")
  set cursorline
  set guioptions=egmt
  "set columns=162 lines=45
  set transparency=5
  set showtabline=2
  set vb
  set scrolloff=2
  colorscheme satellite
else
  set t_Co=256
  color grb256
  set scrolloff=8
endif

" Command-T mappings
nnoremap <silent> <C-t> :CommandT<CR>
nnoremap <silent> <leader>t :CommandT<CR>
nnoremap <silent> <C-y> :CommandTBuffer<CR>
nnoremap <silent> <leader>y :CommandTBuffer<CR>
nnoremap <silent> <leader>o :CommandTTag<CR>

" Don't allow using the arrow keys in normal mode
map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

" Tab navigation
map th :tabfirst<CR>
map tj :tabnext<CR>
map tk :tabprev<CR>
map tl :tablast<CR>
map tt :tabedit<Space>
map tn :tabnew<Space>

" Show the name of the symbol under the cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'. synIDattr(synID(line("."),col("."),0),"name") . "> lo<". synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Open the vimrc in a new tab
map <F11> :tabe ~/.vimrc

command! W :w

let g:CommandTMaxHeight=12
let g:CommandTMatchWindowReverse=1
let g:CommandTMaxFiles=40000
