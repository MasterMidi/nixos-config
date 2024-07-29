{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../shared/home/secrets
  ];

  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.11";

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  services = {
    swayosd = {
      enable = true;
      display = "eDP-1";
    };
  };

  wayland.windowManager.hyprland.settings = {
    monitor = ["eDP-1, 2240x1400@60, 0x0, 1"];
    bind = [
      ",XF86AudioMute, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ",XF86AudioVolumeDown, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
      ",XF86AudioVolumeUp, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
      ",XF86AudioMicMute, exec, ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle"
      ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl1 set 10%-"
      ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d amdgpu_bl1 set +10%"
    ];
  };
}
