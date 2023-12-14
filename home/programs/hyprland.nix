{pkgs, ...}:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "waybar"
        "swww init"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "wl-paste --watch cliphist store"
        "xwaylandvideobridge"
      ];

      monitor = [
        ",highrr,auto,auto" # Default
        # "HDMI-A-2, 1920x1080@60, 0x230, 0.93" # matches the dpi, but creates a gap around apps and poor font rendering
        "HDMI-A-2, 1920x1080@60, 0x270, 1"
        "DP-1, 3440x1440@144, 1920x0, 1"
      ];

      env = "XCURSOR_SIZE=24";

      input = {
        kb_layout = "dk";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = "no";
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        # col = {
        #   active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        #   inactive_border = "rgba(595959aa)";
        # };
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 10;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = "yes";

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = "yes"; # you probably want this
      };

      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true;
      };

      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = "off";
      };

      misc = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        force_default_wallpaper = -1; # Set to 0 to disable the anime mascot wallpapers
      };

      "$mainMod" = "SUPER";
      bind = [
        ", Print, exec, grimblast --freeze copy area" # Screenshots
        "$mainMod SHIFT, W, exec, killall .waybar-wrapped 2>/dev/null && waybar" # Restart waybar
        "$mainMod ALT, W, exec, waybar" # Restart waybar
        "$mainMod, Q, exec, kitty"
        "$mainMod, B, exec, firefox"
        "$mainMod, G, exec, $HOME/.config/rofi/gamelauncher.sh"
        "$mainMod, Space, exec, rofi -show drun"
        "$mainMod ALT, Space, exec, rofi -show run"
        "$mainMod, C, killactive,"
        "$mainMod SHIFT, Q, exit,"
        "$mainMod, E, exec, nautilus"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, wofi --show drun"
        "$mainMod, P, pseudo," # dwindle
        "$mainMod, J, togglesplit," # dwindle
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        # TODO keybind to activate gamemode (+ add gamemode start from rofi gamelauncher)

        # Example special workspace (scratchpad)
        # bind = $mainMod, S, togglespecialworkspace, magic
        # bind = $mainMod SHIFT, S, movetoworkspace, special:magic

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"


        "${builtins.concatStringsSep "\n" (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in ''
              bind = $mainMod, ${ws}, workspace, ${toString (x + 1)}
              bind = $mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
            ''
          )
          10)}"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}