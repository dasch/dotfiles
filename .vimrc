set runtimepath+=~/Projects/dotfiles/.vim

call pathogen#infect()

set nocompatible

syntax on
filetype on
filetype indent on
filetype plugin on

set number
set hidden
set incsearch ignorecase smartcase
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

" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>

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

" Convert a curly block to a do .. end block
function! ConvertCurlyToDoEnd()
    :normal _
    :s/{ /do\r/
    :normal ==
    :s/ }$/\rend/
    :normal ==
    :normal -
endfunction

function! ConvertDoEndToCurly()
  call search("do", "cWb")
  :s/do\n\s*\(.\+\)\n\s*end/{ \1 }/
endfunction

:map <Leader>k :call ConvertCurlyToDoEnd()<CR>
:map <Leader>j :call ConvertDoEndToCurly()<CR>


" Promote a variable assignment to a let statement
function! PromoteToLet()
  :normal! dd
  " :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
  " :normal! <<
  " :normal! ilet(:
  " :normal! f 2cl) {
  " :normal! A }
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>p :PromoteToLet<cr><cr>

let g:CommandTMaxHeight=12
let g:CommandTMatchWindowReverse=1
let g:CommandTMaxFiles=40000

let ruby_operators=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <leader>l :call RunTestFile()<cr>
noremap <leader>; :call RunNearestTest()<cr>
noremap <leader>o :call RunTests('')<cr>

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
    if in_test_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        let t:grb_test_file = AlternateForCurrentFile()
    end
    call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number . " -b")
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunTests(filename)
    " Write the file and run tests for the given filename

    if filereadable(a:filename)
      :w
    end

    if match(a:filename, '_test\.rb$') != -1
        exec ":!testrb -Itest -I. " . a:filename
    else
        if a:filename == ""
            let args = "--format Fuubar"
        else
            let args = "--color"
        end

        exec ":!rspec " . args . " " . a:filename
    end
endfunction


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
  let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1 || match(current_file, '\<helpers\>') != -1
  if going_to_spec
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    else
      let new_file = substitute(new_file, '^lib/' . lib_name . '/', '', '')
    end
    let new_file = substitute(new_file, '\.rb$', '_spec.rb', '')
    let new_file = substitute(new_file, '\.html\.erb$', '_spec.rb', '')
    let new_file = 'spec/' . new_file
  else
    let going_to_view = match(current_file, '\<views\>') != -1
    if going_to_view
      let new_file = substitute(new_file, '_spec\.rb$', '.html.erb', '')
    else
      let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    end

    let new_file = substitute(new_file, '^spec/', '', '')
    if in_app
      let new_file = 'app/' . new_file
    else
      let new_file = 'lib/' . lib_name . '/' . new_file
    end
  endif
  return new_file
endfunction
nnoremap ,, :call OpenTestAlternate()<CR>
