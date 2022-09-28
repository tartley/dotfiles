#!/usr/bin/env bash

if command -v notify-send >/dev/null ; then
	notify-send "ssh $*"
else
	echo "ssh $*" >&2
fi

