
" import our python functions
let s:rootdir = fnamemodify(expand("<sfile>"), ":h")."/"
execute "py3file ".fnameescape(s:rootdir."toggle_test.py")

" bind keys
" Commented because this key clashes, and Kraken makes this toggling hard to do.
" nnoremap <silent> <Leader>a :python3 toggle_test()<cr>

