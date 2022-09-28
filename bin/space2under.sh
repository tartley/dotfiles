#!/bin/bash

ls *.txt | while read -r FILE
do
    NEWNAME=`echo $FILE | tr ' ' '_' `
    echo "$NEWNAME"
    svn mv "$FILE" "$NEWNAME"
done

