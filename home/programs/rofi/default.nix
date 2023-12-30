{pkgs, ...}: let
  config = ".config/rofi";
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    terminal = "$BROWSER";
    theme = "/theme.rasi";
    extraConfig = {};
  };

  home.file = {
    "${config}/theme.rasi".source = ./applauncher/theme.rasi;

    "${config}/wallpaper-switcher.sh".source = ./wallpaper-switcher/wall-select.sh;
    "${config}/wallpaper-switcher.rasi".source = ./wallpaper-switcher/theme.rasi;

    "${config}/gamelauncher.sh".source = ./gamelauncher/gamelauncher.sh;
    "${config}/gamelauncher.rasi".source = ./gamelauncher/theme.rasi;
  };
}
