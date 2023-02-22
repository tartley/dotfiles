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
alias cd-='cd -'
alias cd..='cd ..'
alias cp='cp -i'
alias df='df -h'
alias du='du -h'
alias histread='history -c; history -r'
alias less='less -R' # display raw control characters for colors only
alias ll='ls -lGh'
alias la='ll -A'
alias ls='LC_COLLATE="C" ls $LS_OPTIONS'
alias mv='mv -i'
alias rm='rm -i'
alias ssh='TERM=xterm-color ssh'
alias timee='/usr/bin/time -f %E'


## Other aliases #########################################

alias whence='type -a' # like where, but also describes aliases and functions

# if colordiff is installed, use it
if type colordiff &>/dev/null ; then
    alias diff=colordiff
fi


## Functions ##############################################

beep() {
    paplay /usr/share/sounds/sound-icons/xylofon.wav &
}

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

# See 'bzr functions', below.

# cd into a directory, resolving any symlinks to give the full actual directory name
cdr() {
    if [ -n "$1" ]; then in="$1"; else in="."; fi
    cd $(readlink -e "$in")
}

colout_traceroute() {
    colout '(^ ?\d+)|(\([\d\.]+\))|([\d\.]+ ms)|(!\S+)' white,cyan,yellow,magenta bold,normal,normal,reverse
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

nh() {
    nohup "$@" 1>/dev/null 2>&1 &
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
    tree -AC -I '*.pyc|__pycache__' "$@"
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

# Allows use of 'watch' with aliases or functions
watcha() {
    watch -ctn1 "bash -i -c \"$@\""
}

workon() {
    . ~/.virtualenvs/$1/bin/activate
}

# git functions (esp. see 'git'!)
# See also ~/bin for commands I use non-interactively, eg. "watch gd"

# git add
ga() {
    git add "$@"
}

# git add all
gaa() {
    git add --all
}

# git branch: List branches with commitid, remotes, commit message
gb() {
    git branch -vv --color=always "$@"
}

# git branch: Print bare current branch name
gbranch() {
    git branch "$@" | grep '^*'| cut -d' ' -f2
}

# git commit
gc() {
    git commit --verbose "$@"
}

# git fast forward : merge without a merge commit. (see gm for opposite)
# Arg: branch to merge into current (just like regular 'git merge')
# Merge given branch into current, without creating a merge commit.
# Will abort if cannot fast-forward (eg. current has commits not in Arg1.)
gff() {
    git merge --ff-only -q "$@"
}

# Shadows git! To warn againt the use of 'git push -f'
git() {
    is_push=false
    for arg in "$@"; do
        [ "$arg" = "push" ] && is_push=true
        if [ "$is_push" = true ] && [ "$arg" = "-f" -o "$arg" = "--force" ]; then
            echo "git push -f: Consider 'git push --force-with-lease --force-if-includes' instead, which is aliased to 'gpf'"
            return 1
        fi
    done
    # run the executable, not this function
    $(which git) "$@"
}

# git log : one line per commit, with graph
gl() {
    git log --graph --format=format:"%C(yellow)%h%C(reset)%C(auto)%d%C(reset)%C(white) %s%C(reset)" --abbrev-commit "$@"
    echo
}

# git log : all branches, one line per commit, with graph
gla() {
    gl --all "$@"
}

# git log merge : show the commits that are ancestors of a given merge
glm() {
    git log --graph $(git merge-base --octopus $(git log -1 --pretty=format:%P $1)).. --boundary
}

# git log : two lines per commit, with graph
glog() {
    git log --graph --format=format:"%x09%C(yellow)%h%C(reset) %C(green)%ai%x08%x08%x08%x08%x08%x08%C(reset) %C(white)%an%C(reset)%C(auto)%d%C(reset)%n%x09%C(dim white)%s%C(reset)" --abbrev-commit "$@"
    echo
}

# git log : all branches, two lines per commit, with graph
gloga() {
    glog --all "$@"
}

# git merge, always creating a merge commit. (see gff for opposite)
# Arg1: branch to merge into current (like regular merge)
gm() {
    git merge --no-ff -q "$@"
}

# git pull
gpull() {
    git pull --quiet "$@"
}

# git push
gpush() {
    git push --quiet "$@"
}

# git push force: using the new, safer alternatives to --force
gpf() {
    gpush --force-with-lease --force-if-includes "$@"
}

# git remote : list remotes
gr() {
    git remote -v | sed 's/git+ssh:\/\/tartley@git\.launchpad\.net\//lp:/g' | colout '(^\S+)\s+(lp:)?\S+\s+\((fetch)?|(push)?\)$' cyan,yellow,blue,green normal
}

# git status : short format
gs() {
    git status -s "$@"
}

# git ignored : use git status to show ignored files in current dir
# Can pass '..' or similar to see ignored files from other dirs.
gignored() {
    git status --ignored=traditional . "$@"
}

# git status : regular format
gst() {
    git status "$@"
}

# git tags : use 'git log' to display tags at the current commit
gtags() {
    git log -n1 --pretty=format:%C\(auto\)%d | sed 's/, /\n/g' | grep tag | sed 's/tag: \|)//g'
}

. ~/.git-completion.bash


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

historyc() {
    history "$@" | colout '^ *(\d+) +([0-9-]+ [0-9:]+)' white,cyan bold,normal
}

history_backup() {
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


## Source all ~/.bashrc.* files. ############################################

for fname in $(ls ~/.bashrc.*); do
    # echo "calling $fname"
    . $fname
done

