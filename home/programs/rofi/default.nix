{ pkgs, ... }:
let
  config = ".config/rofi";
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "$BROWSER";
    theme = "/theme.rasi";
    extraConfig = { };
  };

  home.file = {
    "${config}/theme.rasi".source = ./applauncher/theme.rasi;
    "${config}/gamelauncher.sh".source = ./gamelauncher/gamelauncher.sh;
    "${config}/gamelauncher.rasi".source = ./gamelauncher/gamelauncher.rasi;
  };

  # environment.systemPackages = with pkgs; [
  #   (pkgs.writeShellScriptBin "gamelauncher" (builtins.readFile ./gamelauncher/gamelauncher.sh))
  # ];
}
