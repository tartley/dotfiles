#!/usr/bin/python

from os import listdir
from os.path import isfile, join, splitext
from random import randrange
from subprocess import call
from sys import exit


image_dir = '/home/jhartley/docs/media/wallpaper'
image_extensions = ['.jpeg', '.jpg', '.png', 'gif', 'bmp']

def get_image_files():
    files = listdir(image_dir)

    image_files = []
    for imgfile in files:
        ext = splitext(imgfile)[1]
        if ext.lower() in image_extensions and isfile(join(image_dir, imgfile)):
            image_files.append(imgfile)
    return image_files


def pick_one(image_files):
    index = randrange(0, len(image_files))
    return image_files[index]


def set_key(key, value):
    command = [
        'gconftool',
        '-t',
        'string',
        '-s',
        key,
        value,
    ]
    return call(command)


def change_background(image_file):
    root_key = '/desktop/gnome/background/'
    image_key = 'picture_filename'
    options_key = 'picture_options'
    retval = set_key(root_key + image_key, image_dir + image_file)
    if retval == 0:
        retval = set_key(root_key + options_key, "stretched")
    return retval


image_files = get_image_files()
image_file = pick_one(image_files)
print image_file
exit(change_background(image_file))
