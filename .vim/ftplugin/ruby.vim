let ruby_operators=1

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
        exec ":!bundle exec rspec --color " . a:filename
    end
endfunction

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
