{ pkgs, self, ... }:
{
  imports = [
    self.modules.nixos.compose

    # # ./autobrr.nix
    ./bazarr.nix
    # # ./bitmagnet.nix
    # # ./glance.nix
    # # ./gotify.nix
    # # ./homarr.nix
    ./immich.nix
    ./jdupes.nix
    # # ./jellyfin
    # # ./jellyseerr.nix
    # # ./karakeep.nix
    # ./mealie.nix
    ./newt.nix
    # # ./open-webui.nix
    ./paperless.nix
    # # ./penpot.nix
    # # ./pocketid.nix
    ./prefetcher.nix
    # # ./prowlarr.nix
    ./qbit
    # # ./radarr.nix
    # # ./recyclarr.nix
    # # ./scrutiny.nix
    ./searxng.nix
    # # ./sonarr.nix
    # # ./sterling-pdf.nix
    # # ./uptime-kuma.nix
  ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 8192; # fix a lot of filehandles from qbittorrent and other services simultaneously
    "fs.inotify.max_user_watches" = 524288;
  };

  environment.systemPackages = with pkgs; [
    mediainfo
    nvidia-container-toolkit
  ];

  # virtualisation.oci-containers.compose.mediaserver.containers.subgen = {
  #   image = "docker.io/mccloud/subgen:cpu";
  #   autoUpdate = "registry";
  #   networking = {
  #     networks = [ "default" ];
  #     aliases = [ "subgen" ];
  #   };
  #   environment = {
  #     TRANSCRIBE_DEVICE = "cpu";
  #     WHISPER_MODEL = "large-v3";
  #   };
  #   volumes = [
  #     "/mnt/ssd/services/subgen/data/models:/subgen/models:rw"
  #   ];
  # };
}
