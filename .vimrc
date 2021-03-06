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

" Move lines up or down
nmap <C-k> ddkP
nmap <C-j> ddp
vmap <C-k> xkP`[V`]
vmap <C-j> xp`[V`]

" Gundo mappings
nnoremap <F5> :GundoToggle<CR>

" Command-T mappings
nnoremap <silent> <C-t> :CommandT<CR>
nnoremap <silent> <C-g> :CommandT app/<CR>
nnoremap <silent> <C-y> :CommandTBuffer<CR>
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

" Use <Enter> to move to the next item in the quickview window
map <Enter> :cn<CR>

" Show the name of the symbol under the cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'. synIDattr(synID(line("."),col("."),0),"name") . "> lo<". synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Open the vimrc in a new tab
map <F11> :tabe ~/.vimrc

if has("autocmd")
  " Source the vimrc file after saving it
  autocmd bufwritepost .vimrc source $MYVIMRC

  " Restore cursor position when opening a file
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
endif

command! W :w

let g:CommandTMaxHeight=12
let g:CommandTMatchWindowReverse=1
let g:CommandTMaxFiles=40000

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SWITCH BETWEEN TEST AND PRODUCTION CODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':e ' . new_file
endfunction
function! AlternateForCurrentFile()
  let lib_name = substitute(getcwd(), '^/.\+/', '', '')
  let current_file = expand("%")
  let new_file = current_file
  let in_spec = match(current_file, '^spec/') != -1
  let going_to_spec = !in_spec

  let in_app = 
    \ match(current_file, '\<controllers\>') != -1 ||
    \ match(current_file, '\<models\>') != -1 ||
    \ match(current_file, '\<views\>') != -1 ||
    \ match(current_file, '\<presenters\>') != -1 ||
    \ match(current_file, '\<helpers\>') != -1

  if going_to_spec
    let new_file = substitute(new_file, '\.rb$', '_spec.rb', '')
    let new_file = substitute(new_file, '\.html\.erb$', '_spec.rb', '')

    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    else
      let new_file = substitute(new_file, '^lib/', '', '')

      if !filereadable('spec/' . new_file)
        let new_file = substitute(new_file, '^' . lib_name . '/', '', '')
      end
    end

    let new_file = 'spec/' . new_file
  else
    let going_to_view = match(current_file, '\<views\>') != -1
    let erb_file = substitute(new_file, '_spec\.rb$', '.html.erb', '')

    if going_to_view && filereadable(erb_file)
      let new_file = erb_file
    else
      let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    end

    let new_file = substitute(new_file, '^spec/', '', '')
    if in_app
      let new_file = 'app/' . new_file
    else
      let new_file = substitute(new_file, '^' . lib_name . '/', '', '')
      let new_file = 'lib/' . lib_name . '/' . new_file
    end
  endif
  return new_file
endfunction
nnoremap ,, :call OpenTestAlternate()<CR>
