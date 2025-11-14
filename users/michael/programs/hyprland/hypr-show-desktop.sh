#!/bin/env bash

# From hyprland wiki: https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/#show-desktop

TMP_FILE="$XDG_RUNTIME_DIR/hyprland-show-desktop"

CURRENT_WORKSPACE=$(hyprctl monitors -j | jq '.[] | .activeWorkspace | .name' | sed 's/"//g')

if [ -s "$TMP_FILE-$CURRENT_WORKSPACE" ]; then
  readarray -d $'\n' -t ADDRESS_ARRAY <<< $(< "$TMP_FILE-$CURRENT_WORKSPACE")

  for address in "${ADDRESS_ARRAY[@]}"
  do
    CMDS+="dispatch movetoworkspacesilent name:$CURRENT_WORKSPACE,address:$address;"
  done

  hyprctl --batch "$CMDS"

  rm "$TMP_FILE-$CURRENT_WORKSPACE"
else
  HIDDEN_WINDOWS=$(hyprctl clients -j | jq --arg CW "$CURRENT_WORKSPACE" '.[] | select (.workspace .name == $CW) | .address')

  readarray -d $'\n' -t ADDRESS_ARRAY <<< "$HIDDEN_WINDOWS"

  for address in "${ADDRESS_ARRAY[@]}"
  do
    address=$(sed 's/"//g' <<< $address )

		TMP_ADDRESS+="$address\n"

    CMDS+="dispatch movetoworkspacesilent special:desktop,address:$address;"
  done

  hyprctl --batch "$CMDS"

  echo -e "$TMP_ADDRESS" | sed -e '/^$/d' > "$TMP_FILE-$CURRENT_WORKSPACE"
fi
