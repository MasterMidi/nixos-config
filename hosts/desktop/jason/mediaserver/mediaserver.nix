# Auto-generated using compose2nix v0.2.2-pre.
{
  pkgs,
  lib,
  config,
  ...
}: let
  Timezone = "Europe/Copenhagen";
  PGID = builtins.toString config.users.groups.users.gid;
  PUID = "1000";
in {
  # Runtime
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
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
  virtualisation.oci-containers.containers."bazarr" = {
    image = "lscr.io/linuxserver/bazarr:development";
    environment = {
      "PGID" = PGID;
      "PUID" = PUID;
      "TZ" = Timezone;
    };
    volumes = [
      "/home/michael/.temp/data/media:/storage/media:rw"
      "/mnt/storage/media/media:/cold/media:rw"
      "/services/media/bazarr/config:/config:rw"
    ];
    ports = [
      "9080:6767/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=bazarr"
      "--network=mediaserver_default"
    ];
  };
  systemd.services."podman-bazarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-mediaserver_default.service"
    ];
    requires = [
      "podman-network-mediaserver_default.service"
    ];
    partOf = [
      "podman-compose-mediaserver-root.target"
    ];
    wantedBy = [
      "podman-compose-mediaserver-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/home/michael/.temp/data/media"
      "/mnt/storage/media/media"
      "/services/media/bazarr/config"
    ];
  };
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "lscr.io/linuxserver/jellyfin:latest";
    environment = {
      inherit PGID PUID;
      "TZ" = Timezone;
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
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/dri:/dev/dri"
      # "--group-add=${builtins.toString config.users.groups.render.gid}"
      "--network-alias=jellyfin"
      "--network=mediaserver_default"
    ];
  };
  systemd.services."podman-jellyfin" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-mediaserver_default.service"
    ];
    requires = [
      "podman-network-mediaserver_default.service"
    ];
    partOf = [
      "podman-compose-mediaserver-root.target"
    ];
    wantedBy = [
      "podman-compose-mediaserver-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/home/michael/.temp/data/media"
      "/mnt/storage/media/media"
      "/services/media/jellyfin/certs"
      "/services/media/jellyfin/config"
      "/services/media/jellyfin/transcodes"
      "/services/media/jellyfin/web"
    ];
  };
  virtualisation.oci-containers.containers."qbit-media" = {
    image = "ghcr.io/hotio/qbittorrent:latest";
    environment = {
      "PGID" = PGID;
      "PUID" = PUID;
      "TZ" = Timezone;
      "UMASK" = "002";
      "WEBUI_PORTS" = "9060";
    };
    volumes = [
      "/home/michael/.temp/data/torrents:/storage/torrents:rw"
      "/mnt/storage/media/torrents:/cold/torrents:rw"
      "/services/media/qbit/config:/config:rw"
      "/services/media/qbit/webui:/webui:rw"
    ];
    ports = [
      "9060:9060/tcp"
      "6881:6881/tcp"
      "6881:6881/udp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=qbittorrent"
      "--network=mediaserver_default"
    ];
  };
  systemd.services."podman-qbit-media" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-mediaserver_default.service"
    ];
    requires = [
      "podman-network-mediaserver_default.service"
    ];
    partOf = [
      "podman-compose-mediaserver-root.target"
    ];
    wantedBy = [
      "podman-compose-mediaserver-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/home/michael/.temp/data/torrents"
      "/mnt/storage/media/torrents"
      "/services/media/qbit/config"
      "/services/media/qbit/webui"
    ];
  };
  virtualisation.oci-containers.containers."qbit-media-private" = {
    image = "ghcr.io/hotio/qbittorrent:latest";
    environment = {
      "PGID" = PGID;
      "PUID" = PUID;
      "TZ" = Timezone;
      "UMASK" = "002";
      "WEBUI_PORTS" = "9061";
    };
    volumes = [
      "/home/michael/.temp/data/torrents-priv:/storage/torrents-priv:rw"
      "/mnt/storage/media/torrents-priv:/cold/torrents-priv:rw"
      "/services/media/qbit-private/config:/config:rw"
      "/services/media/qbit-private/webui:/webui:rw"
    ];
    ports = [
      "9061:9061/tcp"
      "6882:6882/tcp"
      "6882:6882/udp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=qbittorrent-private"
      "--network=mediaserver_default"
    ];
  };
  systemd.services."podman-qbit-media-private" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-mediaserver_default.service"
    ];
    requires = [
      "podman-network-mediaserver_default.service"
    ];
    partOf = [
      "podman-compose-mediaserver-root.target"
    ];
    wantedBy = [
      "podman-compose-mediaserver-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/home/michael/.temp/data/torrents-priv"
      "/mnt/storage/media/torrents-priv"
      "/services/media/qbit-private/config"
      "/services/media/qbit-private/webui"
    ];
  };
  virtualisation.oci-containers.containers."radarr" = {
    image = "lscr.io/linuxserver/radarr:latest";
    environment = {
      "PGID" = PGID;
      "PUID" = PUID;
      "TZ" = Timezone;
    };
    volumes = [
      "/home/michael/.temp/data:/storage:rw"
      "/mnt/storage/media:/cold:rw"
      "/services/media/radarr/config:/config:rw"
    ];
    ports = [
      "9030:7878/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=radarr"
      "--network=mediaserver_default"
    ];
  };
  systemd.services."podman-radarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-mediaserver_default.service"
    ];
    requires = [
      "podman-network-mediaserver_default.service"
    ];
    partOf = [
      "podman-compose-mediaserver-root.target"
    ];
    wantedBy = [
      "podman-compose-mediaserver-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/home/michael/.temp/data"
      "/mnt/storage/media"
      "/services/media/radarr/config"
    ];
  };
  virtualisation.oci-containers.containers."sonarr" = {
    image = "ghcr.io/hotio/sonarr:nightly";
    environment = {
      "PGID" = PGID;
      "PUID" = PUID;
      "TZ" = Timezone;
      "UMASK" = "002";
    };
    volumes = [
      "/home/michael/.temp/data:/storage:rw"
      "/mnt/storage/media:/cold:rw"
      "/services/media/sonarr/config:/config:rw"
    ];
    ports = [
      "9040:8989/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr"
      "--network=mediaserver_default"
    ];
  };
  systemd.services."podman-sonarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-mediaserver_default.service"
    ];
    requires = [
      "podman-network-mediaserver_default.service"
    ];
    partOf = [
      "podman-compose-mediaserver-root.target"
    ];
    wantedBy = [
      "podman-compose-mediaserver-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/home/michael/.temp/data"
      "/mnt/storage/media"
      "/services/media/sonarr/config"
    ];
  };
  virtualisation.oci-containers.containers."whisper" = {
    image = "onerahmet/openai-whisper-asr-webservice:latest";
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
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/dri:/dev/dri"
      "--group-add=${builtins.toString config.users.groups.render.gid}"
      "--network-alias=openai-whisper"
      "--network=mediaserver_default"
    ];
  };
  systemd.services."podman-whisper" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "no";
    };
    after = [
      "podman-network-mediaserver_default.service"
    ];
    requires = [
      "podman-network-mediaserver_default.service"
    ];
    partOf = [
      "podman-compose-mediaserver-root.target"
    ];
    wantedBy = [
      "podman-compose-mediaserver-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/services/media/data/whisper"
    ];
  };

  # Networks
  systemd.services."podman-network-mediaserver_default" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f mediaserver_default";
    };
    script = ''
      podman network inspect mediaserver_default || podman network create mediaserver_default
    '';
    partOf = ["podman-compose-mediaserver-root.target"];
    wantedBy = ["podman-compose-mediaserver-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-mediaserver-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
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
