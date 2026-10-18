startenv = set(globals())

import atexit
import os
import sys
try:
    from dataclasses import replace
    from _colorize import ANSIColors, default_theme, set_theme
except ImportError:
    pass

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
        nonvis = "\001"
        vis = "\002"

        prefix = "\x1b["
        bg = prefix + "103m" # bright yellow
        fg = prefix + "1;30m" # bold black
        reset = prefix + "0m"

        sys.ps1 = nonvis + bg + fg + vis + ">>>" + nonvis + reset + vis + " "
        sys.ps2 = nonvis + bg + fg + vis + "..." + nonvis + reset + vis + " "


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
    except OSError as exc:
        msg(f"ERROR: Failed to read history file '{histfile}' ({exc})")


def write_history_file_atexit(histfile):
    atexit.register(readline.write_history_file, histfile)
    msg("Will write to history file atexit")


def set_repl_colors():
    # See options with:
    #
    #   from _colorize import default_theme
    #   from pprint import pprint
    #   pprint(default_theme, indent=2, expand=True)
    #
    # See colors with:
    #
    #   from _colorize import ANSIColors
    #   from pprint import pprint
    #   pprint(vars(ANSIColors), indent=2, expand=True)
    #
    theme = default_theme.copy_with(
        syntax=replace(
            default_theme.syntax,
            prompt=ANSIColors.INTENSE_BACKGROUND_YELLOW + ANSIColors.BOLD_BLACK, # Doesn't work
            keyword=ANSIColors.BOLD_WHITE,
            soft_keyword=ANSIColors.INTENSE_WHITE,
            keyword_constant=ANSIColors.INTENSE_WHITE,
            string=ANSIColors.INTENSE_CYAN,
            number=ANSIColors.INTENSE_CYAN,
            comment=ANSIColors.GREY,
            builtin=ANSIColors.INTENSE_WHITE,
            op=ANSIColors.WHITE,
            definition=ANSIColors.GREEN,
        ),
        traceback=replace(
            default_theme.traceback,
            type=ANSIColors.INTENSE_RED,
            message=ANSIColors.WHITE,
            note=ANSIColors.INTENSE_BLUE,
            filename=ANSIColors.INTENSE_GREEN,
            line_no=ANSIColors.INTENSE_GREEN,
            frame=ANSIColors.INTENSE_GREEN,
            error_highlight=ANSIColors.INTENSE_RED,
            error_range=ANSIColors.INTENSE_RED,
        ),
    )
    set_theme(theme)


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
    set_repl_colors()
    delete_new_globals(startenv)


if __name__ == '__main__':
    main()

