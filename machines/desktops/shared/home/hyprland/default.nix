{
  pkgs,
  config,
  ...
}: let
  rgb = color: "rgb(${color})";
in {
  imports = [
    ./binds.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    plugins = with pkgs; [];

    settings = with config.colorScheme.palette; {
      exec-once = [
        "${pkgs.waybar}/bin/waybar" # start taskbar
        "sleep 1 && ${pkgs.swww}/bin/swww-daemon" # start wallpaper daemon
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" # start polkit agent
        "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator" # start network manager applet
        "${pkgs.blueman}/bin/blueman-applet" # start bluetooth tray icon
        # "${pkgs.kdePackages.xwaylandvideobridge}/bin/kdePackages.xwaylandvideobridge" # start xwayland video bridge
      ];

      monitor = [
        ",highrr,auto,1" # Default
      ];

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
        "col.active_border" = "${rgb base0D} ${rgb base0B} 45deg";
        "col.inactive_border" = "${rgb base02}";
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

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
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
        # new_is_master = true;
      };

      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = "on";
      };

      misc = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        force_default_wallpaper = 0; # Set to 0 to disable the anime mascot wallpapers
        vfr = true;
        focus_on_activate = true;
      };

      windowrulev2 = [
        "monitor 1, class:^(discord|VencordDesktop)$"
        "stayfocused, class:^(pinentry-)" # fix pinentry losing focus
        "float,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
        "nofocus,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
      ];
    };
  };
}
