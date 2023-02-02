# .bashrc, run by every non-login bash
# aliases and transient shell options that are not inherited by child processes

# echo "$(date) .bashrc" >> .profile.log

## Readline and key binds ####################################################

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

## Env vars related to interacive prompt #####################################
# (other env vars are in .profile)

# PS1
case $- in

# interactive shell
*i*)
  pre='\[\e['
  post='m\]'

  green="${pre}32${post}"
  magenta="${pre}95${post}"
  dim_cyan="${pre}96${post}"
  bright_yellow_inverse="${pre}93;1;7${post}"
  reset="${pre}00${post}"

  pwd="$dim_cyan\w$reset"
  prompt="$bright_yellow_inverse\$$reset"
  user="${USER}"
  if [ "$user" = "jhartley" ]; then
    user="${green}${user}${reset}"
  else
    user="${magenta}${user}${reset}"
  fi
  host="${HOSTNAME%%.*}"
  if [ "$host" = "pop-os" -o "$host" = "t460" -o "$host" = "asus" ]; then
    host="${green}${host}${reset}"
  else
    host="${magenta}${host}${reset}"
  fi

  . ~/.ps1_vcs

  export PS1="${user}@${host} $pwd\$(${dvcs_function})\n$prompt "

  unset pre post green magenta dim_cyan bright_yellow_inverse reset pwd prompt

  # Whenever displaying the prompt, append history to disk
  PROMPT_COMMAND='history -a'
  # To have all terminals sync their history after every command
  # PROMPT_COMMAND='history -a; history -n'

  # if exit value isn't zero, display it with red background, and a bell
  PROMPT_COMMAND='EXITVAL=$?; '$PROMPT_COMMAND
  GET_EXITVAL='$(if [[ $EXITVAL != 0 ]]; then echo -ne "\[\e[37;41;01;5m\] $EXITVAL \[\e[0m\]\07 "; fi)'
  export PS1="$GET_EXITVAL$PS1"

  # turn off flow control, mapped to ctrl-s, so that we regain use of that key
  # for searching command line history forwards (opposite of ctrl-r)
  stty -ixon

;;

# non-interactive shell
*)
;;

esac

# Set dircols if terminal can handle it
if [ "$TERM" != "dumb" ]; then
    eval `dircolors -b $HOME/.dircolors`
fi


## options to coreutils #####################################################

# Requires latest gnu coreutils, maybe don't work with Mac's old built-in ones
alias cp='cp -i'
alias df='df -h'
alias du='du -h'
alias histread='history -c; history -r'
alias less='less -R' # display raw control characters for colors only
alias ll='ls -lAGh'
alias ls='LC_COLLATE="C" ls $LS_OPTIONS'
alias mv='mv -i'
alias rm='rm -i'
alias ssh='TERM=xterm-color ssh'
alias timee='/usr/bin/time -f %E'
alias cd-='cd -'
alias cd..='cd ..'

## Functions ##############################################

function nh {
    nohup "$@" 1>/dev/null 2>&1 &
}

# Allows use of 'watch' with aliases or functions
function watcha {
    watch -ctn1 "bash -i -c \"$@\""
}

function colout_traceroute () {
    colout '(^ ?\d+)|(\([\d\.]+\))|([\d\.]+ ms)|(!\S+)' white,cyan,yellow,magenta bold,normal,normal,reverse
}

function pytree {
    tree -AC -I '*.pyc|__pycache__' "$@"
}

function etime {
    /usr/bin/time -f"%E" "$@"
}

function beep {
    paplay /usr/share/sounds/sound-icons/xylofon.wav &
}

# Use 'pytags $(pydirs) .' to tag with all stdlib and venv symbols
function pydirs {
    python -c "import os, sys; print(' '.join(os.path.relpath(d) for d in sys.path if d))"
}

# Generate n busyloops to keep n CPUs busy.
# See also 'killalljobs'
function busyloop {
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
     echo "error: Not a number" >&2
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

# This is good at cleaning up the results of 'busyloop'
# TODO: There is probably a simpler version of this using 'jobs -p' (output just the PID)
function killalljobs {
  for jid in $(jobs | grep '\[' | cut -d']' -f1 | cut -c2-); do
    kill %$jid
  done
}

function workon {
    . ~/.virtualenvs/$1/bin/activate
}

# Set the terminal window name
function termname {
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

# git stuff
# See also ~/bin for commands I use non-interactively, eg. "watch gd"

function ga {
    git add "$@"
}

function gaa {
    git add --all
}

# List branches with commitid, remotes, commit message
function gb {
    git branch -vv --color=always "$@"
}

# bare current branch name
function gbranch {
    git branch "$@" | grep '^*'| cut -d' ' -f2
}

function gc {
    git commit --verbose "$@"
}

function gdst {
    git diff --stat=160,120
}

# git fast forward
# Arg: branch to merge into current (just like regular 'git merge')
# Merge given branch into current, without creating a merge commit.
# Will abort if cannot fast-forward (eg. current has commits not in Arg1.)
function gff {
    git merge --ff-only -q "$@"
}

# git log, further abbreviated one line per commit, with graph
function gl {
    git log --graph --format=format:"%C(yellow)%h%C(reset)%C(auto)%d%C(reset)%C(white) %s%C(reset)" --abbrev-commit "$@"
    echo
}

# git log, further abbreviated one line per commit, with graph
function gla {
    gl --all "$@"
}

# git log branch - show the commits behind a given merge
function glb {
    git log --graph $(git merge-base --octopus $(git log -1 --pretty=format:%P $1)).. --boundary
}

# git log, pretty one line per commit, with graph
function glog {
    git log --graph --format=format:"%x09%C(yellow)%h%C(reset) %C(green)%ai%x08%x08%x08%x08%x08%x08%C(reset) %C(white)%an%C(reset)%C(auto)%d%C(reset)%n%x09%C(dim white)%s%C(reset)" --abbrev-commit "$@"
    echo
}

# git log, pretty one line per commit, with graph
function gloga {
    glog --all "$@"
}

# git merge, always creating a merge commit.
# Arg1: branch to merge into current (like regular merge)
function gm {
    git merge --no-ff -q "$@"
}

function gpull {
    git pull --quiet "$@"
}

function gpush {
    git push --quiet "$@"
}

function gr {
    git remote -v | sed 's/git+ssh:\/\/tartley@git\.launchpad\.net\//lp:/g' | colout '(^\S+)\s+(lp:)?\S+\s+\((fetch)?|(push)?\)$' cyan,yellow,blue,green normal
}

function gs {
    git status -s "$@"
}

function gsi {
    git status --ignored=traditional "$@"
}

function gst {
    git status "$@"
}

# output tags at the current commit
function gtags {
    git log -n1 --pretty=format:%C\(auto\)%d | sed 's/, /\n/g' | grep tag | sed 's/tag: \|)//g'
}

. ~/.git-completion.bash


## bzr ####

alias bs='bzr status && bzr show-pipeline'
alias bt='bzr log -r-1' # tip

function bl {
    bzr log "$@" | less
}

function blp {
    bzr log -v -p "$@" | colordiff | colout -- '^.{7}(-{5,})' cyan reverse | less
}

function bup {
    bzr unshelve --preview "$@" | colordiff
}

##

# show man pages rendered using postscript
function psman () {
    SLUG=$(echo $@ | tr ' ' '-')
    FNAME="/tmp/man-$SLUG.pdf"
    set -o pipefail
    man -t "$@" | ps2pdf - "$FNAME" && \
        nohup evince "$FNAME" >/dev/null 2>/dev/null
    set +o pipefail
}

function pywait () {
    find -name 'env' -prune -o -name '*.py' -print | entr "$@"
}

## aliases #################################################################

alias whence='type -a' # where, of a sort

# if colordiff is installed, use it
if type colordiff &>/dev/null ; then
    alias diff=colordiff
fi

## Terminal frippery. ######################################################

# call given command every second until a key is pressed
function repeat_until_key () {
    command="$@"
    while true; do
        $command
        read -s -n1 -t1 && break
    done
}

# Flash whole terminal inverse video until key press
function flashes () {
    repeat_until_key flash
}

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


## Tool setup ###############################################################

## FZF
# Neovim plugin config:
# Solarized colors
export FZF_DEFAULT_OPTS='
  --color bg+:#073642,bg:#002b36,spinner:#719e07,hl:#618e04
  --color fg:#839496,header:#586e75,info:#000000,pointer:#719e07
  --color marker:#719e07,fg+:#839496,prompt:#719e07,hl+:#719e17
'
# Bash command line:
[ -f ~/.fzf.bash ] && source ~/.fzf.bash || :

# Go version master
if [[ -s "/home/jhartley/.gvm/scripts/gvm" ]] ; then
    source "/home/jhartley/.gvm/scripts/gvm"
fi

## On exit ##################################################################

# Backup .bash_history

function historyc() {
    history "$@" | colout '^ +(\d+) +([0-9-]+ [0-9:]+)' white,cyan bold,normal
}

function history_backup () {
    (
        if [ -d ~/docs/config/bash_history ] ; then
            # make a backup, overwriting other backups from today
            (
            cd ~/docs/config/bash_history/
            \cp ~/.bash_history bash_history_$(date +%F)
            # rm backups older than N days
            ls -1 . | head -n -100 | xargs rm -f
            )
        fi
    )
}
trap history_backup EXIT

function dedupe_history () {
    # Now remove duplicate lines from history file
    dedupe-bash-history >/tmp/bash_history
    mv /tmp/bash_history ~/.bash_history
    # (previous solutions, using 'tac', to keep the most recent duplicate,
    # then filtering using line-based tools like awk, don't work with
    # history files containing timestamps or multi-line commands)
    # tac < ~/.bash_history | awk '!a[$0]++' | tac >/tmp/deduped \
    #     && mv -f /tmp/deduped ~/.bash_history
}


## Source all ~/.bashrc.* files. ############################################

for fname in $(ls ~/.bashrc.*); do
    # echo "calling $fname"
    . $fname
done

