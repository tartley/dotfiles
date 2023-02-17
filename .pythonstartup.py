startenv = set(globals())

import atexit
import os
import sys

COLORTERMS = [
    'xterm', 'xterm-color', 'xterm-256color', 'vt100',
]

# Define aliases so JSON can be pasted straight in.
true = True
false = False
null = None

try:
    import readline
except ImportError:
    readline = None
else:
    import rlcompleter


def set_ps1():
    if os.environ.get('TERM') in COLORTERMS and sys.platform != 'darwin':
        # Tell terminal which chars are non-visible,
        # so it can keep accurate track of line lengths.
        # This doesn't seem to work on OSX.
        nonvis = '\001'
        vis = '\002'

        prefix = '\x1b['
        bold_yellow = prefix + '1;33m'
        reset = prefix + '0m'

        sys.ps1 = nonvis + bold_yellow + vis + '>>> ' + nonvis + reset
        sys.ps2 = nonvis + bold_yellow + vis + '... ' + nonvis + reset


def enable_tab_completion():
    if sys.platform == "darwin":
        readline.parse_and_bind('bind ^I rl_complete')
    else:
        readline.parse_and_bind('tab: complete')
    print(".pythonstartup.py: Bound readline 'complete' to [tab]")


def read_history_file():
    histfile = os.path.join(os.environ['HOME'], '.pythonhistory')
    try:
        readline.read_history_file(histfile)
        print(f".pythonstartup.py: Read history ({histfile})")
    except IOError:
        pass
    return histfile


def write_history_atexit(histfile):
    atexit.register(readline.write_history_file, histfile)
    print(f".pythonstartup.py: Registered to write history file atexit")


def delete_new_globals(startenv):
    for key in set(globals()) - startenv:
        del globals()[key]


def main():
    set_ps1()
    if readline:
        enable_tab_completion()
        histfile = read_history_file()
        write_history_atexit(histfile)
    delete_new_globals(startenv)


if __name__ == '__main__':
    main()

