{ pkgs, ... }:
{
  imports = [
    ../common
  ];

  home-manager.users.michael = {
    imports = [
      ./programs
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono NF" ];
        sansSerif = [ "Inter" ];
      };
    };

    services.mpris-proxy.enable = true; # media player mpris proxy
    services.playerctld.enable = true; # media player control

    home.packages = with pkgs; [
      devenv

      prusa-slicer

      # Tools
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
