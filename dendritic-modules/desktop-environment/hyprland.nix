{ ... }:
{
  flake.nixosModules.hyprland =
    { pkgs, ... }:
    {
      programs.uwsm.enable = true;

      programs.hyprland = {
        enable = true;
        withUWSM = true;
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

      # fonts = {
      #   enableDefaultPackages = true;

      #   packages = with pkgs; [
      #     corefonts
      #     noto-fonts
      #     noto-fonts-cjk-sans # To fix weird font rendering for cjk characters
      #     unifont
      #   ];

      #   fontconfig = {
      #     antialias = true;
      #   };
      # };
    };

  flake.homeModules.hyprland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      rgb = color: "rgb(${color})";
      mainMod = "SUPER";

      # Emit a value as a raw Lua expression instead of a quoted Lua value
      luaInline = lib.generators.mkLuaInline;

      # Quote a Nix string so it can be embedded as a Lua string literal
      luaQuote = str: "\"" + lib.replaceStrings [ "\"" ] [ "\\\"" ] str + "\"";

      # hl.dsp.exec_cmd("...") Lua expression for a shell command
      execCmd = cmd: "hl.dsp.exec_cmd(${luaQuote cmd})";

      # Build an hl.bind(...) settings entry:
      # https://wiki.hypr.land/configuring/core/binds/
      mkBind =
        {
          keys,
          dispatcher,
          flags ? null,
        }:
        {
          _args = [
            keys
            (luaInline dispatcher)
          ]
          ++ lib.optional (flags != null) flags;
        };

      # Build an hl.on("hyprland.start", ...) settings entry that runs the given
      # commands once at startup (replaces hyprlang's exec-once):
      # https://wiki.hypr.land/configuring/core/autostart/
      execOnce = commands: {
        _args = [
          "hyprland.start"
          (luaInline ''
            function()
            ${lib.concatMapStrings (cmd: "  hl.exec_cmd(${luaQuote cmd})\n") commands}end
          '')
        ];
      };

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
        # List runtime dependencies. Their 'bin' directories will be added to the script's PATH.bumper-flake-module
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
        configType = "lua";

        plugins = with pkgs; [ ];

        settings = with config.colorScheme.palette; {
          # https://wiki.hypr.land/configuring/core/monitors/
          monitor = [
            {
              output = "";
              mode = "highrr";
              position = "auto";
              scale = 1;
            } # Default
          ];

          # https://wiki.hypr.land/configuring/core/environment-variables/
          env = [
            # { _args = [ "XCURSOR_SIZE" "24" ]; }
            # { _args = [ "GDK_SCALE" "2" ]; }
          ];

          # https://wiki.hypr.land/configuring/core/config-options/
          config = {
            xwayland = {
              use_nearest_neighbor = false;
              force_zero_scaling = true;
            };

            input = {
              kb_layout = "dk";
              kb_variant = "";
              kb_model = "";
              kb_options = "";
              kb_rules = "";

              follow_mouse = 1;

              touchpad = {
                natural_scroll = true;
                middle_button_emulation = true;
              };

              sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
            };

            general = {
              gaps_in = 5;
              gaps_out = 10;
              border_size = 2;
              col = {
                active_border = {
                  colors = [
                    (rgb base0D)
                    (rgb base0B)
                  ];
                  angle = 45;
                };
                inactive_border = rgb base02;
              };
              layout = "dwindle";

              # Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
              allow_tearing = false;
            };

            decoration = {
              # See https://wiki.hypr.land/configuring/core/config-options/ for more

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

            animations.enabled = true;

            dwindle = {
              # See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
              # pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = true; # you probably want this
            };

            # master = {
            #   # See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
            #   # new_status = "master";
            # };

            misc = {
              # See https://wiki.hypr.land/configuring/core/config-options/ for more
              force_default_wallpaper = 0; # Set to 0 to disable the anime mascot wallpapers
              focus_on_activate = true;
            };
          };

          # https://wiki.hypr.land/configuring/core/animations/
          curve = {
            _args = [
              "myBezier"
              {
                type = "bezier";
                points = [
                  [
                    0.05
                    0.9
                  ]
                  [
                    0.1
                    1.05
                  ]
                ];
              }
            ];
          };

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 7;
              bezier = "myBezier";
            }
            {
              leaf = "windowsOut";
              enabled = true;
              speed = 7;
              bezier = "default";
              style = "popin 80%";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 10;
              bezier = "default";
            }
            {
              leaf = "borderangle";
              enabled = true;
              speed = 8;
              bezier = "default";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 7;
              bezier = "default";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 6;
              bezier = "default";
            }
          ];

          # https://wiki.hypr.land/configuring/core/binds/gestures/
          gesture = {
            fingers = 3;
            direction = "horizontal";
            action = "workspace";
          };

          # https://wiki.hypr.land/configuring/core/rules/
          window_rule = [
            {
              match.class = "^(discord|VencordDesktop)$";
              monitor = "1";
            }
            {
              match.class = "^pinentry-$";
              stay_focused = true;
            } # fix pinentry losing focus
            {
              match.class = "^jetbrains-.*$";
              match.title = "^win[0-9]+$";
              float = true;
            }
            {
              match.class = "^jetbrains-.*$";
              match.title = "^win[0-9]+$";
              no_focus = true;
            }
          ];

          bind = [
            # Programs
            (mkBind {
              keys = "${mainMod} + Q";
              dispatcher = execCmd "kitty";
            }) # Terminal
            (mkBind {
              keys = "${mainMod} + E";
              dispatcher = execCmd "nautilus -w";
            }) # File manager
            (mkBind {
              keys = "${mainMod} + B";
              dispatcher = execCmd "firefox";
            }) # Browser
            (mkBind {
              keys = "${mainMod} + SHIFT + B";
              dispatcher = execCmd "firefox --private-window";
            }) # Private browser
            (mkBind {
              keys = "${mainMod} + SHIFT + W";
              dispatcher = execCmd "${pkgs.killall}/bin/killall -q .waybar-wrapped ; waybar";
            }) # Restart waybar
            (mkBind {
              keys = "${mainMod} + SHIFT + A";
              dispatcher = execCmd "${pkgs.killall}/bin/killall -q .ags-wrapped ; ags";
            }) # Restart ags
            (mkBind {
              keys = "${mainMod} + SHIFT + C";
              dispatcher = execCmd "hyprpicker -a";
            }) # Color picker

            # Rofi menues
            (mkBind {
              keys = "${mainMod} + G";
              dispatcher = execCmd "rofi-games";
            }) # rofi games menu
            (mkBind {
              keys = "${mainMod} + W";
              dispatcher = execCmd "rofi-wall ${config.home.homeDirectory}/Pictures/wallpapers";
            }) # rofi wallpaper menu
            (mkBind {
              keys = "${mainMod} + SPACE";
              dispatcher = execCmd "pkill rofi || ${config.programs.rofi.package}/bin/rofi -show drun";
            }) # Rofi app launcher
            (mkBind {
              keys = "${mainMod} + CTRL + SHIFT + N";
              dispatcher = execCmd "pkill rofi-network || rofi-network";
            }) # Rofi network menu
            (mkBind {
              keys = "${mainMod} + CTRL + B";
              dispatcher = execCmd "pkill rofi-bluetooth || rofi-bluetooth";
            }) # Rofi bluetooth menu
            (mkBind {
              keys = "${mainMod} + ALT + SPACE";
              dispatcher = execCmd "rofi -show run";
            }) # Rofi run menu
            (mkBind {
              keys = "${mainMod} + SHIFT + SPACE";
              dispatcher = execCmd "rofi-rbw";
            }) # Rofi rbw menu
            (mkBind {
              keys = "${mainMod} + CTRL + S";
              dispatcher = execCmd "rofi-systemd";
            }) # Rofi systemd menu
            (mkBind {
              keys = "${mainMod} + CTRL + SPACE";
              dispatcher = execCmd "rofi -show calc -modi calc";
            }) # Rofi calculator
            (mkBind {
              keys = "${mainMod} + PERIOD";
              dispatcher = execCmd "bemoji";
            }) # Emoji picker
            (mkBind {
              keys = "${mainMod} + V";
              dispatcher = execCmd "rofi-clipboard";
            }) # Rofi clipboard manager

            # Window management
            (mkBind {
              keys = "${mainMod} + L";
              dispatcher = execCmd "hyprlock";
            }) # Lock screen
            (mkBind {
              keys = "${mainMod} + C";
              dispatcher = "hl.dsp.window.close()";
            }) # Close current window
            (mkBind {
              keys = "${mainMod} + F";
              dispatcher = "hl.dsp.window.float({ action = \"toggle\" })";
            }) # Toggle floating mode
            (mkBind {
              keys = "${mainMod} + P";
              dispatcher = "hl.dsp.window.pseudo()";
            }) # dwindle
            (mkBind {
              keys = "${mainMod} + J";
              dispatcher = "hl.dsp.layout(\"togglesplit\")";
            }) # dwindle
            (mkBind {
              keys = "${mainMod} + left";
              dispatcher = "hl.dsp.focus({ direction = \"left\" })";
            })
            (mkBind {
              keys = "${mainMod} + right";
              dispatcher = "hl.dsp.focus({ direction = \"right\" })";
            })
            (mkBind {
              keys = "${mainMod} + up";
              dispatcher = "hl.dsp.focus({ direction = \"up\" })";
            })
            (mkBind {
              keys = "${mainMod} + down";
              dispatcher = "hl.dsp.focus({ direction = \"down\" })";
            })
            (mkBind {
              keys = "${mainMod} + SHIFT + F";
              dispatcher = "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })";
            })
            # (mkBind { keys = "${mainMod} + D"; dispatcher = execCmd "${showDesktopScript}/bin/hypr-show-desktop"; })

            # Media keys
            (mkBind {
              keys = "${mainMod} + SHIFT + S";
              dispatcher = execCmd "${pkgs.grimblast}/bin/grimblast --freeze copy area";
            }) # Screenshots
            (mkBind {
              keys = "${mainMod} + CTRL + SHIFT + S";
              dispatcher = execCmd "${pkgs.qrtool}/bin/qrtool decode $(${pkgs.grimblast}/bin/grimblast --freeze save area) | ${pkgs.wl-clipboard}/bin/wl-copy";
            }) # Scans QR code and copies data to clipboard
            (mkBind {
              keys = "XF86AudioPlay";
              dispatcher = execCmd "${pkgs.playerctl}/bin/playerctl play-pause --player='spotify,spotify_player,%any'";
            }) # Play/pause
            (mkBind {
              keys = "XF86AudioNext";
              dispatcher = execCmd "${pkgs.playerctl}/bin/playerctl next --player='spotify,spotify_player,%any'";
            }) # Next track
            (mkBind {
              keys = "XF86AudioPrev";
              dispatcher = execCmd "${pkgs.playerctl}/bin/playerctl previous --player='spotify,spotify_player,%any'";
            }) # Previous track
            (mkBind {
              keys = "${mainMod} + mouse_down";
              dispatcher = execCmd "${pkgs.playerctl}/bin/playerctl volume '0.05+' --player='spotify,spotify_player,%any'";
            }) # Volume up
            (mkBind {
              keys = "${mainMod} + mouse_up";
              dispatcher = execCmd "${pkgs.playerctl}/bin/playerctl volume '0.05-' --player='spotify,spotify_player,%any'";
            }) # Volume down
            # TODO keybind to activate gamemode (+ add gamemode start from rofi gamelauncher)

            # Example special workspace (scratchpad)
            # (mkBind { keys = "${mainMod} + S"; dispatcher = "hl.dsp.workspace.toggle_special(\"magic\")"; })
            # (mkBind { keys = "${mainMod} + SHIFT + S"; dispatcher = "hl.dsp.window.move({ workspace = \"special:magic\" })"; })

            # Move/resize windows with mainMod + LMB/RMB and dragging
            (mkBind {
              keys = "${mainMod} + mouse:272";
              dispatcher = "hl.dsp.window.drag()";
              flags = {
                mouse = true;
              };
            })
            (mkBind {
              keys = "${mainMod} + mouse:273";
              dispatcher = "hl.dsp.window.resize()";
              flags = {
                mouse = true;
              };
            })

            # Brightness keys (repeating + locked, replaces hyprlang's bindel)
            (mkBind {
              keys = "${mainMod} + F6";
              dispatcher = execCmd "swayosd-client --brightness raise";
              flags = {
                repeating = true;
                locked = true;
              };
            })
            (mkBind {
              keys = "${mainMod} + F5";
              dispatcher = execCmd "swayosd-client --brightness lower";
              flags = {
                repeating = true;
                locked = true;
              };
            })
          ]
          # Switch to workspace with mainMod + [0-9],
          # move active window to workspace with mainMod + SHIFT + [0-9]
          ++ builtins.concatLists (
            builtins.genList (
              x:
              let
                ws = toString (x + 1 - ((x + 1) / 10) * 10);
              in
              [
                (mkBind {
                  keys = "${mainMod} + ${ws}";
                  dispatcher = "hl.dsp.focus({ workspace = ${toString (x + 1)} })";
                })
                (mkBind {
                  keys = "${mainMod} + SHIFT + ${ws}";
                  dispatcher = "hl.dsp.window.move({ workspace = ${toString (x + 1)} })";
                })
              ]
            ) 10
          );

          # Autostart (replaces hyprlang's exec-once)
          on = [
            (execOnce [
              "${pkgs.waybar}/bin/waybar" # start taskbar
              "sleep 1 && ${pkgs.awww}/bin/awww-daemon" # start wallpaper daemon
              "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator" # start network manager applet
              "${pkgs.blueman}/bin/blueman-applet" # start bluetooth tray icon
              # "${pkgs.kdePackages.xwaylandvideobridge}/bin/kdePackages.xwaylandvideobridge" # start xwayland video bridge
            ])
          ];
        };
      };

      # Polkit authentication agent recommended by Hyprland, started as a
      # systemd user service bound to graphical-session.target (activated by UWSM)
      services.hyprpolkitagent.enable = true;

      # Hyprland (and its ecosystem tooling) expects wl-copy/wl-paste in PATH
      home.packages = [
        pkgs.wl-clipboard
        pkgs.hyprland-guiutils # provides hyprland-welcome, the Getting Started menu
      ];
    };
}
