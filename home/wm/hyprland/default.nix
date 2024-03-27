{pkgs, ...}: let
  config = ".config/hypr";
in {
  home.file = {
    "${config}/scripts".source = ./scripts;
  };

  wayland.windowManager.hyprland = {
    enable = true;

    plugins = with pkgs; [];

    settings =
      {
        exec-once = [
          "waybar"
          "sleep 2 && swww init"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "wl-paste --watch cliphist store"
        ];

        monitor = [
          ",highrr,auto,1" # Default
          # "HDMI-A-2, 1920x1080@60, 0x230, 0.93" # matches the dpi, but creates a gap around apps and poor font rendering
          "HDMI-A-2, 1920x1080@60, 0x275, 1"
          "DP-1, 3440x1440@144, 1920x0, 1"
          # "eDP-1, 2240x1400@60, 0x0, 1"
        ];

        "misc:vfr" = true;

        xwayland = {
          use_nearest_neighbor = false;
          force_zero_scaling = true;
        };

        env = [
          # "XCURSOR_SIZE,24"
          # "GDK_SCALE,2"
        ];

        input = {
          kb_layout = "dk";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;

          touchpad = {
            natural_scroll = "yes";
            middle_button_emulation = true;
          };

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
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
          workspace_swipe = "on";
        };

        misc = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = 0; # Set to 0 to disable the anime mascot wallpapers
          vfr = true;
        };

        windowrulev2 = [
          "monitor 1, class:(discord|VencordDesktop)"
          "stayfocused, title:^()$,class:^(steam)$" # fix steam menues
          "minsize 1 1, title:^()$,class:^(steam)$" # Fix steam friends list

          "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
          "noanim,class:^(xwaylandvideobridge)$"
          "noinitialfocus,class:^(xwaylandvideobridge)$"
          "maxsize 1 1,class:^(xwaylandvideobridge)$"
          "noblur,class:^(xwaylandvideobridge)$"
        ];

        # workspace = [
        #   "1, monitor:DP-1"
        #   "2, monitor:HMDI-A-2"
        #   "3, monitor:DP-1"
        #   "4, monitor:HMDI-A-2"
        #   "5, monitor:DP-1"
        #   "6, monitor:HMDI-A-2"
        #   "7, monitor:DP-1"
        #   "8, monitor:HMDI-A-2"
        #   "9, monitor:DP-1"
        #   "10, monitor:HMDI-A-2"
        # ];
      }
      // import ./binds.nix;
  };
}
