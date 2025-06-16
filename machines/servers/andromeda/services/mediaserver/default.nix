{ pkgs, modules, ... }:
{
  imports = [
    modules.options.compose

    ./authentik.nix
    ./autobrr.nix
    ./bazarr.nix
    ./bitmagnet.nix
    ./glance.nix
    ./gotify.nix
    ./hoarder.nix
    ./homarr.nix
    ./immich.nix
    ./jdupes.nix
    ./jellyfin
    ./jellyseerr.nix
    # ./mealie.nix
    ./newt.nix
    ./paperless.nix
    ./pocketid.nix
    ./prowlarr.nix
    ./qbit
    ./radarr.nix
    ./recyclarr.nix
    ./scrutiny.nix
    ./searxng.nix
    ./sonarr.nix
    # ./sterling-pdf.nix
    # ./title-card-maker.nix
    ./traefik.nix
    ./uptime-kuma.nix
  ];

  environment.systemPackages = with pkgs; [ mediainfo ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 512; # fix a lot of filehandles from qbittorrent and other services simultaneously
  };
}
