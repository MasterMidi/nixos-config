{ pkgs, modules, ... }:
{
  imports = [
    modules.options.compose

    ./autobrr.nix
    ./bazarr.nix
    ./bitmagnet.nix
    ./glance.nix
    ./gotify.nix
    ./homarr.nix
    ./immich.nix
    ./jdupes.nix
    ./jellyfin
    ./jellyseerr.nix
    ./karakeep.nix
    ./mealie.nix
    ./newt.nix
    ./open-webui.nix
    ./paperless.nix
    ./penpot.nix
    ./pocketid.nix
    ./prefetcher.nix
    ./prowlarr.nix
    ./qbit
    ./radarr.nix
    ./recyclarr.nix
    ./scrutiny.nix
    ./searxng.nix
    ./sonarr.nix
    ./sterling-pdf.nix
    # ./title-card-maker.nix
    # ./traefik.nix
    ./uptime-kuma.nix
  ];

  environment.systemPackages = with pkgs; [ mediainfo ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 512; # fix a lot of filehandles from qbittorrent and other services simultaneously
  };

  virtualisation.oci-containers.compose.mediaserver.containers.subgen = {
    image = "docker.io/mccloud/subgen:cpu";
    autoUpdate = "registry";
    networking = {
      networks = [ "default" ];
      aliases = [ "subgen" ];
    };
    environment = {
      TRANSCRIBE_DEVICE = "cpu";
      WHISPER_MODEL = "large-v3";
    };
    volumes = [
      "/mnt/ssd/services/subgen/data/models:/subgen/models:rw"
    ];
  };
}
