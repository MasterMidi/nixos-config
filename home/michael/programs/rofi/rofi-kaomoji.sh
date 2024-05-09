#!/bin/env sh
# https://gitlab.com/ceda_ei/kaomoji-rofi/
export YDOTOOL_SOCKET=/tmp/ydotools
nohup ydotoold --socket-path /tmp/ydotools &                  # Start ydotoold in the background
selection=$(rofi -i -dmenu "@" <@kaomojis@)                   # Show the rofi menu and store the selected item
echo "$selection" | sed "s|$(echo -e "\ufeff").*||" | wl-copy # Copy the selected item to the clipboard
ydotool key 29:1 42:1 47:1 47:0 42:0 29:0                     # Ctrl+Shift+V
pkill ydotool                                                 # Kill ydotoold
