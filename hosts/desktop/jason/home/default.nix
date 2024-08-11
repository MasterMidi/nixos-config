{inputs, ...}: {
  imports = [
    ../../shared/home/secrets
  ];

  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.05";

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  services = {
    swayosd = {
      enable = true;
      # display = "eDP-1";
    };
  };

  wayland.windowManager.hyprland.settings = {
    monitor = [
      # "HDMI-A-2, 1920x1080@60, 0x230, 0.93" # matches the dpi, but creates a gap around apps and poor font rendering
      "HDMI-A-1, 1920x1080@60, 0x275, 1"
      "HDMI-A-2, 1920x1080@60, 0x275, 1"
      "HDMI-A-3, 1920x1080@60, 0x275, 1"
      "DP-1, 3440x1440@144, 1920x0, 1, vrr, 1"
      "DP-2, 3440x1440@144, 1920x0, 1, vrr, 1"
      "DP-3, disable"
    ];
  };
}
