{
  pkgs,
  config,
  lib,
  ...
}: let
  PGID = builtins.toString config.users.groups.users.gid;
  PUID = "1000";
in {
  imports = [
    ./authentik.nix
    ./autobrr.nix
    ./bazarr.nix
    ./bitmagnet.nix
    ./glance.nix
    ./gotify.nix
    ./hoarder.nix
    ./homarr.nix
    ./immich.nix
    ./jellyfin
    ./jellyseerr.nix
    ./newt.nix
    ./prowlarr.nix
    ./qbit
    ./radarr.nix
    ./recyclarr.nix
    ./scrutiny.nix
    ./searxng.nix
    ./sonarr.nix
    # ./title-card-maker.nix
    ./traefik.nix
    ./uptime-kuma.nix
  ];

  environment.systemPackages = with pkgs; [mediainfo];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 512;
  };

  # Containers
  virtualisation.oci-containers.compose.mediaserver = {
    enable = true;
    networks.default = {};
    containers = rec {
      # titlecardmaker = {
      #   image = "docker.io/collinheist/titlecardmaker:latest";
      #   autoUpdate = "registry";
      #   networking = {
      #     networks = ["default"];
      #     aliases = ["titlecardmaker"];
      #   };
      #   environment = {
      #     inherit PGID PUID;
      #     TCM_MISSING = "/config/missing.yml";
      #     TCM_FREQUENCY = "5m";
      #   };
      #   volumes = [
      #     "/services/media/tcm/config:/config"
      #     # "${./tcm.config.yaml}:/config/preferences.yml:ro"
      #     "/services/media/tcm/log:/maker/logs"
      #     "/home/michael/.temp/data/media:/storage/media:rw"
      #   ];
      # };

      # whisper = {
      #   image = "docker.io/onerahmet/openai-whisper-asr-webservice:latest";
      #   autoUpdate = "registry";
      #   networking = {
      #     networks = ["default"];
      #     aliases = ["openai-whisper"];
      #     ports = {
      #       webui = {
      #         host = 9999;
      #         internal = 9000;
      #         protocol = "tcp";
      #       };
      #     };
      #   };
      #   environment = {
      #     "ASR_ENGINE" = "faster_whisper";
      #     "ASR_MODEL" = "large-v3";
      #     "ASR_MODEL_PATH" = "/data/whisper";
      #   };
      #   volumes = [
      #     "/services/media/data/whisper:/data/whisper:rw"
      #   ];
      #   devices = ["/dev/dri"];
      #   extraOptions = [
      #     "--group-add=${builtins.toString config.users.groups.render.gid}"
      #   ];
      # };
    };
  };
}
