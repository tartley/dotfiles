#!/usr/bin/env bash

tc=/apps/gnome-terminal/profiles/Default
gconftool-2 -s "${tc}/use_theme_background" -t bool false
gconftool-2 -s "${tc}/use_theme_colors" -t bool false
gconftool-2 -s "${tc}/palette" -t string "#070736364242:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3"
gconftool-2 -s "${tc}/background_color" -t string "#00002B2B3636"
gconftool-2 -s "${tc}/foreground_color" -t string "#65657B7B8383"

