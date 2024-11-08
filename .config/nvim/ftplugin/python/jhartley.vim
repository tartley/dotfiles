
" auto indent after block keywords:
set smartindent cinwords=class,def,for,if,elif,else,try,except,finally,while

" comment and uncomment lines in visual or block mode
vnoremap <silent> # :s/^/# /<cr>:noh<cr>
vnoremap <silent> <a-3> :s/^# //<cr>:noh<cr>

" generate tags for all Python files in or below current dir
noremap <f12> :silent !pytags<CR>

