#!/usr/bin/env python2.7
"""
imageresize
-----------
    Version: %s

Usage
-----
    python imageresize.py [OPTIONS] image.jpg [image2.jpg...]

    where:
        -s SIZE     Max image dimension (either height or width).
                    Defaults to %d.
        -f          Force, always resave, even for smaller images.
        -v          Verbose.
        -h          Show this help

Description
-----------
    Shrinks specified images so that the largest dimension is SIZE. Images may
    be any format that is loaded and saved by the Python Imaging Library (PIL).
    Originals are moved to a subdir named '%s'.

    The original intent of this was to reduce the filesize of photos from
    digital cameras, at the cost of introducing minor new compression artifacts
    in the image. Even images which are already smaller than SIZE are
    substantially reduced in filesize, if a resave is forced with -f.

    I like to run this over all my photos, reducing their filesizes to about
    20%% of their original filesize. Your mileage may vary.

Requirements
------------
    * Python must be installed. Tested on Python 2.5, 2.6, 2.7.
    * Python Imaging Library must be installed.
    * Only tested on Ubuntu 8.10, WinXP, Win7. Might work elsewhere.

Authorship
----------
    Jonathan Hartley, tartley@tartley.com.
    Licensed under the New BSD License, the text of which is at:
    http://www.opensource.org/licenses/bsd-license.php
"""

from __future__ import division

from glob import glob
from os import mkdir
from os.path import basename, dirname, getsize, isdir, isfile, join
from shutil import copy
from sys import argv, exit

import Image

revision='1.13'

defaultSize = 1280
backupDir = "orig"
usage = __doc__ % (revision, defaultSize, backupDir)


class Sizer(object):

    def __init__(self):
        self.maxSize = defaultSize
        self.filenames= []
        self.verbose = False
        self.force = False


    def process_size_arg(self, args):
        abort = False
        sizeInt = None
        try:
            size = args.pop(0)
            sizeInt = int(size)
        except IndexError:
            print "no size specified after '-s'"
            abort = True
        except ValueError:
            print "bad size after '-s': %s" % (size, )
            abort = True
        else:
            if sizeInt < 1:
                print "size should be greater than 0: %s" % size
                abort = True
            else:
                self.maxSize = sizeInt
        return abort


    def process_args(self, args):
        abort = False
        if len(args) == 0:
            print "no images found"

        while (args):
            arg = args.pop(0)

            if arg == "-s":
                abort |= self.process_size_arg(args)

            elif arg == '-h':
                print usage

            elif arg == '-v':
                self.verbose = True

            elif arg == '-f':
                self.force = True

            elif arg.startswith('-'):
                print "unknown option: %s" % arg
                abort = True

            elif isfile(arg):
                self.filenames.append(arg)

            else:
                for filename in glob(arg):
                    if isfile(filename):
                        self.filenames.append(filename)
                    else:
                        print ("unknown param, not a file: %s" % arg)
                        abort = True
        if abort:
            exit(1)


    def backup(self, path):
        backupPath = join(dirname(path), backupDir)
        filename = basename(path)
        if not isdir(backupPath):
            mkdir(backupPath)
        dest = join(backupPath, filename)
        if not isfile(dest):
            copy(path, dest)


    def getNewSize(self, width, height):
        if width > height:
            ratio = self.maxSize / width
        else:
            ratio = self.maxSize / height
        newWidth = int(width * ratio)
        newHeight = int(height * ratio)
        return newWidth, newHeight


    def resize(self):
        modifications = False
        for filename in self.filenames:

            try:
                image = Image.open(filename)
            except IOError:
                print "skipping, not an image: %s" % filename
                continue

            if self.verbose:
                print filename,

            width, height = image.size
            filesize = getsize(filename)
            if self.verbose:
                print "%dx%d" % (width, height),
                print "%.0fkb" % (filesize/1000),

            newWidth, newHeight = self.getNewSize(width, height)

            if newWidth >= width:
                if self.force:
                    newWidth = width
                    newHeight = height
                    verb = "force"
                else:
                    if self.verbose:
                        print "skip"
                    continue

            else:
                verb = "-> %dx%d" % (newWidth, newHeight)

            if self.verbose:
                print "%s," % (verb),

            image.thumbnail((newWidth, newHeight), Image.ANTIALIAS)
            self.backup(filename)
            image.save(filename)
            modifications = True

            newFilesize = getsize(filename)
            if self.verbose:
                percent = 100 * newFilesize / filesize
                print "%.0fkb %.0f%%" % (newFilesize/1000, percent)

        if modifications:
            print "backups are in 'orig' directory"


def main():
    sizer = Sizer()
    sizer.process_args(argv[1:])
    sizer.resize()


if __name__ == "__main__":
    main()
