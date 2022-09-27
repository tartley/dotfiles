# .profile, run once on login
# (or at start of every (interactive?) shell on OSX)
# environment vars, process limits
# i.e. stuff inherited by child processes

# RHEL runs .profile twice on login.
# Once from GUI login shell. Once from an Xinit script.
# This 'if' prevents a 2nd execution of .profile
echo "$(date) .profile $PROFILE" >> ~/.profile.log
export PROFILE="${PROFILE}1"
# if [ "$PROFILE" != "1" ] ; then
#     # This is 2nd (or greater) time of sourcing .profile.
#     if [ -t 2 ] ; then
#         # Stderr is connected to a terminal.
#         # Presumably user is manually sourcing .profile. Warn them.
#         echo ".profile: skipping. Unset \$PROFILE and try again." >&2
#     fi
#     # Don't execute remainder of script.
#     return 0
# fi

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

addpath "/opt/bin"
addpath "$HOME/bin"
addpath "$HOME/bin/linux"
addpath "$HOME/.local/bin"
addpath "$HOME/.gem/ruby/2.3.0/bin"
addpath "$HOME/.gems/bin"

if [ $OSTYPE = cygwin ] ; then
    addpath ~/bin/cygwin
    addpath ~/docs/bin/cygwin
fi

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

export EDITOR=nis

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
export MAILCHECK
# prevent man pages from displaying bold text in black
export LESS_TERMCAP_mb=$'\e[6m' # start blink
export LESS_TERMCAP_md=$'\e[01;97m' # start bold (& bright white)
export LESS_TERMCAP_us=$'\e[4;96m' # start underline (& cyan)
export LESS_TERMCAP_ue=$'\e[0m' # stop underline
export LESS_TERMCAP_me=$'\e[0m' # turn off bold, blink, underline
export LESS_TERMCAP_so=$'\e[1;7m' # start standout (reverse)
export LESS_TERMCAP_se=$'\e[0m' # stop standout

export GREP_COLORS="ms=1;33:fn=32:ln=1;32:se=0;37"

# nice modern GNU 'ls'
if ls --color >/dev/null 2>&1; then
    LS_OPTIONS='--color=auto'
else
    # no known color options supported, use trailing filetype chars instead
    LS_OPTIONS='-F'
fi
export LS_OPTIONS

if [ $OSTYPE = cygwin ] ; then
    export PYTHONSTARTUP=$HOME\\.pythonstartup.py
else
    # native Linux shell
    export PYTHONSTARTUP=$HOME/.pythonstartup.py
fi

# These completion tuning parameters change the default behavior of
# bash_completion:
# Define to avoid stripping description in --option=description of
# './configure --help'
export COMP_CONFIGURE_HINTS=1
# Define to avoid flattening internal contents of tar files
export COMP_TAR_INTERNAL_PATHS=1

export CPPFLAGS="-I/usr/local/include"

export PG_COLOR=auto

# Ruby Gems dir
export GEM_HOME=$HOME/.gems

# Add RVM to PATH for scripting.
# Make sure this is the last PATH variable change.
addpath "$HOME/.rvm/bin"

## Source other files ########################################################

# run .bashrc if we're starting a Bash interactive shell, e.g. in a terminal
if [[ $- == *i* ]] && [[ -n "$BASH_VERSION" ]] && [[ -f "$HOME/.bashrc" ]] ; then
  source "$HOME/.bashrc"
fi

