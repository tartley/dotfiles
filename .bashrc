# .bashrc, run by every non-login bash
# aliases and transient shell options that are not inherited by child processes

## Shell Options (See man bash) #############################################

# Don't wait for job termination notification
set -o notify

# Don't use ^D to exit
set -o ignoreeof

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# save multi-line commands as a single line in the history.
shopt -s cmdhist
# and use newlines to separate rather than semi-colons
shopt -s lithist

# don't autocomplete if command-line is empty
shopt -s no_empty_cmd_completion


## utility functions for this script

error() (
  IFS=' '
  awk -v msg="$*" 'BEGIN { print "Error: " msg > "/dev/stderr" }'
)

## Interactive shell tweaks ################################################

case $- in

# interactive shell
*i*)

  # PS1 related env-vars (other env vars are in .profile)
  pre='\[\e['
  post='m\]'

  green="${pre}32${post}"
  yellow="${pre}33${post}"
  cyan="${pre}36${post}"
  magenta="${pre}95${post}"
  dim_cyan="${pre}96${post}"
  bright_yellow_inverse="${pre}93;1;7${post}"
  red_inverse="${pre}97;41;01${post}"
  reset="${pre}0${post}"

  pwd="$dim_cyan\w$reset"
  prompt="$bright_yellow_inverse\$$reset"

  if [[ "$USER" =~ ^(jhartley)$ ]]; then
    usercol="${green}"
  else
    usercol="${magenta}"
  fi
  user="${usercol}${USER}${reset}"

  host="${HOSTNAME%%.*}"
  if [[ "$host" =~ ^(delta)$ ]]; then
    hostcol="${green}"
  elif [[ "$host" =~ ^(asus|boris|gazelle|t460)$ ]]; then
    hostcol="${yellow}"
  elif [[ "$host" =~ ^(ambrose)$ ]]; then
    hostcol="${cyan}"
  else
    hostcol="${magenta}"
  fi
  host="${hostcol}${host}${reset}"

  . ~/.ps1_vcs

  # Whenever displaying the prompt, append history to disk
  PROMPT_COMMAND='history -a'
  # To have all terminals sync their history after every command
  # PROMPT_COMMAND='history -a; history -n'

  # if exit value isn't zero, display it with red background, and a bell
  PROMPT_COMMAND='exitval=$?; '$PROMPT_COMMAND
  get_exitval="\$(if [[ \$exitval != 0 ]]; then echo \"${red_inverse} \$exitval ${reset}\"; fi)"
  export PS1="$get_exitval\n${user}@${host} $pwd\$(${dvcs_function})\n$prompt "

  unset pre post green magenta dim_cyan bright_yellow_inverse reset pwd prompt

  # turn off flow control, mapped to ctrl-s, so that we regain use of that key
  # for searching command line history forwards (opposite of ctrl-r)
  stty -ixon

  # Readline and key binds
  if [[ ${SHELLOPTS} =~ (vi|emacs) ]]; then
    # If there are multiple matches for completion,
    # Tab should cycle through them
    bind 'TAB':menu-complete
    # Display a list of the matching files
    bind "set show-all-if-ambiguous on"
    # Perform partial completion on the first Tab press,
    # only start cycling full results on the second Tab press
    bind "set menu-complete-display-prefix on"
  fi

  ;;

esac

# Set dircols if terminal can handle it
if [ "$TERM" != "dumb" ]; then
    eval `dircolors -b $HOME/.dircolors`
fi


## aliases to coreutils #####################################################

# Requires latest gnu coreutils, maybe don't work with Mac's old built-in ones
alias cd-='cd -'
alias cd..='cd ..'
alias cp='cp -i'
alias df='df -h'
alias du='du -h'
alias histread='history -c; history -r'
alias less='less -R' # display raw control characters for colors only

alias ls='LC_COLLATE="C" ls $LS_OPTIONS'
if command -v eza >/dev/null ; then
    alias ll='eza --long --git --no-quotes --color-scale=age'
else
    alias ll='ls -lGh'
fi
alias la='ll -A'

alias mv='mv -i'
alias rm='rm -i'
alias ssh='TERM=xterm-color ssh'
alias timee='/usr/bin/time -f %E'
alias whence='type -a' # like where, but also describes aliases and functions

# My installed tools
# Prefer aliases here over ~/.local/bat symlinks since it forces scripts to use
# the canonical name, rather than my idiosyncratic personal aliases. Also, some
# programs behavior is influenced by the name they are invoked as, e.g.
# cool-retro-term helpfully (but confusingly) generates a whole new config for
# each name it is invoked under.
alias bat=batcat
alias crt=cool-retro-term
alias python=python3
alias py=python3

# if colordiff is installed, use it
if type colordiff &>/dev/null ; then
    alias diff=colordiff
fi


## Functions ##############################################

# Generate n busyloops to keep n CPUs busy.
# See also 'killalljobs'
busyloop() {
  # Usage: busyloop N
  # Where N is number of parallel busy processes to start.
  # I forget why we loop over args rather than just using the first.

  number=1 # Default to creating 1 busyloop process.

  while [ $# -gt 0 ]; do
      case "$1" in
          *) number=$1
      esac
      shift
  done

  # validate args
  re='^[0-9]+$'
  if ! [[ $number =~ $re ]] ; then
     error "Not a number" >&2
     return 1
  fi

  # Start $number busyloops
  for (( job=0 ; job<$number; job++ ));
  do
    while true; do
      :
    done &
  done
}

# See 'bzr functions', below.

# cd into a directory, resolving any symlinks to give the full actual directory name
cdr() {
    if [ -n "$1" ]; then in="$1"; else in="."; fi
    cd $(readlink -e "$in")
}

colout_traceroute() {
    colout '(^ ?\d+)|(\([\d\.]+\))|([\d\.]+ ms)|(!\S+)' white,cyan,yellow,magenta bold,normal,normal,reverse
}

# docker ps
dps() {
    docker container ls --format 'table {{.Names}}\t{{.Image}}\t{{.ID}}\t{{.Status}}' "$@" | colout '(^NAMES .+$)|(.+Up .+)|(.+Exited .+)' white,green,red bold,normal
}

etime() {
    /usr/bin/time -f"%E" "$@"
}

# See 'git functions', below.

# This is good at cleaning up the results of 'busyloop'
killalljobs() {
  # TODO: There is probably a simpler version of this using 'jobs -p' (output just the PID)
  for jid in $(jobs | grep '\[' | cut -d']' -f1 | cut -c2-); do
    kill %$jid
  done
}

# previously known as lxc-ll
lll() {
    lxc list -cns4 "$@" | grep '\w' | tr -d '|' | colout '(^\s+NAME\s.+)|(RUNNING)|(STOPPED)' white,green,red bold,normal
}

nh() {
    nohup "$@" 1>/dev/null 2>&1 &
}

# Run nvim listening for Godot events
# (e.g. Godot can open files in the Nvim session)
ng() {
    nw --listen /tmp/godothost "$@"
}

# Parent of given PID, or else of current shell
ppid() {
    ps -p ${1:-$$} -o ppid=
}

# show man pages rendered using postscript
psman() {
    SLUG=$(echo $@ | tr ' ' '-')
    FNAME="/tmp/man-$SLUG.pdf"
    set -o pipefail
    man -t "$@" | ps2pdf - "$FNAME" && \
        nohup evince "$FNAME" >/dev/null 2>/dev/null
    set +o pipefail
}

# Use 'pytags $(pydirs) .' to tag with all stdlib and venv symbols
pydirs() {
    python -c "import os, sys; print(' '.join(os.path.relpath(d) for d in sys.path if d))"
}

pytree() {
    tree -AC -I '*.pyc|__pycache__|htmlcov' "$@"
}

pywait() {
    find -name 'env' -prune -o -name '*.py' -print | entr "$@"
}

# call given command every second until a key is pressed
repeat_until_key() {
    command="$@"
    while true; do
        $command
        read -s -n1 -t1 && break
    done
}

sd() {
    sudo docker "$@"
}

# Set the terminal window name
termname() {
    # Use window title specified by caller, with a fallback if they didn't specify.
    if [ "$#" -ne 0 ]; then
        name="$@"
    else
        name="$USER@$(hostname)"
    fi
    printf "\e]0;${name}\a"
}

# Set our terminal window name, but only for interactive sessions.
# Printing to stdout in non-interactive sessions breaks scp copies to this host.
[[ $- == *i* ]] && termname

trash() {
    destdir="$HOME/docs/trash/$(date --iso)"
    mkdir -p "$destdir"
    exitval=0
    for src; do
        if [ -e "$src" ]; then
            dest="$destdir/$(basename "$src").$(date +%H%M%S.%N)"
            printf "$src -> $(echo "$dest" | humanize)\n" >&2
            mv "$src" "$dest"
        else
            printf "Not found: $src\n" >&2
            exitval=1
        fi
    done
    return $exitval
}

# -- virtualenvs

ve_root="$HOME/.virtualenvs"

ve() {
    if [ "$#" -eq 0 ]; then
        ls -1 "$ve_root"
        return 0
    elif [ "$#" -ne 1 ]; then
        error "ve: Error: more than one virtualenv name given."
        error "USAGE: ve [virtualenv]"
        error "Omit virtualenv to list existing content of ~/.virtualenvs."
        return 1
    fi
    ve="$ve_root/$1"
    if [ -e "$ve" ]; then
        error "ve: Error: \"$ve\" exists."
        return 2
    fi

    python3 -m venv "$ve"
    "$ve/bin/pip" --quiet install --upgrade pip
}

workon() {
    if [ "$#" -eq 0 ]; then
        ls -1 "$ve_root"
        return 0
    elif [ "$#" -ne 1 ]; then
        error "workon: Error: more than one virtualenv name given."
        error "USAGE: workon [virtualenv]"
        error "Omit virtualenv to list existing content of ~/.virtualenvs."
        return 1
    fi

    if type deactivate &>/dev/null; then
        deactivate
    fi
    source "$ve_root/$1/bin/activate"
    if [ -d "$HOME/$1" ]; then
        cdr "$HOME/$1"
    fi
}

# --

# Allows use of 'watch' with aliases or functions
watcha() {
    watch -ctn1 "bash -i -c \"$@\""
}

## bzr functions ####

alias bs='bzr status && bzr show-pipeline'
alias bt='bzr log -r-1' # tip

bl() {
    bzr log "$@" | less
}

blp() {
    bzr log -v -p "$@" | colordiff | colout -- '^.{7}(-{5,})' cyan reverse | less
}

bup() {
    bzr unshelve --preview "$@" | colordiff
}

## Tool setup #################################################################

## FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS='
  --color bg+:#073642,bg:#002b36,spinner:#719e07,hl:#618e04
  --color fg:#839496,header:#586e75,info:#000000,pointer:#719e07
  --color marker:#719e07,fg+:#839496,prompt:#719e07,hl+:#719e17
'

# Bash Completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# stderred wraps stderr of processes in your terminal with a color
stderred_so="$HOME/.local/share/stderred/libstderred.so"
if [ -f ${stderred_so} ]; then
    export LD_PRELOAD="${stderred_so}${LD_PRELOAD:+:$LD_PRELOAD}"
    export STDERRED_ESC_CODE=$(tput setaf 222)
fi

# direnv (installed using apt) exports env vars from .envrc in PWD or above
# I'm using it to define 'refactor' and 'impl', which are used above.
eval "$(direnv hook bash)"

## On exit ####################################################################

# Backup .bash_history

## TODO: This generates a lot of half megabyte files, there must be a better way.
## Also, the saved files have wildly inconsistent sizes, which seems like a clue
# that something weird is going on.

historyc() {
    history "$@" | colout '^ *(\d+) +([0-9-]+ [0-9:]+)' white,cyan bold,normal
}

bash_history_backups=~/docs/config/bash_history

history_backup() {
    (
        if [ ! -d "$bash_history_backups" ] ; then
            error "bash history save directory not found: '$bash_history_backups'"
            # Normally we'd return 1 here but it doesn't help in this case,
            # since we're executing on shell exit.
        fi
        # make a backup, overwriting other backups from today
        (
            cd "$bash_history_backups"
            \cp ~/.bash_history bash_history_$(date +%F)
            # rm backups older than N days
            ls -1 . | head -n -100 | xargs rm -f
        )
    )
}

if [ ! -d "$bash_history_backups" ]; then
    error "bash history save directory not found: '$bash_history_backups'"
else
    trap history_backup EXIT
fi

dedupe_history() {
    # Now remove duplicate lines from history file
    dedupe-bash-history >/tmp/bash_history
    mv /tmp/bash_history ~/.bash_history
    # (previous solutions, using 'tac', to keep the most recent duplicate,
    # then filtering using line-based tools like awk, don't work with
    # history files containing timestamps or multi-line commands)
    # tac < ~/.bash_history | awk '!a[$0]++' | tac >/tmp/deduped \
    #     && mv -f /tmp/deduped ~/.bash_history
}

## Things that drop junk on the end of your .bashrc #########################

# direnv
if command direnv version >/dev/null; then
    eval "$(direnv hook bash)"
fi

## Node version manager. :eyeroll:
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# # Ignore the error if nvm is not installed on this machine
# :

## Source all ~/.bashrc.* files. ############################################

for fname in $(ls ~/.bashrc.*); do
    . $fname
done

