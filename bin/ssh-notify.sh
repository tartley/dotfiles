#!/usr/bin/env bash

if command -v notify-send >/dev/null ; then
	notify-send "$@"
else
	echo -e "ssh $@" >&2
fi

