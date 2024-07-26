#!/bin/env sh
export YDOTOOL_SOCKET=/tmp/ydotools
nohup ydotoold --socket-path /tmp/ydotools &            # Start ydotoold in the background
cliphist list | rofi -dmenu | cliphist decode | wl-copy # Copy the selected item to the clipboard
ydotool key 29:1 42:1 47:1 47:0 42:0 29:0               # Ctrl+Shift+V
pkill ydotool                                           # Kill ydotoold
