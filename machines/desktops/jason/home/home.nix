{ pkgs, ... }:
{
  home.stateVersion = "23.05";

  services = {
    swayosd = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    # Gaming
    r2modman
    heroic
    adwsteamgtk
    # prismlauncher
    # modrinth-app

    # Media
    jellyfin-media-player
  ];
}
