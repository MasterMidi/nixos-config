{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "/launchers/type-1/style-8.rasi";
    # extraConfig = '''';
  };
}
