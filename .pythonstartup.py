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


def msg(message):
    print(f"{os.path.basename(__file__)}: {message}", file=sys.stderr)


try:
    import readline
except ImportError:
    msg("Package 'readline' not found")
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

        sys.ps1 = nonvis + bold_yellow + vis + '>>> ' + nonvis + reset + vis
        sys.ps2 = nonvis + bold_yellow + vis + '... ' + nonvis + reset + vis


def enable_tab_completion():
    if sys.platform == "darwin":
        readline.parse_and_bind('bind ^I rl_complete')
    else:
        readline.parse_and_bind('tab: complete')
    msg("Bound readline 'complete' to [tab]")


def get_history_filename():
    return os.path.join(os.environ['HOME'], '.python_history')


def read_history_file(histfile):
    try:
        readline.read_history_file(histfile)
        msg(f"Read history file '{histfile}'")
    except IOError as exc:
        msg(f"ERROR: Failed to read history file '{histfile}' ({exc})")


def write_history_file_atexit(histfile):
    atexit.register(readline.write_history_file, histfile)
    msg(f"Will write to history file atexit")


def delete_new_globals(startenv):
    for key in set(globals()) - startenv:
        del globals()[key]


def main():
    set_ps1()
    if readline:
        enable_tab_completion()
        # Python3.13 began persisting REPL history automatically (to the same file we use)
        if sys.version_info < (3, 13):
            histfile = get_history_filename()
            read_history_file(histfile)
            write_history_file_atexit(histfile)
    delete_new_globals(startenv)


if __name__ == '__main__':
    main()

