#!/usr/bin/env bash

tc=/apps/gnome-terminal/profiles/Default
gconftool-2 -s "${tc}/use_theme_background" -t bool false
gconftool-2 -s "${tc}/use_theme_colors" -t bool false
gconftool-2 -s "${tc}/palette" -t string '#000000000000:#AAAA00000000:#0000AAAA0000:#AAAA55550000:#00000000AAAA:#AAAA0000AAAA:#0000AAAAAAAA:#AAAAAAAAAAAA:#555555555555:#FFFF55555555:#5555FFFF5555:#FFFFFFFF5555:#55555555FFFF:#FFFF5555FFFF:#5555FFFFFFFF:#FFFFFFFFFFFF'
gconftool-2 -s "${tc}/background_color" -t string '#000000000000'
gconftool-2 -s "${tc}/foreground_color" -t string '#FFFFFFFFFFFF'

