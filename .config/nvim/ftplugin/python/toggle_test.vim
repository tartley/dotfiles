
" import our python functions
let s:rootdir = fnamemodify(expand("<sfile>"), ":h")."/"
execute "py3file ".fnameescape(s:rootdir."toggle_test.py")

" bind keys
nnoremap <silent> <Leader>a :python3 toggle_test()<cr>

