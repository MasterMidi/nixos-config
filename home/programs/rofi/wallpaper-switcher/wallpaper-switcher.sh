#!/usr/bin/env bash

# set variables
RofiConf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/wallpaper-switcher/theme.rasi"
RofiConf=/etc/nixos/home/programs/rofi/wallpaper-switcher/theme.rasi

# set rofi override
elem_border=$(( hypr_border * 2 ))
icon_border=$(( elem_border - 3 ))
r_override="element{border-radius:${elem_border}px;} element-icon{border-radius:${icon_border}px;}"

wallpaper_folder=$HOME/Pictures/wallpapers/
wallpaper_location="$(ls "$wallpaper_folder" | sort | rofi -dmenu -i -p "Select Background"  \
							   -theme ${RofiConf} 		     \
								 -theme-str "${r_override}" \
							   -hover-select -me-select-entry '' \
	 						   -me-accept-entry MousePrimary)"

if [[ -d $wallpaper_folder/$wallpaper_location ]]; then
    wallpaper_temp="$wallpaper_location"
elif [[ -f $wallpaper_folder/$wallpaper_location ]]; then
	swww img "$wallpaper_folder"/"$wallpaper_location" --transition-step 255 --transition-type any
else
    exit 1
fi
