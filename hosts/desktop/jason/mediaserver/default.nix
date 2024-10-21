{
  pkgs,
  config,
  ...
}: let
  TZ = "Europe/Copenhagen";
  PGID = builtins.toString config.users.groups.users.gid;
  PUID = "1000";
in {
  environment.systemPackages = with pkgs; [mediainfo];

  # Runtime
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
      # network_interface = "podman0";
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Firewall
  networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];

  # Containers
  virtualisation.oci-containers.compose.mediaserver = {
    enable = true;
    networks = ["default"];
    containers = {
      gluetun = {
        image = "docker.io/qmcgaw/gluetun:latest";
        networks = ["mediaserver-default"];
        environment = {
          VPN_SERVICE_PROVIDER = "mullvad";
        };
        ports =
          [
            "9090:9696/tcp"
          ]
          config.virtualisation.oci-containers.compose.mediaserver.containers.qbit.ports
          ++ config.virtualisation.oci-containers.compose.mediaserver.containers.qbit-private.ports;
        extraOptions = [
          "--device=/dev/net/tun"
          "--cap-add=NET_ADMIN"
          "--network-alias=gluetun"
          # "--privileged"
        ];
      };
      qbit = rec {
        image = "ghcr.io/hotio/qbittorrent:latest";
        networks = ["container:mediaserver-gluetun"];
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
          WEBUI_PORTS = "9060";
        };
        volumes = [
          "/home/michael/.temp/data/torrents:/storage/torrents:rw"
          "/mnt/storage/media/torrents:/cold/torrents:rw"
          "/services/media/qbit/config:/config:rw"
          "/services/media/qbit/webui:/webui:rw"
        ];
        ports = [
          "${environment.WEBUI_PORTS}:${environment.WEBUI_PORTS}/tcp"
          "6881:6881/tcp"
          "6881:6881/udp"
        ];
        dependsOn = ["gluetun"];
      };
      qbit-private = rec {
        image = "ghcr.io/hotio/qbittorrent:latest";
        networks = ["container:mediaserver-gluetun"];
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
          WEBUI_PORTS = "9061";
        };
        volumes = [
          "/home/michael/.temp/data/torrents-priv:/storage/torrents-priv:rw"
          "/mnt/storage/media/torrents-priv:/cold/torrents-priv:rw"
          "/services/media/qbit-private/config:/config:rw"
          "/services/media/qbit-private/webui:/webui:rw"
        ];
        ports = [
          "${environment.WEBUI_PORTS}:${environment.WEBUI_PORTS}/tcp"
          "6882:6882/tcp"
          "6882:6882/udp"
        ];
        dependsOn = ["gluetun"];
      };
      prowlarr = {
        image = "ghcr.io/hotio/prowlarr:latest";
        networks = ["container:mediaserver-gluetun"];
        environment = {
          inherit PGID PUID TZ;
        };
        volumes = [
          "/services/media/prowlarr/config:/config:rw"
        ];
        ports = [
          "9696:9696/tcp"
        ];
      };
      qbitmanage = {
        image = "ghcr.io/hotio/qbitmanage:nightly";
        networks = ["mediaserver-default"];
        # user = "${builtins.toString config.users.users."${cfg.user}".uid}:${builtins.toString config.users.groups."${cfg.group}".gid}";
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
          QBT_DRY_RUN = "false";
          QBT_SCHEDULE = "60";
        };
        volumes = [
          "/var/lib/qbitmanage/config:/config"
          "${./qbitmanage.config.yml}:/config/config.yml:ro"
          "/home/michael/.temp/data/torrents:/storage/torrents"
          "/mnt/storage/media/torrents:/cold/torrents"
        ];
        # extraOptions = ["--network=host"];
      };
      bazarr = {
        image = "lscr.io/linuxserver/bazarr:development";
        networks = ["mediaserver-default"];
        environment = {
          inherit PGID PUID TZ;
        };
        volumes = [
          "/home/michael/.temp/data/media:/storage/media:rw"
          "/mnt/storage/media/media:/cold/media:rw"
          "/services/media/bazarr/config:/config:rw"
        ];
        ports = [
          "9080:6767/tcp"
        ];
        extraOptions = [
          "--network-alias=bazarr"
        ];
      };
      jellyfin = {
        image = "lscr.io/linuxserver/jellyfin:latest";
        networks = ["mediaserver-default"];
        environment = {
          inherit PGID PUID TZ;
          DOCKER_MODS = "ghcr.io/jumoog/intro-skipper"; # fix intro skipper file permission issues for linuxserver image
        };
        volumes = [
          "/home/michael/.temp/data/media:/storage/media:rw"
          "/mnt/storage/media/media:/cold/media:rw"
          "/services/media/jellyfin/config:/config:rw"
          "/services/media/jellyfin/transcodes:/transcodes:rw"
        ];
        ports = [
          "9010:8096/tcp"
        ];
        extraOptions = [
          "--device=/dev/dri:/dev/dri"
          # "--group-add=${builtins.toString config.users.groups.render.gid}"
          "--network-alias=jellyfin"
        ];
      };
      jellyseerr = {
        image = "ghcr.io/hotio/jellyseerr";
        networks = ["mediaserver-default"];
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
        };
        volumes = [
          "/services/media/jellyseerr/config:/app/config:rw"
        ];
        ports = [
          "5055:5055"
        ];
        extraOptions = [
          "--network-alias=jellyseerr"
        ];
      };
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        networks = ["mediaserver-default"];
        environment = {
          inherit PGID PUID TZ;
        };
        volumes = [
          "/home/michael/.temp/data:/storage:rw"
          "/mnt/storage/media:/cold:rw"
          "/services/media/radarr/config:/config:rw"
        ];
        ports = [
          "9030:7878/tcp"
        ];
        extraOptions = [
          "--network-alias=radarr"
        ];
      };
      sonarr = {
        image = "ghcr.io/hotio/sonarr:nightly";
        networks = ["mediaserver-default"];
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
        };
        volumes = [
          "/home/michael/.temp/data:/storage:rw"
          "/mnt/storage/media:/cold:rw"
          "/services/media/sonarr/config:/config:rw"
        ];
        ports = [
          "9040:8989/tcp"
        ];
        extraOptions = [
          "--network-alias=sonarr"
        ];
      };
      whisper = {
        image = "onerahmet/openai-whisper-asr-webservice:latest";
        networks = ["mediaserver-default"];
        environment = {
          "ASR_ENGINE" = "faster_whisper";
          "ASR_MODEL" = "large-v3";
          "ASR_MODEL_PATH" = "/data/whisper";
        };
        volumes = [
          "/services/media/data/whisper:/data/whisper:rw"
        ];
        ports = [
          "9999:9000/tcp"
        ];
        extraOptions = [
          "--device=/dev/dri:/dev/dri"
          "--group-add=${builtins.toString config.users.groups.render.gid}"
          "--network-alias=openai-whisper"
        ];
      };
    };
  };

  # prometheus exporters
  services.prometheus.exporters = {
    exportarr-sonarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:9040";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.SONARR_API_KEY.path;
      port = 9041;
    };

    exportarr-radarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:9030";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.RADARR_API_KEY.path;
      port = 9031;
    };

    exportarr-bazarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:9080";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.BAZARR_API_KEY.path;
      port = 9081;
    };
  };
}
