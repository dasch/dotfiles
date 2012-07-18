let ruby_operators=1

" Regard : as part of words.
set iskeyword+=:

" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>

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
            let args = ""
        end

        exec ":!rspec --color " . args . " " . a:filename
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

function! ConvertToMultiLineHash()
  :normal! _
  call search("=>")
  :normal! B
  :normal! vg_h
  :normal S}
  :normal! a
  :normal! g_hik
  :.s/, /,\r\t/g
endfunction
