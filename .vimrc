" Jonathan Hartley, tartley@tartley.com

" TODO: I have already have pathogen installed but don't seem to be using
" it very much. Consider whether to stick with pathogen or use a replacement,
" then reinstall all my bits on a clean vim, using the package manager.
" Then check this out, whatever it is:
" https://github.com/tpope/vim-rsi


" 1. Vim settings -------------------------------------------------------------

" Don't be compatible with original vi. Must be first, changes other settings
set nocompatible

" Should come early, affects the behaviour of other things
if has('vim_starting')
    set encoding=utf-8
    scriptencoding utf-8
endif

" Allow backgrounding buffers without writing them
" and remember marks/undo for backgrounded buffers
set hidden

" Make searches case-sensitive only if they contain upper-case characters
set noignorecase
set smartcase
" show search matches as the search pattern is typed
set incsearch

" Don't flick cursor to show matching brackets, they're already highlighted
set noshowmatch

" highlight last search matches
set hlsearch

" search-next wraps back to start of file
set wrapscan

" make tab completion for files/buffers act like bash
set wildmenu
set wildmode=list:longest
" stuff to ignore when autocompleting filenames
set wildignore=*.pyc,*.pyo

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" use 'comma' prefix for user-defined multi-stroke keyboard mappings
let mapleader = ","

" sane text files
set fileformat=unix
set fileformats=unix,dos,mac

" sane editing
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" indenting.
" Autoindent preserves indent from the previous line
set autoindent
" *All* the other smart indent settings and plugins are TOTALLY FUCKED.
" Disable them all
set nocindent
set indentexpr=
" smartindent moves comments to indent zero. fucked.
set nosmartindent

" lastline: don't display truncated last lines as '@' chars
set display+=lastline

" display current mode on the last line (e.g. '-- INSERT --')
set showmode

" display number of selected chars, lines, or size of blocks.
set showcmd

" status line
set statusline=
" Filename, relative to cwd
set statusline+=%f
set statusline+=\ 
" Modified flag
set statusline+=%#lCursor#
set statusline+=%M
set statusline+=%*
set statusline+=\ 
" A nice color
set statusline+=%#directory#
" Warn if file encoding != utf-8
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
" Warn if fileformat != unix
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
" Warn if file contains tab chars
set statusline+=%{TabsPresent()}
" Warn if file contains non-ascii
set statusline+=%{NonAsciiPresent()}
" Regular colors again
set statusline+=%*
" Read-only flag
set statusline+=%r
set statusline+=%*
" Right-align
set statusline+=%=
" Filetype
set statusline+=%{strlen(&ft)?&ft:'none'}
set statusline+=\ 
" Char under the cursor
set statusline+=%3b,0x%02B
set statusline+=\ 
" Cursor column,
set statusline+=%2c,
" Cursor line / lines in file
set statusline+=%l/%L
set laststatus=2

set formatoptions-=t
set formatoptions-=c
set formatoptions+=r
set formatoptions+=o
set formatoptions+=q
set formatoptions-=w
set formatoptions-=a
" formatoptions 'n' stops autoformat from messing up numbered lists.
set formatoptions+=n
" Make autoformat of numbered lists also handle bullets, using asterisks:
set formatlistpat=^\\s*[0-9*]\\+[\\]:.)}\\t\ ]\\s*

" long line wrapping
set nowrap
" wrap at exactly char 80, not at word breaks
set nolinebreak

" Display of wrapped lines
" Implemented using 'let &...' in order to use \u escapes
let &showbreak="\u2026" " start of wrapped lines
" Display of invisible characters
" Implemented using 'let &...' in order to use \u escapes
let &listchars="extends:\ubb,nbsp:\u2423,precedes:\uab,tab:\u25b8-,trail:\ub7"
set list
"
" Preview (visible with 'set list')
" nbsp  
" tab	
" trail 
" turn wrap on to see 'showbreak', turn it off to see extends::::::::::::::::::::and precedes
"
" Some unicode:
" \uab double <
" \ub7 middle dot
" \ubb double >
" \u2014 a long dash of some sort
" \u2026 elipsis
" \u2423 underscore with shoulders
" \u25a1 hollow block
" \u2588 full block
" \u25b8 triangle, filled, pointing right

" show line numbers
set number

" allow cursor keys to go right off end of one line, onto start of next
set whichwrap+=<,>,[,]

" when joining lines, don't insert two spaces after punctuation
set nojoinspaces

" enable automatic yanking to and pasting from the selection
set clipboard+=unnamed

" I don't like folded regions
set nofoldenable

" omit intrusive 'press ENTER' (etc) status line messages
set shortmess=atTWI

set history=999

set shell=/bin/bash

" make commands invoked by grep go via an interactive shell
" Without this, the bash alias 'grp' in 'grpprg' is not expanded
set shellcmdflag=-ci

" 'grep' command should use 'grp' bash function, a wrapper for system grep
" which adds some common flags, like --exclude-dir=\.git.
" We add '-n' into that mix, so that output is parsable by vim quickfix window.
set grepprg=grpy\ -n\ $*\ /dev/null

" allow use of mouse pretty much everywhere
set mouse=a
if !has('nvim')
    set ttymouse=xterm2
endif

" mouse and keyboard selections enter visual mode, not select mode
set selectmode=

" right mouse button extends selection instead of context menu
set mousemodel=extend

" faster mousewheel scrolling
noremap <ScrollWheelUp> 10<C-y>
noremap <ScrollWheelDown> 10<C-e>

" Keep more context when scrolling off the end of a buffer
set scrolloff=3

" shift plus movement keys changes selection
set keymodel=startsel,stopsel

" allow cursor to be positioned one char past end of line
" and apply operations to all of selection including last char
set selection=exclusive

" prevent security exploits. I never used modelines anyway.
set modelines=0

" places to look for tags files:
set tags=./tags,tags
" recursively search cwd's parent dirs for tags file
set tags+=tags;/

" indicate a fast terminal - more redraw chars sent for smoother redraw
set ttyfast
" don't redraw while running macros
set nolazyredraw

" show vim in window title
set notitle

" turn on syntax highlighting
syntax on
set t_Co=256
set background=dark

" files to hide in directory listings
let g:netrw_list_hide='\.py[oc]$,\.svn/$,\.git/$,\.hg/$'

" Saved sessions should include gui or terminal window sizes & position.
set sessionoptions+=resize,winpos

" Make backups in a single central place.
if !isdirectory($HOME . "/.vim-tmp/backup")
    call mkdir($HOME . "/.vim-tmp/backup", "p")
endif
set backupdir=~/.vim-tmp/backup/
set backup

if !isdirectory($HOME . "/.vim-tmp/swap")
    call mkdir($HOME . "/.vim-tmp/swap", "p")
endif
set directory=~/.vim-tmp/swap/

" persist undo info, so you can undo even after closing and re-opening a file
if version >= 703
    if !isdirectory($HOME . "/.vim-tmp/undo")
        call mkdir($HOME . "/.vim-tmp/undo", "p")
    endif
    set undodir=~/.vim-tmp/undo/
    set undofile
endif


" 2. Key mappings -------------------------------------------------------------

" ctl-l doesn't just refresh window, but also hides search highlights
nnoremap <silent> <C-l> :nohlsearch<cr><C-l>
inoremap <silent> <C-l> :nohlsearch<cr><C-l>

" stop autoindent from unindenting lines typed starting with '#'
inoremap # X<backspace>#

" toggle wrapping long lines
noremap <leader>w :set wrap!<cr>

" toggle visibility of invisible characters
nmap <silent> <leader>s :set list!<cr>

" strip trailing whitespace
nmap <silent> <leader>S ms:%s/\s\+$//<cr>`s

" search for non-ascii characters
nmap <leader>N /[^\x00-\x7F]<cr>

" toggle display of line numbers
function! ToggleNumber()
    if &number ==# 0
        set number
        set columns+=4
    else
        set nonumber
        set columns-=4
    endif
endfunction

nmap <leader>n :call ToggleNumber()<cr>

" toggle between last two buffers
noremap <leader><leader> <C-^>

" make Y yank to end of line (consistent with C and D)
noremap Y y$

" make Q do somethign useful - format para
noremap Q gq}

" search for visual selection if one exists, otherwise for word under cursor
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" Silent grep and then show results in quickfix
function! Grp(args)
    " grp is my own Bash wrapper for system grep
    set grepprg=grp\ -n\ $*\ /dev/null
    execute "silent grep " . a:args
    botright copen
endfunction

" Grp across .py files only
function! Grpy(args)
    " grpy is my own Bash wrapper for system grep
    set grepprg=grpy\ -n\ $*\ /dev/null
    execute "silent grep " . a:args
    botright copen
endfunction

command! -nargs=* -complete=file Grp call Grp(<q-args>)
command! -nargs=* -complete=file Grpy call Grpy(<q-args>)

" Grp all files for the word under the cursor (& case insensitive version)
noremap <leader>g :Grp -w '<C-r><C-w>' .<cr>
noremap <leader>G :Grp -wi '<C-r><C-w>' .<cr>
" Grp .py files
noremap <leader>p :Grpy -w '<C-r><C-w>' .<cr>
noremap <leader>P :Grpy -wi '<C-r><C-w>' .<cr>

" move up/down by visible lines on long wrapped lines of text
nnoremap k gk
nnoremap j gj
vnoremap <a-4> g$
nnoremap <a-4> g$
vnoremap <a-0> g^
nnoremap <a-0> g^
nnoremap <a-6> g^
vnoremap <a-6> g^

" start typing commands without needing shift
nnoremap ; :

" Windows-like keys for cut/copy/paste
vnoremap <C-x> "+x
vnoremap <C-c> "+y
noremap <C-v> "+gP
imap <C-v> <esc>"+gpa
vmap <C-v> "-cx<Esc>\\paste\\"_x
cnoremap <C-v> <C-r>+

" save file
noremap <silent> <C-s> :update<cr>
inoremap <silent> <C-s> <C-o>:update<cr>

" navigating quickfix
noremap <silent> <f3> :cnext<cr>
noremap <silent> <S-f3> :cprevious<cr>

" cd to current file
noremap <m-j> :lcd %:p:h<cr>:pwd<cr>
map <m-down> <a-j>
map! <m-j> <esc><a-j>
map! <m-down> <a-j>
" cd ..
noremap <m-k> :lcd ..<cr>:pwd<cr>
map <m-up> <a-k>
map! <m-k> <esc><a-k>
map! <m-up> <a-k>

" go to prev buffer
noremap <silent> <a-q> :hide bp<cr>
map! <silent> <a-q> <esc><C-tab>
" go to next buffer
noremap <silent> <a-w> :hide bn<cr>
map! <silent> <a-w> <esc><C-S-tab>
" close buffer
noremap <a-backspace> :Bclose<cr>
noremap <a-s-backspace> :Bclose!<cr>

" close window
noremap <a-backspace> <C-w>c
map! <a-backspace> <esc><C-backspace>
" close all other windows
noremap <a-o> <C-w>o
" navigating between windows
noremap <a-left> <C-w>h
noremap <a-right> <C-w>l
noremap <a-up> <C-w>k
noremap <a-down> <C-w>j
noremap! <a-left> <esc><C-w>h
noremap! <a-right> <esc><C-w>l
noremap! <a-up> <esc><C-w>k
noremap! <a-down> <esc><C-w>j
if has('nvim')
    tnoremap <C-left> <C-\><C-n><C-w>h
    tnoremap <C-right> <C-\><C-n><C-w>l
    tnoremap <C-up> <C-\><C-n><C-w>k
    tnoremap <C-down> <C-\><C-n><C-w>j
endif

" Readline style keys for command mode
" move to start of line (or vim C-b)
cnoremap <C-a> <Home>
" move to end of line (or vim C-e)
cnoremap <C-e> <End>
" Things that just work:
" - move back one word (vim C-Left or S-Left)
" - move forward one word (C-Right or S-Right)
" - delete prev word (vim C-w)
" - delete to start of line (vim C-u)
" - Things that don't work:
" - delete to end of line (Bash C-k) is not easy to map to vim keys

" tabs
" Skip C-w as close tab, because it is also delete word
noremap <C-t> :tabnew<CR>
noremap <C-y> :tabclose<CR>
noremap <C-PageUp> :tabprev<CR>
noremap <C-PageDown> :tabnext<CR>

" make cursor keys work during visual block selection
vnoremap <left> h
vnoremap <right> l
vnoremap <up> k
vnoremap <down> j

" toggle autoformatting (my own personal group of settings for editing plain
" text files as opposed to code)
noremap <a-t> :py3 toggle_autoformat()<cr>

" disable annoying help on f1
noremap <silent> <f1> <esc>
map! <silent> <f1> <esc>

" generate tags for all (Python) files in or below current dir
" Mac & Linux
noremap <leader>T :silent !pytags<cr>:FufRenewCache<cr>
" Windows
" noremap <leader>T :!start /min ctags -R --languages=python .<cr>:FufRenewCache<cr>

" go to defn of tag under the cursor
fun! MatchCaseTag()
  let ic = &ic
  set noic
  try
    exe 'tjump ' . expand('<cword>')
  finally
    let &ic = ic
  endtry
endfun

nnoremap <silent> <C-]> :call MatchCaseTag()<CR>

" shortcuts to save and load session
noremap <leader>L :mksession! ./.vimsession<cr>
noremap <leader>l :source ./.vimsession<cr>


" 3. Autocommands -------------------------------------------------------------

if has("autocmd")

    " enables filetype detection
    filetype on
    " enables filetype specific plugins
    filetype plugin on
    " do language-dependent indenting.
    filetype indent off

    " For all text files set 'textwidth' to 80 characters.
    autocmd FileType text setlocal textwidth=80

    " make syntax highlighting work correctly on long files
    autocmd BufEnter * :syntax sync fromstart

    " When editing a file, always jump to the last known cursor position.
    autocmd BufReadPost * call SetLastCursorPosition()
    function! SetLastCursorPosition()
      " Don't do it when the position is invalid or when inside an event
      " handler (happens when dropping a file on gvim).
      if line("'\"") > 0 && line("'\"") <= line("$")
        exe "normal g`\""
        normal! zz
      endif
    endfunction

    " syntax highlighting for unusual file extensions
    autocmd BufNewFile,BufRead *.hql set filetype=sql
    autocmd BufNewFile,BufRead *.md set filetype=markdown
    autocmd BufNewFile,BufRead *.sqli set filetype=sql

    " Don't clear the X clipboard on exit
    autocmd VimLeave * call system("xsel -ib", getreg('+'))

    " When vimrc is edited, reload it
    autocmd! bufwritepost .vimrc source ~/.vimrc

    " Return warning string if tab chars (	) in file, else ''
    function! TabsPresent()
        if !exists("b:tabs_present")
            if search('\t', 'nw') != 0
                let b:tabs_present = '[tabs]'
            else
                let b:tabs_present = ''
            endif
        endif
        return b:tabs_present
    endfunction
    " Recalculate after writing and when idle
    autocmd bufwritepost,cursorhold * unlet! b:tabs_present

    " Return warning string if non ascii chars (£) are present in the file, else ''
    function! NonAsciiPresent()
        if !exists("b:nonascii_present")
            if search('[^\x00-\x7F]', 'nw') != 0
                let b:nonascii_present = '[nonascii]'
            else
                let b:nonascii_present = ''
            endif
        endif
        return b:nonascii_present
    endfunction
    " Recalculate after writing and when idle
    autocmd bufwritepost,cursorhold * unlet! b:nonascii_present

    " Disabled because annoying
    " On changing window,
    "   Make all windows equally wide
    "   Make current window 84 wide (possibly shrinking others)
    "   Scroll current window to make left ten times to make line start visible
    "       (to compensate for possibly having been scrolled right to keep
    "       cursor in view when this window was previously shrunk.)
    " autocmd WinEnter * if &number ==# 1 | :vertical resize 84 | else | :vertical resize 80 | endif
    " autocmd WinEnter * normal 10zH

endif " has("autocmd")


" 4. Plugin config ------------------------------------------------------------

" Solarised color scheme
let g:solarized_termcolors=256
let g:solarized_termtrans=0    "default value is 1
let g:solarized_contrast="high"
let g:solarized_visibility="high"

" fuzzyfind plugin
let s:extension = '\.bak|\.dll|\.exe|\.o|\.pyc|\.pyo|\.swp|\.swo'
let s:dirname = '__pycache__|\.bzr|\.git|\.hg|\.svn|.+\.egg-info|build|dist|node_modules|tags|venv|vms'
let s:slash = '[/\\]'
let s:startname = '(^|'.s:slash.')'
let s:endname = '($|'.s:slash.')'
let g:fuf_file_exclude = '\v'.'('.s:startname.'('.s:dirname.')'.s:endname.')|(('.s:extension.')$)'
let g:fuf_dir_exclude = '\v'.s:startname.'('.s:dirname.')'.s:endname
let g:fuf_enumeratingLimit = 60
let g:fuf_timeFormat = '    %Y%m%d %H:%M:%S'
nnoremap <leader>f :FufFile **/<cr>
nnoremap <leader>b :FufBuffer<cr>
nnoremap <leader>t :FufTag<cr>


" 5. Disabled -----------------------------------------------------------------

" Really slow on startup in nvim
" glsl filetypes
"function! SetGLSLFileType()
"  execute ':set filetype=glsl330'
"  for item in getline(1,10)
"    if item =~ "#version 400"
"      execute ':set filetype=glsl400'
"      break
"    endif
"  endfor
"endfunction
"command! SetGLSLFileType call SetGLSLFileType()
"au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl SetGLSLFileType

" Does not work out of the box in nvim
"" use pathogen to manage plugins
"" (although some are still installed directly to the base directories)
"execute pathogen#infect()

" Doesn't seem to work out of the box in nvim
" Syntastic
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" let g:syntastic_aggregate_errors = 1
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_enable_signs = 1
" let g:syntastic_python_checkers = ['pylint']
" let g:syntastic_python_python_exec = 'python3.4'
" 
" let g:syntastic_mode_map = {'mode': 'passive', 'active_filetypes': [], 'passive_filetypes': [] }
" 
" noremap <leader>c :SyntasticCheck<cr> :SyntasticToggleMode<cr>
" noremap <leader>C :SyntasticToggleMode<cr>
" 
" nnoremap <a-.> :lnext<cr>
" nnoremap <a-,> :lprev<cr>

