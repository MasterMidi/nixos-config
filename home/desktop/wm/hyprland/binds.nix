{pkgs, ...}: let
  mainMod = "SUPER";
in {
  wayland.windowManager.hyprland.settings = {
    bind = [
      ", Print, exec, grimblast --freeze copy area" # Screenshots
      "${mainMod}, L, exec, hyprlock"
      "${mainMod} SHIFT, W, exec, killall -q .waybar-wrapped ; waybar" # Restart waybar
      "${mainMod} SHIFT, A, exec, killall -q .ags-wrapped ; ags" # Restart ags
      "${mainMod} ALT, W, exec, waybar" # Restart waybar
      "${mainMod}, Q, exec, kitty"
      "${mainMod}, B, exec, firefox"
      "${mainMod} SHIFT, B, exec, firefox --private-window"
      "${mainMod}, G, exec, rofi-games"
      "${mainMod}, W, exec, rofi-wall"
      "${mainMod}, SPACE, exec, pkill rofi || rofi -show drun"
      "${mainMod} CTRL SHIFT, N, exec, pkill rofi-network || rofi-network"
      "${mainMod} CTRL SHIFT, B, exec, pkill rofi-bluetooth || rofi-bluetooth"
      "${mainMod} ALT, SPACE, exec, rofi -show run"
      "${mainMod} SHIFT, SPACE, exec, rofi-rbw"
      "${mainMod} CTRL, B, exec, rofi-bluetooth"
      "${mainMod} CTRL, S, exec, rofi-systemd"
      "${mainMod} CTRL, SPACE, exec, rofi -show calc -modi calc"
      "${mainMod}, PERIOD, exec, bemoji"
      "${mainMod}, V, exec, rofi-clipboard"
      "${mainMod} SHIFT, C, exec, hyprpicker -a"
      "${mainMod}, C, killactive,"
      "${mainMod} SHIFT, Q, exec, ${./scripts/logout.sh},"
      "${mainMod}, E, exec, nautilus -w"
      "${mainMod}, F, togglefloating,"
      "${mainMod}, P, pseudo," # dwindle
      "${mainMod}, J, togglesplit," # dwindle
      "${mainMod}, left, movefocus, l"
      "${mainMod}, right, movefocus, r"
      "${mainMod}, up, movefocus, u"
      "${mainMod}, down, movefocus, d"
      "${mainMod} SHIFT, F, fullscreen, 0"

      ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause --player='spotify,spotify_player,%any'"
      ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next --player='spotify,spotify_player,%any'"
      ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous --player='spotify,spotify_player,%any'"
      "${mainMod}, mouse_up, exec, ${pkgs.playerctl}/bin/playerctl volume '0.05+' --player='spotify,spotify_player,%any'"
      "${mainMod}, mouse_down, exec, ${pkgs.playerctl}/bin/playerctl volume '0.05-' --player='spotify,spotify_player,%any'"
      # TODO keybind to activate gamemode (+ add gamemode start from rofi gamelauncher)

      # Example special workspace (scratchpad)
      # bind = ${mainMod}, S, togglespecialworkspace, magic
      # bind = ${mainMod} SHIFT, S, movetoworkspace, special:magic

      "${builtins.concatStringsSep "\n" (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in ''
            bind = ${mainMod}, ${ws}, workspace, ${toString (x + 1)}
            bind = ${mainMod} SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
          ''
        )
        10)}"
    ];

    bindm = [
      "${mainMod}, mouse:272, movewindow"
      "${mainMod}, mouse:273, resizewindow"
    ];
  };
}
