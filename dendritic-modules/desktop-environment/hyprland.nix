{ ... }:
{
  flake.nixosModules.hyprland =
    { pkgs, ... }:
    {
      programs.hyprland = {
        enable = true;
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = false; # DON'T EVER SET THIS TRUE WILL RUIN XDG-OPEN FUNCTIONALITY
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland
        ];
        config = {
          hyprland.default = [
            "hyprland"
            "gtk"
          ];
        };
      };

      security.polkit.enable = true; # Polkit for hyprland to get sudo password prompts

      environment.variables = {
        NIXOS_OZONE_WL = "1"; # Force electron to use wayland
      };

      fonts = {
        enableDefaultPackages = true;

        packages = with pkgs; [
          corefonts
          noto-fonts
          noto-fonts-cjk-sans # To fix weird font rendering for cjk characters
          unifont
        ];

        fontconfig = {
          antialias = true;
        };
      };
    };

  flake.homeModules.hyprland =
    {
      pkgs,
      config,
      ...
    }:
    let
      rgb = color: "rgb(${color})";
      mainMod = "SUPER";

      showDesktopScript = pkgs.writeShellApplication {
        name = "hypr-show-desktop";
        text = ''
          # From hyprland wiki: https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/#show-desktop

          TMP_FILE="$XDG_RUNTIME_DIR/hyprland-show-desktop"

          CURRENT_WORKSPACE=$(hyprctl monitors -j | jq '.[] | .activeWorkspace | .name' | sed 's/"//g')

          if [ -s "$TMP_FILE-$CURRENT_WORKSPACE" ]; then
            readarray -d $'\n' -t ADDRESS_ARRAY <<< $(< "$TMP_FILE-$CURRENT_WORKSPACE")

            for address in "''${ADDRESS_ARRAY[@]}"
            do
              CMDS+="dispatch movetoworkspacesilent name:$CURRENT_WORKSPACE,address:$address;"
            done

            hyprctl --batch "$CMDS"

            rm "$TMP_FILE-$CURRENT_WORKSPACE"
          else
            HIDDEN_WINDOWS=$(hyprctl clients -j | jq --arg CW "$CURRENT_WORKSPACE" '.[] | select (.workspace .name == $CW) | .address')

            readarray -d $'\n' -t ADDRESS_ARRAY <<< "$HIDDEN_WINDOWS"

            for address in "''${ADDRESS_ARRAY[@]}"
            do
              address=$(sed 's/"//g' <<< $address )

              TMP_ADDRESS+="$address\n"

              CMDS+="dispatch movetoworkspacesilent special:desktop,address:$address;"
            done

            hyprctl --batch "$CMDS"

            echo -e "$TMP_ADDRESS" | sed -e '/^$/d' > "$TMP_FILE-$CURRENT_WORKSPACE"
          fi
        '';
        # List runtime dependencies. Their 'bin' directories will be added to the script's PATH.
        runtimeInputs = [
          pkgs.hyprland
          pkgs.jq
          pkgs.gnused # Use gnused for consistency/features if needed, though pkgs.sed usually works
          pkgs.bash # Explicitly list bash as a dependency
        ];
      };
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;

        plugins = with pkgs; [ ];

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

          gesture = "3, horizontal, workspace";

          misc = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            force_default_wallpaper = 0; # Set to 0 to disable the anime mascot wallpapers
            vfr = true;
            focus_on_activate = true;
          };

          windowrule = [
            "match:class ^(discord|VencordDesktop)$, monitor 1"
            "match:class ^(pinentry-)$, stay_focused 1" # fix pinentry losing focus
            "match:class ^(jetbrains-.*)$, match:title ^(win[0-9]+)$, float 1"
            "match:class ^(jetbrains-.*)$, match:title ^(win[0-9]+)$, no_focus 1"
          ];

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
            # "${mainMod}, D, exec, ${showDesktopScript}"

            # Media keys
            "${mainMod} SHIFT, S, exec, ${pkgs.grimblast}/bin/grimblast --freeze copy area" # Screenshots
            "${mainMod} CTRL SHIFT, S, exec, ${pkgs.qrtool}/bin/qrtool decode $(${pkgs.grimblast}/bin/grimblast --freeze save area) | ${pkgs.wl-clipboard}/bin/wl-copy" # Scans QR code and copies data to clipboard
            ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause --player='spotify,spotify_player,%any'" # Play/pause
            ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next --player='spotify,spotify_player,%any'" # Next track
            ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous --player='spotify,spotify_player,%any'" # Previous track
            "${mainMod}, mouse_down, exec, ${pkgs.playerctl}/bin/playerctl volume '0.05+' --player='spotify,spotify_player,%any'" # Volume up
            "${mainMod}, mouse_up, exec, ${pkgs.playerctl}/bin/playerctl volume '0.05-' --player='spotify,spotify_player,%any'" # Volume down
            # TODO keybind to activate gamemode (+ add gamemode start from rofi gamelauncher)

            # Example special workspace (scratchpad)
            # bind = ${mainMod}, S, togglespecialworkspace, magic
            # bind = ${mainMod} SHIFT, S, movetoworkspace, special:magic

            "${builtins.concatStringsSep "\n" (
              builtins.genList (
                x:
                let
                  ws =
                    let
                      c = (x + 1) / 10;
                    in
                    builtins.toString (x + 1 - (c * 10));
                in
                ''
                  bind = ${mainMod}, ${ws}, workspace, ${toString (x + 1)}
                  bind = ${mainMod} SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
                ''
              ) 10
            )}"
          ];

          bindm = [
            "${mainMod}, mouse:272, movewindow"
            "${mainMod}, mouse:273, resizewindow"
          ];

          bindel = [
            "${mainMod}, F6, exec, swayosd-client --brightness raise"
            "${mainMod}, F5, exec, swayosd-client --brightness lower"
          ];
        };
      };
    };
}
