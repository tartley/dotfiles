@echo off
grep.exe -rI --color --exclude-dir=\.bzr --exclude-dir=\.git --exclude-dir=\.hg --exclude-dir=\.svn --exclude-dir=build --exclude-dir=dist --exclude=tags %*

