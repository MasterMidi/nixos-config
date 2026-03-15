{
  pkgs,
  config,
  ...
}:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Display manager.
  services.displayManager.gdm = {
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

  services.gvfs.enable = true; # for nautlius to work with ttrash and network shares

}
