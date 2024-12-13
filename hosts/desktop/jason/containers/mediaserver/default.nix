{
  pkgs,
  config,
  lib,
  ...
}: let
  TZ = "Europe/Copenhagen";
  PGID = builtins.toString config.users.groups.users.gid;
  PUID = "1000";
in {
  imports = [./recyclarr];

  environment.systemPackages = with pkgs; [mediainfo];

  # Containers
  virtualisation.oci-containers.compose.mediaserver = {
    enable = true;
		networks.default = {};
    containers = rec {
      # unmanic= {
      #   image = "docker.io/josh5/unmanic:latest";
      #   networking = {
      #     networks = ["default"];
      #     aliases = ["unmanic"];
      #     ports = {
      #       webui = {
      #         host = 8888;
      #         internal = 8888;
      #       };
      #     };
      #   };
      #   ports = ["8888:8888"];
      #   environment= {inherit PUID PGID;};
      #   volumes=[
      #     "/services/media/unmanic/config:/config"
      #     "/home/michael/.temp/data/media:/library"
      #     "/home/michael/.temp/data/cache:/tmp/unmanic"
      #   ];
      #   devices = ["/dev/dri"];# For H/W transcoding using the VAAPI encoder
      # };
      recyclarr={
        image= "ghcr.io/recyclarr/recyclarr";
        autoUpdate = "registry";
        networking= {networks = ["default"];};
        user = "root";
        volumes=[
          "/services/media/recyclarr/config:/config"
          "${./recyclarr/recyclarr.yml}:/config/recyclarr.yml"
        ];
        environment={
          inherit TZ;
        };
      };
      uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["kuma"];
          ports = {
            webui = {
              host = 3001;
              internal = 3001;
            };
          };
        };
        volumes = [
          "/services/media/uptime-kuma/config:/app/data"
        ];
      };
      qbit = {
        image = "ghcr.io/hotio/qbittorrent:latest";
        autoUpdate = "registry";
        networking={
					networks = ["default"];
					aliases = ["qbit"];
					ports = {
            webui = {
              host = 9060;
              internal = 9060;
            };
						torrent = {
							host = 6881;
							internal = 6881;
						};
          };
				};
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
          WEBUI_PORTS = "${toString qbit.networking.ports.webui.host}/tcp,${toString qbit.networking.ports.webui.host}/udp";

					# VPN settings
					VPN_ENABLED="false";
					VPN_CONF="wg0";
					VPN_PROVIDER="generic";
					VPN_LAN_NETWORK="192.168.50.0/24";
					VPN_LAN_LEAK_ENABLED="false";
					VPN_AUTO_PORT_FORWARD="false";
					VPN_KEEP_LOCAL_DNS="true";
					VPN_FIREWALL_TYPE="auto";
					VPN_HEALTHCHECK_ENABLED="false";
					PRIVOXY_ENABLED="false";
					UNBOUND_ENABLED="false";
        };
        volumes = [
					"${./wireguard.mullvad.conf}:/config/wireguard/wg0.conf:ro"
          "/home/michael/.temp/data/torrents:/storage/torrents:rw"
          "/mnt/storage/media/torrents:/cold/torrents:rw"
          "/services/media/qbit/config:/config:rw"
          "/services/media/qbit/webui:/webui:rw"
        ];
				capabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun"];
				extraOptions = [
					"--sysctl=net.ipv4.conf.all.src_valid_mark=1"
				];
      };
      qbit-private = {
        image = "ghcr.io/hotio/qbittorrent:latest";
        autoUpdate = "registry";
        networking={
					networks = ["default"];
					aliases = ["qbit-private"];
					ports = {
            webui = {
              host = 9061;
              internal = 9061;
            };
						torrent = {
							host = 6882;
							internal = 6882;
						};
          };
				};
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
          WEBUI_PORTS = "${toString qbit-private.networking.ports.webui.host}/tcp,${toString qbit-private.networking.ports.webui.host}/udp";

					# VPN settings
					VPN_ENABLED="true";
					VPN_CONF="wg0";
					VPN_PROVIDER="generic";
					VPN_LAN_NETWORK="192.168.50.0/24";
					VPN_LAN_LEAK_ENABLED="false";
					VPN_AUTO_PORT_FORWARD="false";
					VPN_KEEP_LOCAL_DNS="true";
					VPN_FIREWALL_TYPE="auto";
					VPN_HEALTHCHECK_ENABLED="false";
					PRIVOXY_ENABLED="false";
					UNBOUND_ENABLED="false";
        };
        volumes = [
					"${./wireguard.mullvad.conf}:/config/wireguard/wg0.conf:ro"
          "/home/michael/.temp/data/torrents-priv:/storage/torrents-priv:rw"
          "/mnt/storage/media/torrents-priv:/cold/torrents-priv:rw"
          "/services/media/qbit-private/config:/config:rw"
          "/services/media/qbit-private/webui:/webui:rw"
        ];
				capabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun"];
				extraOptions = [
					"--sysctl=net.ipv4.conf.all.src_valid_mark=1"
				];
      };
      prowlarr = {
        image = "ghcr.io/hotio/prowlarr:latest";
        autoUpdate = "registry";
        networking={
					networks = ["default"];
					aliases = ["prowlarr"];
					ports = {
						webui = {
							host = 9090;
							internal = 9696;
						};
					};
				};
        environment = {
          inherit PGID PUID TZ;
        };
        volumes = [
          "/services/media/prowlarr/config:/config:rw"
        ];
      };
      qbitmanage = {
        image = "ghcr.io/hotio/qbitmanage:nightly";
        autoUpdate = "registry";
        networking.networks = ["default"];
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
          QBT_DRY_RUN = "false";
          QBT_SCHEDULE = "60";
        };
        volumes = [
          "/var/lib/qbitmanage/config:/config:rw"
          # "${./qbitmanage.config.yml}:/config/config.yml:ro"
          "/home/michael/.temp/data/torrents:/storage/torrents:rw"
          "/mnt/storage/media/torrents:/cold/torrents:rw"
        ];
        dependsOn = ["qbit"];
      };
      # qbitmanage-private = {
      #   image = "ghcr.io/hotio/qbitmanage:nightly";
      #   autoUpdate = "registry";
      #   networking.networks = ["default"];
      #   environment = {
      #     inherit PGID PUID TZ;
      #     UMASK = "002";
      #     QBT_DRY_RUN = "false";
      #     QBT_SCHEDULE = "60";
      #   };
      #   volumes = [
      #     "/services/media/qbitmanage-private/config:/config:rw"
      #     # "${./qbitmanage.private.config.yml}:/config/config.yml:ro"
      #     "/home/michael/.temp/data/torrents-priv:/storage/torrents-priv:rw"
      #   ];
      #   dependsOn = ["qbit-private"];
      # };
      fail2ban = {
        image = "lscr.io/linuxserver/fail2ban:latest";
        autoUpdate = "registry";
        networking.useHostNetwork = true;
        environment = {
          inherit PGID PUID TZ;
        };
        volumes = [
          "/services/media/fail2ban/config:/config"
          "/var/log:/var/log:ro"
          "/services/media/jellyfin/config/log:/remotelogs/jellyfin:ro"
          "/services/media/prowlarr/config/logs:/remotelogs/prowlarr:ro"
          "/services/media/radarr/config/logs:/remotelogs/radarr:ro"
          "/services/media/sonarr/config/logs:/remotelogs/sonarr:ro"
        ];
        capabilities = ["NET_ADMIN" "NET_RAW"];
        devices = ["/dev/net/tun"];
      };
      titlecardmaker = {
        image = "docker.io/collinheist/titlecardmaker:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["titlecardmaker"];
        };
        environment = {
          inherit PGID PUID;
          TCM_MISSING = "/config/missing.yml";
          TCM_FREQUENCY = "5m";
        };
        volumes = [
          "/services/media/tcm/config:/config"
          # "${./tcm.config.yaml}:/config/preferences.yml:ro"
          "/services/media/tcm/log:/maker/logs"
          "/home/michael/.temp/data/media:/storage/media:rw"
        ];
      };
      homarr = {
        image = "ghcr.io/ajnart/homarr:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["homarr"];
          ports = {
            webui = {
              host = 9000;
              internal = 7575;
            };
          };
        };
        volumes = [
          "/services/media/homarr/configs:/app/data/configs"
          "/services/media/homarr/data:/data"
          "/services/media/homarr/icons:/app/public/icons"
        ];
      };
      bazarr = {
        image = "lscr.io/linuxserver/bazarr:development";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["bazarr"];
          ports = {
            webui = {
              host = 9080;
              internal = 6767;
              protocol = "tcp";
            };
          };
        };
        environment = {
          inherit PGID PUID TZ;
          VERBOSITY = "-vv";
        };
        volumes = [
          "/home/michael/.temp/data/media:/storage/media:rw"
          "/mnt/storage/media/media:/cold/media:rw"
          "/services/media/bazarr/config:/config:rw"
        ];
      };
      jellyfin = {
        image = "lscr.io/linuxserver/jellyfin:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["jellyfin"];
          ports = {
            webui = {
              host = 9010;
              internal = 8096;
              protocol = "tcp";
            };
          };
        };
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
        devices = ["/dev/dri"];
      };
      jellyseerr = {
        image = "ghcr.io/hotio/jellyseerr";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["jellyseerr"];
          ports = {
            webui = {
              host = 5055;
              internal = 5055;
            };
          };
        };
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
        };
        volumes = [
          "/services/media/jellyseerr/config:/app/config:rw"
        ];
      };
      radarr = {
        image = "lscr.io/linuxserver/radarr:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["radarr"];
          ports = {
            webui = {
              host = 9030;
              internal = 7878;
              protocol = "tcp";
            };
          };
        };
        environment = {
          inherit PGID PUID TZ;
        };
        volumes = [
          "/home/michael/.temp/data:/storage:rw"
          "/mnt/storage/media:/cold:rw"
          "/services/media/radarr/config:/config:rw"
        ];
      };
      sonarr = {
        image = "ghcr.io/hotio/sonarr:nightly";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["sonarr"];
          ports = {
            webui = {
							host = 9040;
							internal = 8989;
							protocol = "tcp";
          	};
					};
        };
        environment = {
          inherit PGID PUID TZ;
          UMASK = "002";
        };
        volumes = [
          "/home/michael/.temp/data:/storage:rw"
          "/mnt/storage/media:/cold:rw"
          "/services/media/sonarr/config:/config:rw"
        ];
      };
      whisper = {
        image = "docker.io/onerahmet/openai-whisper-asr-webservice:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["openai-whisper"];
          ports = {
            webui = {
              host = 9999;
              internal = 9000;
              protocol = "tcp";
            };
          };
        };
        environment = {
          "ASR_ENGINE" = "faster_whisper";
          "ASR_MODEL" = "large-v3";
          "ASR_MODEL_PATH" = "/data/whisper";
        };
        volumes = [
          "/services/media/data/whisper:/data/whisper:rw"
        ];
        devices = ["/dev/dri"];
        extraOptions = [
          "--group-add=${builtins.toString config.users.groups.render.gid}"
        ];
      };
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["flaresolverr"];
          ports = {
            webui = {
              host = 8191;
              internal = 8191;
            };
          };
        };
        environment = {
          LOG_LEVEL="info";
        };
      };
    };
  };

  # prometheus exporters
  services.prometheus.exporters = {
    exportarr-sonarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:${config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.ports.webui.host |> builtins.toString}";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.SONARR_API_KEY.path;
      port = config.virtualisation.oci-containers.compose.mediaserver.containers.sonarr.networking.ports.webui.host + 1;
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
