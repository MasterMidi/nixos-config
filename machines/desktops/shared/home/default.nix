{ pkgs, ... }:
{
  home-manager.users.michael = {
    imports = [
      ./hyprland
      ./programs
      ./services
      ./theme
      ./default-apps.nix
      ./secrets.nix
    ];

    services.mpris-proxy.enable = true; # media player mpris proxy
    services.playerctld.enable = true; # media player control

    home.packages = with pkgs; [
      playerctl

      # Tools
      # ventoy-full
      xdg-utils
      envsubst
      jq
      tldr
      hyprpicker
      libnotify
      trash-cli
      pix
      xfce.mousepad
      obsidian

      # misc
      pipes-rs

      # Fonts
      nerd-fonts.jetbrains-mono
      inter
    ];
  };
}
