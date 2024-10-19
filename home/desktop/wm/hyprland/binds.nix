{
  pkgs,
  config,
  ...
}: let
  mainMod = "SUPER";
in {
  wayland.windowManager.hyprland.settings = {
    bind = [
      # Programs
      "${mainMod}, Q, exec, kitty" # Terminal
      "${mainMod}, E, exec, nautilus -w" # File manager
      "${mainMod}, B, exec, firefox" # Browser
      "${mainMod} SHIFT, B, exec, firefox --private-window" # Private browser
      "${mainMod} SHIFT, W, exec, ${pkgs.killall}/bin/killall -q .waybar-wrapped ; waybar" # Restart waybar
      "${mainMod} SHIFT, A, exec, ${pkgs.killall}/bin/killall -q .ags-wrapped ; ags" # Restart ags
      "${mainMod} SHIFT, C, exec, hyprpicker -a" # Color picker

      # Rofi menues
      "${mainMod}, G, exec, rofi-games" # rofi games menu
      "${mainMod}, W, exec, rofi-wall ${config.home.homeDirectory}/Pictures/wallpapers" # rofi wallpaper menu
      "${mainMod}, SPACE, exec, pkill rofi || ${config.programs.rofi.package}/bin/rofi -show drun" # Rofi app launcher
      "${mainMod} CTRL SHIFT, N, exec, pkill rofi-network || rofi-network" # Rofi network menu
      "${mainMod} CTRL, B, exec, pkill rofi-bluetooth || rofi-bluetooth" # Rofi bluetooth menu
      "${mainMod} ALT, SPACE, exec, rofi -show run" # Rofi run menu
      "${mainMod} SHIFT, SPACE, exec, rofi-rbw" # Rofi rbw menu
      "${mainMod} CTRL, S, exec, rofi-systemd" # Rofi systemd menu
      "${mainMod} CTRL, SPACE, exec, rofi -show calc -modi calc" # Rofi calculator
      "${mainMod}, PERIOD, exec, bemoji" # Emoji picker
      "${mainMod}, V, exec, rofi-clipboard" # Rofi clipboard manager

      # Window management
      "${mainMod}, L, exec, hyprlock" # Lock screen
      "${mainMod}, C, killactive," # Close current window
      "${mainMod}, F, togglefloating," # Toggle floating mode
      "${mainMod}, P, pseudo," # dwindle
      "${mainMod}, J, togglesplit," # dwindle
      "${mainMod}, left, movefocus, l"
      "${mainMod}, right, movefocus, r"
      "${mainMod}, up, movefocus, u"
      "${mainMod}, down, movefocus, d"
      "${mainMod} SHIFT, F, fullscreen, 0"

      # Media keys
      ", Print, exec, ${pkgs.grimblast}/bin/grimblast --freeze copy area" # Screenshots
      ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause --player='spotify,spotify_player,%any'"
      ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next --player='spotify,spotify_player,%any'"
      ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous --player='spotify,spotify_player,%any'"
      "${mainMod}, mouse_down, exec, ${pkgs.playerctl}/bin/playerctl volume '0.05+' --player='spotify,spotify_player,%any'"
      "${mainMod}, mouse_up, exec, ${pkgs.playerctl}/bin/playerctl volume '0.05-' --player='spotify,spotify_player,%any'"
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
