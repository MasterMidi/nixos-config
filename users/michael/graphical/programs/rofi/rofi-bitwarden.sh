#!/bin/env sh
# Run rofi-rbw and capture its output and exit status
output=$(rofi-rbw 2>&1)
status=$?

if [ $status -eq 0 ]; then
	# If rofi-rbw succeeded, copy the output to the clipboard using wl-copy
	echo "$output" | wl-copy
else
	# If rofi-rbw failed, send the error output as a notification
	notify-send "t1" -a "rofi-rbw Error" "$output" -r 91190 -t 2200
fi
