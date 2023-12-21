{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "$BROWSER";
    theme = "/launchers/type-1/style-8.rasi";
    extraConfig = { };
  };

  # home.file.".config/rofi/gamelauncher" = {};

  # environment.systemPackages = with pkgs; [
  #   (pkgs.writeShellScriptBin "gamelauncher" (builtins.readFile ./gamelauncher/gamelauncher.sh))
  # ];
}
