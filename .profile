# .profile, run once on login
# (or at start of every (interactive?) shell on OSX)
# environment vars, process limits
# i.e. stuff inherited by child processes

# Prefix to PATH ###############################

addpath() {
    new_entry="$1"
    # If it's a directory or a symlink
    if [[ -d "$new_entry" || -L "$new_entry" ]] ; then
        # Add it only if it isn't already present
        case ":$PATH:" in
          *":$new_entry:"*) :;; # already present
          *) PATH="$new_entry:$PATH";;
        esac
    fi
}

addpath "$HOME/.local/bin"
addpath "$HOME/bin"

if [ $OSTYPE = darwin* ] ; then
    # this already in PATH, but we want it before /usr/bin so things like
    # brew can override builtin binaries
    addpath "/usr/local/bin"

    # utils from homebrew
    addpath "$(brew --prefix coreutils)/libexec/gnubin"
    export MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"

    # PATH for installed pythons
    addpath "/Library/Frameworks/Python.framework/Versions/2.7/bin"
    addpath "/Library/Frameworks/Python.framework/Versions/3.3/bin"
fi

export PATH

# Other env variables ######################

export CDPATH=":$HOME/src/cosmos:$HOME/src:$HOME"

# These completion tuning parameters change the default behavior of
# bash_completion:
# Define to avoid stripping description in --option=description of
# './configure --help'
export COMP_CONFIGURE_HINTS=1
# Define to avoid flattening internal contents of tar files
export COMP_TAR_INTERNAL_PATHS=1

export CPPFLAGS="-I/usr/local/include"

export EDITOR=ni

export EZA_COLORS="reset:ur=38;5;244:uw=38;5;244:ux=38;5;244:ue=38;5;244:gr=38;5;240:gw=38;5;240:gx=38;5;240:tr=38;5;244:tw=38;5;244:tx=38;5;244:xa=93:nb=38;5;23:ub=38;5;23:nk=38;5;66:uk=38;5;66:nm=38;5;109:um=38;5;109:ng=38;5;152:ug=38;5;152:nt=38;5;195:ut=38;5;195:uu=38;5;244:un=0:uR=97:gu=38;5;244:gn=0:gR=97:da=38;5;109:gm=93:fi=38;5;250:tm=38;5;240:*.py[co]=38;5;240"

export GREP_COLORS="ms=1;33:fn=32:ln=1;32:se=0;37"

export HISTSIZE=20000 # bash history will save this many commands
export HISTFILESIZE=${HISTSIZE} # bash will remember this many commands
export HISTCONTROL=ignoreboth:erasedups # ignore & erase duplicate commands
export HISTIGNORE="&:bg:fg:exit:ls:ll" # Ignore some commands
export HISTTIMEFORMAT="%F %T " # Format used in output of history command
# The history file itself always uses seconds-past-epoch format.
# Don't turn HISTTIMEFORMAT off - that breaks readline handling of multi-line
# commands when subsequent sessions read the hist file, since the timestamp
# comments are used to delimit multi-line commands.

export LESS=-R
# prevent man pages from displaying bold text in black
export LESS_TERMCAP_mb=$'\e[6m' # start blink
export LESS_TERMCAP_md=$'\e[01;97m' # start bold (& bright white)
export LESS_TERMCAP_us=$'\e[4;96m' # start underline (& cyan)
export LESS_TERMCAP_ue=$'\e[0m' # stop underline
export LESS_TERMCAP_me=$'\e[0m' # turn off bold, blink, underline
export LESS_TERMCAP_so=$'\e[1;7m' # start standout (reverse)
export LESS_TERMCAP_se=$'\e[0m' # stop standout

# nice modern GNU 'ls'
if ls --color >/dev/null 2>&1; then
    LS_OPTIONS='--color=auto'
else
    # no known color options supported, use trailing filetype chars instead
    LS_OPTIONS='-F'
fi
export LS_OPTIONS

export MAILCHECK

# If 'bat' is installed, use it as a man pager
if command -v bat >/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p | less -R'"
    export MANROFFOPT="-c"
fi

export PG_COLOR=auto

export PIP_CACHE_DIR=$HOME/.cache/pip

if [ $OSTYPE = cygwin ] ; then
    export PYTHONSTARTUP=$HOME\\.pythonstartup.py
else
    # native Linux shell
    export PYTHONSTARTUP=$HOME/.pythonstartup.py
fi

## Source other files ########################################################

# run .bashrc if we're starting a Bash interactive shell, e.g. in a terminal
if [[ $- == *i* ]] && [[ -n "$BASH_VERSION" ]] && [[ -f "$HOME/.bashrc" ]] ; then
  source "$HOME/.bashrc"
fi

