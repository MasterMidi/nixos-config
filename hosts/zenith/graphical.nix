{
  pkgs,
  config,
  ...
}:
{
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
}
