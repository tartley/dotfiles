#!/usr/bin/env bash

# touches each directory in . to give it the same datestamp as the files
# within it. Because I often create / rename directories long after
# downloading files, so the files have a correct aquisition date, but
# directories do not.

ls | while read dirname; do
    echo $dirname
    ls "$dirname" | while read filename; do
        echo "  $filename"
        touch -r "$dirname/$filename" "$dirname"
    done
done

