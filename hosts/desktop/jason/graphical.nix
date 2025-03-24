{
  pkgs,
  config,
  ...
}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Display manager.
  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };

  # Define monitors for GDM
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
  ];

  # Set the same cursor theme for GDM and Hyprland
  programs.dconf = {
    enable = true;
    profiles = {
      gdm.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              # cursor-theme = config.home-manager.users.michael.home.pointerCursor.name;
            };
          };
        }
      ];
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "nodeadkeys";
  };

  # Enable Hyprland window manager
  programs.hyprland = {
    enable = true;
  };

  home-manager.users.michael.wayland.windowManager.hyprland.settings = {
    monitor = [
      # "HDMI-A-2, 1920x1080@60, 0x230, 0.93" # matches the dpi, but creates a gap around apps and poor font rendering
      "HDMI-A-1, 1920x1080@60, 0x275, 1"
      "HDMI-A-2, 1920x1080@60, 0x275, 1"
      "HDMI-A-3, 1920x1080@60, 0x275, 1"

      # Xiaomi mi 34" curved monitor.
      # DON'T enable VRR/FreeSync, will flicker screen
      "DP-1, 3440x1440@144, 1920x0, 1"
      "DP-2, 3440x1440@144, 1920x0, 1"
      "DP-3, disable"
    ];
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false; # DON'T EVER SET THIS TRUE WILL RUIN XDG-OPEN FUNCTIONALITY
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config = {
      hyprland.default = ["hyprland" "gtk"];
    };
  };

  services.gvfs.enable = true; # for nautlius to work with ttrash and network shares

  environment.variables = {
    NIXOS_OZONE_WL = "1"; # Force electron to use wayland
  };

  # fonts
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

  # Shutdown animation
  boot.plymouth = {
    enable = false;
    logo = pkgs.fetchurl {
      url = "https://nixos.org/logo/nixos-hires.png";
      sha256 = "1ivzgd7iz0i06y36p8m5w48fd8pjqwxhdaavc0pxs7w1g7mcy5si";
    };
    theme = "breeze";
    # theme = "angular_alt";
    # themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["angular_alt"];})];
  };
}
