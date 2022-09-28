#!/usr/bin/bash

echo -n 'product: '
find *.py | grep -v "/tests/" | xargs cat | grep -cve "^\W*$$"
echo -n 'tests: '
find *.py | grep "/tests/" | xargs cat | grep -cve "^\W*$$"

