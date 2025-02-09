{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "qbit-private.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.qbit-private = {};
    containers = rec {
      qbit-private = rec {
        image = "ghcr.io/hotio/qbittorrent:release-5.0.2";
        autoUpdate = "registry";
        networking={
					networks = ["default:ip=10.89.1.90"]; # dont support multiple networks because of vpn setup it seems
					aliases = ["qbit-private"];
					ports = {
            webui = {
              host = 9061;
              internal = 9061;
            };
						bittorrent-tcp = {
							host = 21783;
							internal = 21783;
              protocol = "tcp";
						};
            bittorrent-udp = {
							host = 21783;
							internal = 21783;
              protocol = "udp";
						};
          };
				};
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
          UMASK = "002";
          WEBUI_PORTS = "${toString qbit-private.networking.ports.webui.host}/tcp,${toString qbit-private.networking.ports.webui.host}/udp";

					# VPN settings
					VPN_ENABLED="true";
					VPN_CONF="wg0";
					VPN_PROVIDER="generic";
					VPN_LAN_NETWORK="192.168.1.0/24";
					VPN_LAN_LEAK_ENABLED="false";
					# VPN_AUTO_PORT_FORWARD="false";
					VPN_KEEP_LOCAL_DNS="true";
					VPN_FIREWALL_TYPE="auto";
					VPN_HEALTHCHECK_ENABLED="false";
					PRIVOXY_ENABLED="true";
					UNBOUND_ENABLED="false";
        };
        volumes = [
					"${./configs/wireguard.airvpn.conf}:/config/wireguard/wg0.conf:ro"
          "/mnt/hdd/torrents/private:/storage/torrents/private:rw"
          "/mnt/ssd/services/qbit-private/config:/config:rw"
        ];
				capabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun"];
				extraOptions = [
					"--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          "--add-host=${builtins.head cross-seed-private.networking.aliases}:10.89.1.101" # add cross seed hostname manually because of vpn
				];
        labels = [
          # Reverse proxy config. Passed on: https://github.com/qbittorrent/qBittorrent/wiki/Traefik-Reverse-Proxy-for-Web-UI
          "traefik.enable=true"      

          # Router Configuration
          "traefik.http.routers.qb-private.entryPoints=local"
          "traefik.http.routers.qb-private.rule=Host(`qbit-private.mgrlab.dk`)"
          
          # Security Headers
          "traefik.http.middlewares.qb-headers-private.headers.customRequestHeaders.X-Frame-Options=SAMEORIGIN"
          "traefik.http.middlewares.qb-headers-private.headers.customRequestHeaders.Referer="
          "traefik.http.middlewares.qb-headers-private.headers.customRequestHeaders.Origin="
          
          # Apply headers middleware
          "traefik.http.routers.qb-private.middlewares=qb-headers-private"
          
          # Service Configuration
          "traefik.http.services.qb-private.loadbalancer.server.port=${toString networking.ports.webui.host}"
          "traefik.http.services.qb-private.loadbalancer.passHostHeader=false"

          # Monitoring
          "kuma.qbit.http.name=Qbittorrent Private"
          "kuma.qbit.http.url=https://qbit-private.mgrlab.dk"
        ];
      };

      cross-seed-private = {
        image= "ghcr.io/cross-seed/cross-seed:6";
        user = "1000:100";
        commands = ["daemon"];
        networking = {
          networks = ["default:ip=10.89.1.101"];
          aliases = ["cross-seed-private"];
          ports = {
            http = {
              host = 2468;
              internal = 2468;
            };
          };
        };
        volumes = [
          "/mnt/ssd/services/cross-seed-private/config:/config:rw" # config location
          "/mnt/ssd/services/qbit-private/config/data/BT_backup:/mnt/ssd/services/qbit-private/config/data/BT_backup:ro" # readonly access to torrent files for qbit
          "/mnt/hdd/torrents/private:/storage/torrents/private:rw" # root folder for torrents in qbit
        ];
      };

      # qbitmanage-private = {
      #   image = "ghcr.io/hotio/qbitmanage:nightly";
      #   autoUpdate = "registry";
      #   networking.networks = ["qbit-private"];
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

      # systemd service to periodically (every hour) remove eall torrents with the "cross-seed-tmp" tag. This is cleanup of torrents moved from public qbit to private for cross-seeding
    };
  };
}