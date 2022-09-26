#!/usr/bin/env bash
git branch -r | while read branch; do echo $branch; git --no-pager log $branch -1 --pretty="format:%d %ar %an"; echo; done

