#!/usr/bin/env python3
'''
Removes a common prefix from filenames in the current directory.

USAGE:
        removeprefix.py PREFIX

You might have to quote PREFIX if it contains spaces or other chars that your
shell treats as special.
'''
import os
import sys


def parse_cmdline(args):
    if len(args) != 1:
        sys.exit(__doc__)
    return args[0]


def remove(prefix):
    errors = []
    for filename in os.listdir('.'):
        if filename.startswith(prefix):
            os.rename(filename, filename[len(prefix):])
        else:
            errors.append(filename)
    if errors:
        sys.stderr.write('not changed:\n')
        for error in errors:
            sys.stderr.write('  ' + error + '\n')


def main(args):
    prefix = parse_cmdline(args)
    remove(prefix)


if __name__ == '__main__':
    main(sys.argv[1:])

