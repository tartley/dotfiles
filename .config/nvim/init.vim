" Neovim config
" Jonathan Hartley, tartley@tartley.com

" 1. Plugins ------------------------------------------------------------------
" Managed by https://github.com/junegunn/vim-plug

call plug#begin('~/.local/share/nvim/plugged')

" run update in existing window, instead of a vertical split
let g:plug_window="enew"

" fuzzy find files, buffers, tags, etc
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" fuzzy find vim plugin
Plug 'junegunn/fzf.vim'

" solarized colors
Plug 'lifepillar/vim-solarized8'

" Deleting a buffer without closing the window
Plug 'rbgrouleff/bclose.vim'

" Language Server Protocol config
Plug 'neovim/nvim-lspconfig'

" <Leader>l - toggle location window
" <Leader>q - toggle quickfix window
Plug 'milkypostman/vim-togglelist'
let g:toggle_list_copen_command="botright copen"

let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
" turn off annoying and useless preview window during autocomplete
set completeopt-=preview
" make manual-complete (C-n) behave same as deoplete auto-complete
function! s:check_back_space() abort "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}
inoremap <expr><C-n> pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ deoplete#mappings#manual_complete()

Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_no_default_key_mappings = 1
let g_vim_markdown_fenced_languages = ['bash=sh', 'js=javascript', 'py=python', 'viml=vim']
" Highlight front matter (useful for Hugo posts).
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_frontmatter = 1
" Format strike-through text (wrapped in `~~`).
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_toc_autofit = 1
" Consider this to stop highlight emphasis from spanning lines
" let g:vim_markdown_emphasis_multiline = 0
" 'ge' on links to other files will then search for the url anchor
let g:vim_markdown_follow_anchor = 1
" 'ge' on [text](path) will open 'path.md' instead of 'path'.
let g:vim_markdown_no_extensions_in_markdown = 1
" (where 'ge' is like 'gx' (open link in browser), but opens in editor (Vim).)
" Enable ':TableFormat' command even on borderless tables:
let g:vim_markdown_borderless_table = 1

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

call plug#end()

" 2. Neovim settings ----------------------------------------------------------

" Should come early, affects the behaviour of other things
if has('vim_starting')
    set encoding=utf-8
    scriptencoding utf-8
endif

" Define comma as the non-default <leader> key,
let g:mapleader = ","

let g:python3_host_prog="$HOME/.virtualenvs/neovim/bin/python3"

" Yank/delete should populate the '*' register, ie. the X 'primary' selection
" (pasted in NVim using 'p' or 'P')
" (pasted elsewhere using Shift-Insert or middle-mouse button)
set clipboard=unnamed

" Allow backgrounding buffers without writing them
" and remember marks/undo for backgrounded buffers
set hidden

" Make searches case-sensitive only if they contain upper-case characters
set ignorecase
set smartcase
" show search matches and resplace results as the search pattern is typed
set incsearch
" Also show replace results in a temporary split. Useful if they are
" too separated to be simultaneously visible in the buffer.
set inccommand=split

" Don't flick cursor to show matching brackets, they're already highlighted
set noshowmatch

" highlight last search matches
set hlsearch

" search-next wraps back to start of file
set nowrapscan

" make tab completion for files/buffers act like bash
set wildmenu
set wildmode=full
" stuff to ignore when autocompleting filenames
set wildignore=*.pyc,*.pyo

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" sane text files
set fileformat=unix
set fileformats=unix,dos,mac

" Don't uniliaterally add a final eol character
" I don't like this but John@Lambda does, so :shrug:
set nofixeol

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
" stop autoindent from unindenting lines typed starting with '#'
inoremap # X<backspace>#

" lastline: don't display truncated last lines as '@' chars
set display+=lastline

" display current mode on the last line (e.g. '-- INSERT --')
set showmode

" display number of selected chars, lines, or size of blocks.
set showcmd

" -- status line ----
set statusline=
" Filename, relative to cwd
set statusline+=%f
set statusline+=\ 
" Modified flag
set statusline+=%#lCursor#
set statusline+=%M
set statusline+=%*\ 
set statusline+=\ 
" A nice color
set statusline+=%#directory#
" Warn if file encoding != utf-8
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
" Warn if fileformat != unix
set statusline+=%{&ff!='unix'?'['.&ff.']':''}

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
" Warn if file contains tab chars
set statusline+=%{TabsPresent()}

" Return warning string if nonascii chars (e.g. £) are present, else ''
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
set statusline+=%{strlen(&ft)?&ft:'no\ filetype'}
set statusline+=\ 
" Char under the cursor
set statusline+=%3b,0x%02B
set statusline+=\ 
" Cursor column,
set statusline+=%2c,
" Cursor line / lines in file
set statusline+=%l/%L
set laststatus=2
" -- end status line ----

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

" -- long line wrapping ----

set wrap

function ToggleWrapWords()
    if &linebreak == 0
        " wrap at word breaks
        setlocal linebreak
        setlocal nolist
        let &showbreak=""
    else
        " wrap at exactly window width
        setlocal nolinebreak
        setlocal list
        let &showbreak="…"
    endif
    echo "wrap words" (&linebreak ? "on" : "off")
endfunction

set linebreak
silent call ToggleWrapWords()

" Map key to toggle option and display its value
function MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  " Why did I ever think the following was a good idea? Delete it soon...
  " exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
command -nargs=+ MapToggle call MapToggle(<f-args>)

MapToggle <Leader>w wrap
noremap <Leader>W :call ToggleWrapWords()<CR>

" wrapped lines start with same indent as start of line
set breakindent

" Display of invisible characters
" Implemented using 'let &...' in order to use \u escapes
let &listchars="extends:\ubb,nbsp:\u2423,precedes:\uab,tab:\u25b8-,trail:\ub7"
set list
MapToggle <Leader>v list

"
" Preview (visible with 'set list')
" nbsp  
" tab	
" trail 
" turn wrap on to see 'showbreak', turn it off to see extends::::::::::::::::::::and precedes (scroll right)
"
" Some unicode:
"   Use 'let &...' instead of 'set ...' to use \u escapes
"   Or use C-v (which I have mapped to C-q) u XXXX to type chars literally)
" \uab double <
" \ub7 middle dot
" \ubb double >
" \u2014 a long dash of some sort
" \u2026 elipsis (or C-q u 2026) …
" \u2423 underscore with shoulders
" \u25a1 hollow block
" \u2588 full block
" \u25b8 triangle, filled, pointing right

" allow cursor keys to go right off end of one line, onto start of next
set whichwrap+=<,>,[,]

" when joining lines, don't insert two spaces after punctuation
set nojoinspaces

" I don't like folded regions
set nofoldenable

" omit intrusive 'press ENTER' (etc) status line messages
set shortmess=atTWI

set history=999

set shell=/bin/bash

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

" Minimum lines to keep visible above and below the cursor.
" So, for example, we start scrolling down when cursor tries
" to go closer to bottom of window than this.
set scrolloff=3

" shift plus movement keys changes selection
set keymodel=startsel,stopsel

" allow cursor to be positioned one char past end of line
" and apply operations to all of selection including last char
set selection=exclusive

" prevent security exploits. I never used modelines anyway.
set modelines=0

" places to look for tags files:
" (I hope this means just in the window's cwd.)
" (Help suggests that ./tags means in the dir of the file.)
set tags=tags

" indicate a fast terminal - more redraw chars sent for smoother redraw
if !has("nvim")
    set ttyfast
endif
" don't redraw while running macros
set nolazyredraw

" show vim in window title
set title

set background=dark
colorscheme solarized8
highlight Whitespace guifg=#08242C " make visible whitespace less intrusive

set termguicolors

set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175

" files to hide in directory listings
let g:netrw_list_hide='\.py[oc]$,\.svn/$,\.git/$,\.hg/$'

" Saved sessions should include gui or terminal window sizes & position.
set sessionoptions+=resize,winpos

" Make backups in a single central place.
set backupdir-=.
if !isdirectory(&backupdir)
    call mkdir(&backupdir, "p")
endif

" persist undo info, so you can undo even after closing and re-opening a file
" stored in ~/.local/share/nvim/undo/*
set undofile


" 3. Key mappings -------------------------------------------------------------

" Reload this config file on saving edits
nmap <Leader>c :e ~/.config/nvim/init.vim<CR>

" -- fzf plugin ----
" see additional fzf config in .bashrc, setting env var FZF_DEFAULT_OPTS
let g:fzf_buffers_jump = 1
let g:fzf_layout = { 'window': 'enew' }
let g:fzf_preview_window = 'up:50%'
let g:fzf_preview = "bat --color=always --style=changes --line-range=:36 {}"
" I don't like that fzf defines W as fuzzy find windows,
" Define it to be what I actually mean when I accidentally type it.
command W :w

" Switch to open buffer
noremap <Leader>b :Buffers<CR>
" Jump to tag
noremap <Leader>t :Tags<CR>
" fuzzy find tag under cursor
noremap <Leader>T :call fzf#vim#tags(expand('<cword>'))<CR>

command MyMarks :marks ABCDEFGHIJKLMNOPQRSTUVWXabcdefghijklmnopqrstuvwxyz
noremap ,m :MyMarks<CR>:normal '

" Custom fzf commands that don't seem to respect the above settings,
" so we have to duplicate things like the preview command.

" Open commonly editable files (eg. not .pyc)
" find-editable-files is in ~/bin
" It defines what files to hide from the list
noremap <silent> <Leader>f :call fzf#run({
\   'source': 'find-editable-files',
\   'sink': 'e',
\   'options': '
\       --preview-window="up:50%"
\       --preview="bat --color=always --style=changes --line-range=:36 {}"
\   '
\})<CR>

" Open any file
noremap <silent> <Leader>F :call fzf#run({
\   'source': 'find . -type f -print 2>/dev/null',
\   'sink': 'e',
\   'options': '
\       --preview-window="up:50%"
\       --preview="bat --color=always --style=changes --line-range=:36 {}"
\   '
\})<CR>

" faster mouscwheel scrolling
noremap <ScrollWheelUp> 10<C-y>
noremap <ScrollWheelDown> 10<C-e>

" toggle highlight of search results
MapToggle <Leader>h hlsearch

" toggle visibility of invisible characters
MapToggle <Leader>s list

" strip trailing whitespace
nmap <silent> <Leader>S ms:%s/\s\+$//<CR>`s

" search for non-ascii characters
nmap <Leader>N /[^\x00-\x7F]<CR>

" show line numbers
set number
MapToggle <Leader>n number

" set window size
set textwidth=100
set colorcolumn=+1
if !exists("g:numColumns")
    let g:numColumns=1
endif

function! SetWindowWidth()
    " Beware, calling this on startup seems to set the variable, but not change the actual window
    " size. The two being out of sync causes screen refresh glitches. Subsequentially setting
    " columns to the same value again has no effect. Only setting it to a different value rescues
    " the session.
    let &columns=g:numColumns*&textwidth + g:numColumns*&numberwidth*&number + (g:numColumns - 1)
    normal <Ctrl-w>=
endfunction

noremap <Leader>8 :set textwidth=80<CR>:call SetWindowWidth()<CR>
noremap <Leader>9 :set textwidth=90<CR>:call SetWindowWidth()<CR>
noremap <Leader>0 :set textwidth=100<CR>:call SetWindowWidth()<CR>

" single column
noremap <silent> <Leader><f1> :only!<CR>:let g:numColumns=1<CR>:call SetWindowWidth()<CR>
" double column
noremap <silent> <Leader><f2> :only!<CR>:let g:numColumns=2<CR>:call SetWindowWidth()<CR>:vsplit<CR>
" TRIPLE COLUMN MADNESS!!!
noremap <silent> <Leader><f3> :only!<CR>:let g:numColumns=3<CR>:call SetWindowWidth()<CR>:vsplit<CR>:vsplit<CR>

" set equalalways

" toggle between last two buffers
noremap <Leader><Leader> <C-^>

" make Y yank to end of line (consistent with C and D)
noremap Y y$

" delete without overwriting the yank register. eg. Dd to delete line.
noremap D "_d

" Format para
noremap Q gq}
" Format whole document (then restore cursor to same line number :-/)
noremap <leader>Q mz1GgqG'z

" search for visual selection if one exists, otherwise for word under cursor
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" Silent grp and then show results in quickfix
function! Grp(args)
    " grp is my own Bash wrapper for system grep
    set grepprg=grp\ -n\ $*
    execute "silent! grep! " . a:args
    botright copen
endfunction

" Silent grrp and then show results in quickfix
" Grp for Lambda.Rackit, excludes 'docs' dir.
function! Grrp(args)
    " grp is my own Bash wrapper for system grep
    set grepprg=grrp\ -n\ $*
    execute "silent! grep! " . a:args
    botright copen
endfunction

" Grp across .py files only
function! Grpy(args)
    " grpy is my own Bash wrapper for system grep
    set grepprg=grpy\ -n\ $*
    execute "silent! grep! " . a:args
    botright copen
endfunction

command! -nargs=* -complete=file Grp call Grp(<q-args>)
command! -nargs=* -complete=file Grrp call Grrp(<q-args>)
command! -nargs=* -complete=file Grpy call Grpy(<q-args>)

" Grp all files for the word under the cursor (& case insensitive version)
noremap <Leader>g :silent Grp -w '<C-r><C-w>' .<CR>
noremap <Leader>G :silent Grp -wi '<C-r><C-w>' .<CR>
" Grp .py files (and upper case to include tests)
noremap <Leader>p :silent Grpy -w --exclude-dir=tests '<C-r><C-w>' .<CR>
noremap <Leader>P :silent Grpy -w '<C-r><C-w>' .<CR>

" Arbitrary command in the quickfix
function! Qf(args)
    execute "cexpr system('" . a:args . "')"
    botright copen
endfunction
command! -nargs=* -complete=file Qf call Qf(<q-args>)

" JSON encode a Python data structure,
noremap <Leader>j :!py2json<CR>
" and vice-versa.
noremap <Leader>J :!json2py<CR>

function! EnBlackenFile()
    let pos = getcurpos()
    " TODO doesn't work in container if black installed in host
    " TODO also would be good to use env/bin/black if it exists
    1,$!black -q --line-length=&textwidth -
    call setpos('.', pos)
endfunction

" Black(Python) format the whole file
nnoremap <leader>k :call EnBlackenFile()<CR>
" Black(Python) format the visual selection
" File writing shenanigans is to display the message from Black on failure,
" without putting it into the buffer's visual selection.
xnoremap <Leader>k !enblacken $codewidth 2>/tmp/vim.err <CR>:echo join(readfile("/tmp/vim.err"), "\n")<CR>

" TODO: Can we combine PyDictToggleRange functions?
" TODO: genericize so enblacken can use it too
" TODO: (harder) When invoked without a selection, automatically figure out the range
"       containing the dict? If we're inside nested dicts, do we operate on the
"       largest or the smallest, or give the user some way to choose? Talk about
"       gold-plating!
" TODO: Consider integrating this answer to my question about how to handle
"       errors from external commands: https://superuser.com/questions/1779615
"       See FILTER_ERROR below, which might already do this?
function! s:PyDictToggleRange() range
    silent '<,'>!py-dict-toggle 2>/tmp/vim.err
    if v:shell_error
        echo join(readfile("/tmp/vim.err"), "\n")
    endif
endfunction

function! s:PyDictToggleLine()
    silent .!py-dict-toggle 2>/tmp/vim.err
    if v:shell_error
        echo join(readfile("/tmp/vim.err"), "\n")
    endif
endfunction


" move up/down by visible lines on long wrapped lines of text
nnoremap k gk
nnoremap j gj

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
noremap <silent> <C-s> :silent wall<CR>
inoremap <silent> <C-s> <Esc>:silent wall<CR>

" navigating quickfix
noremap <silent> <f3> :cnext<CR>
noremap <silent> <S-f3> :cprevious<CR>
" S-f3 doesn't seem to work in terminals
nmap <silent> <f2> <S-f3>

" cd to current file
noremap <M-j> :lcd %:p:h<CR>:pwd<CR>
map <M-down> <A-j>
map! <M-j> <esc><A-j>
map! <M-down> <A-j>
" cd ..
noremap <M-k> :lcd ..<CR>:pwd<CR>
map <M-up> <A-k>
map! <M-k> <esc><A-k>
map! <M-up> <A-k>

" go to next/prev buffer
noremap <leader>; :silent hide bp<CR>
noremap <leader>' :silent hide bn<CR>

" close buffer
noremap <leader><backspace> :Bclose<CR>
noremap <leader><delete> :Bclose!<CR>

" navigating between windows
noremap <C-left> <C-w>h
noremap <C-right> <C-w>l
noremap <C-up> <C-w>k
noremap <C-down> <C-w>j
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l
noremap <C-k> <C-w>k
noremap <C-j> <C-w>j
inoremap <C-left> <Esc><C-w>h
inoremap <C-right> <Esc><C-w>l
inoremap <C-up> <Esc><C-w>k
inoremap <C-down> <Esc><C-w>j
inoremap <C-h> <Esc><C-w>h
inoremap <C-l> <Esc><C-w>l
inoremap <C-k> <Esc><C-w>k
inoremap <C-j> <Esc><C-w>j
if has('nvim')
    " while in a terminal
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
" Things that don't work:
" - delete to end of line (Bash C-k) is not easy to map to vim keys

" tabs
" Commented out as I never use tabs, and hitting 'ctrl-t' here (instead of in
" browser) would open unwanted tabs. I'd rather it did nothing.
" noremap <C-t> :tabnew<CR>
" noremap <C-y> :tabclose<CR>
" Skip C-w as close tab, because it is already used as start-window-command
" Built in: C-PageUp/Down goes to next/prev tab.

" -- visual selection ----
" prevent cursors, etc, from exiting visual selection mode
vnoremap <left> h
vnoremap <right> l
vnoremap <up> k
vnoremap <down> j
vnoremap <home> ^
vnoremap <end> $

" -- toggle autoformatting ----
" My group of settings for editing plain text files as opposed to code.

let g:autoformat = 0

function! ToggleAutoformat()
    if g:autoformat == 0
        " [a]utomatically reformat edited paragraphs
        setlocal formatoptions+=a
        " break lines here as they are typed, at the preceding word end
        " Commented because surely we should use the existing value
        " setlocal textwidth=80
        " turn on spellcheck
        setlocal spell spelllang=en_us
        " turn off number gutter
        setlocal nonumber " doesn't work?
        let g:autoformat = 1
    else
        setlocal formatoptions-=a
        setlocal nospell
        setlocal number
        let g:autoformat = 0
    endif
    echo "autoformat" (g:autoformat ? "on" : "off")
endfunction

noremap <Leader>u :call ToggleAutoformat()<CR>

" -- end toggle autoformatting

" disable annoying help on f1
noremap <silent> <f1> <esc>
map! <silent> <f1> <esc>

" generate tags for all (Python) files in or below current dir
" Mac & Linux
noremap <f12> :silent !pytags<CR>
" Windows
" Commented out: because I hardly ever use it.
" noremap <Leader>T :!start /min ctags -R --languages=python .<CR>:FufRenewCache<CR>

" Go to defn of tag under the cursor.
" If more than one definition, show a menu instead of jumping directly.
" Turn off case-insensitive matches while we do this.
fun! TagJumpMatchCase()
  let ic = &ic
  set noic
  try
    exe 'tjump ' . expand('<cword>')
  finally
    let &ic = ic
  endtry
endfun
nnoremap <silent> <C-]> :call TagJumpMatchCase()<CR>

" 4. Autocommands --------------------------------------------------------------

if has("autocmd") && !exists("autocommands_loaded")

    let autocommands_loaded = 1

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

    " When vimrc is edited, reload it
    autocmd! bufwritepost init.vim source ~/.config/nvim/init.vim

    " compensate for neovim bug failing to ask user to reload files which
    " have changed on disk:
    " https://github.com/neovim/neovim/issues/2127
    autocmd BufEnter,FocusGained * checktime

    " highlight current line only in the current window
    augroup CursorLine
      au!
      au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
      au WinLeave * setlocal nocursorline
    augroup END

    function! SetMinWidth()
        set ead=hor ea noea
        " replace this abomination with the expression we use in <leader><f1> which
        " reads the number margin's width directly.
        let &winwidth = float2nr(log10(line("$"))) + 82
    endfunction

    " When moving between windows of less than 80 chars width,
    " make the one the cursor occupies =80, splitting remaining space
    " between the rest.
    " Commented out because it's a bit unstable when all are =80.
    " augroup WinWidth
    "     autocmd!
    "     autocmd VimEnter,WinEnter,BufWinEnter * call SetMinWidth()
    " augroup END

    " Remove Bclose plugin mapping that clashes with my fzf "<leader>b"
    autocmd VimEnter * nunmap <Leader>bd

    " Python
    autocmd FileType python set expandtab | set list | set shiftwidth=4 | set tabstop=4

    " Go
    autocmd! FileType go set noexpandtab | set nolist | set shiftwidth=4 | set tabstop=4

    " html
    autocmd! FileType html set noexpandtab | set list | set shiftwidth=2 | set tabstop=2

    " yaml
    autocmd! FileType yaml set expandtab | set list | set shiftwidth=2 | set tabstop=2

    " gitcommit
    autocmd! FileType gitcommit setlocal spell

    " Undo changes if a filter command fails (e.g. Python Black)
    " This prevents a failed filter from mangling (commonly, completely erasing)
    " the buffer's content.
    augroup FILTER_ERROR
        au!
        autocmd ShellFilterPost * if v:shell_error | silent undo | endif
    augroup END

    " Recalculate vars used in statusline after writing and when idle
    autocmd bufwritepost,cursorhold * unlet! b:nonascii_present
    autocmd bufwritepost,cursorhold * unlet! b:tabs_present

endif " has("autocmd")

