{config,pkgs,...}:
let
  script = pkgs.writeShellScriptBin "qbit-script" ''
# Required arguments
INFOHASH="$1"
TORRENT_ROOT_PATH="$2"

# Configuration
CROSS_SEED_API_KEY="ef5d258cb193893abc952a7ee4d3614c73e060daf8411819"
CROSS_SEED_URL="http://cross-seed-public:2468/api/webhook"
PRIVATE_TORRENT_BASE="/storage/torrents/private/cross-seed-tmp"
QBITTORRENT_PUBLIC_HOST="http://localhost:9060"
QBITTORRENT_PRIVATE_HOST="http://qbit-private:9061"
QBITTORRENT_USERNAME="michael"
QBITTORRENT_PASSWORD="Servurb42"
COOKIE_FILE_PUBLIC=$(mktemp)
COOKIE_FILE_PRIVATE=$(mktemp)

# Validate input
if [ $# -ne 2 ]; then
    echo "Usage: $0 \<infohash\> \<torrent_root_path\>"
    exit 1
fi

# Extract torrent folder name
TORRENT_FOLDER=$(basename "$TORRENT_ROOT_PATH")

# Trigger cross-seed webhook
CROSS_SEED_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -XPOST "$CROSS_SEED_URL?apikey=$CROSS_SEED_API_KEY" --data-urlencode "infoHash=$INFOHASH")

# Check if cross-seed was successful
if [ "$CROSS_SEED_RESPONSE" -eq 200 ]; then
    # Create destination directory
    mkdir -p "$PRIVATE_TORRENT_BASE/$TORRENT_FOLDER"

    # Hardlink files
    cp -al "$TORRENT_ROOT_PATH"/* "$PRIVATE_TORRENT_BASE/$TORRENT_FOLDER/"

    # Get qBittorrent authentication cookie
    curl -s -c $COOKIE_FILE_PUBLIC -d "username=$QBITTORRENT_USERNAME" -d "password=$QBITTORRENT_PASSWORD" "$QBITTORRENT_PRIVATE_HOST/api/v2/auth/login"
    curl -s -c $COOKIE_FILE_PRIVATE -d "username=$QBITTORRENT_USERNAME" -d "password=$QBITTORRENT_PASSWORD" "$QBITTORRENT_PRIVATE_HOST/api/v2/auth/login"

    # Get magnet link for torrent from public qbit
    MAGNET_URI=$(curl -b "$COOKIE_FILE_PUBLIC" "http://$QBITTORRENT_PUBLIC_HOST/api/v2/torrents/info?hashes=$INFOHASH" | ${pkgs.jq}/bin/jq -r ".[].magnet_uri")

    # Add torrent to private client
    TORRENT_ADD_RESPONSE=$(curl -s -b "$COOKIE_FILE_PRIVATE" \
                            -F "urls=$MAGNET_URI" \
                            -F "category=cross-seed-tmp" \
                            -F "autoTMM=false" \
                            -F "savepath=$PRIVATE_TORRENT_BASE/$TORRENT_FOLDER" \
                            "$QBITTORRENT_PRIVATE_HOST/api/v2/torrents/add")

    # Optional: Remove original torrent after successful cross-seed (uncomment if desired)
    # curl -s -b $COOKIE_FILE_PRIVATE -d "hashes=$INFOHASH" "$QBITTORRENT_PRIVATE_HOST/api/v2/torrents/delete"

    echo "Cross-seed process completed successfully for $INFOHASH"
else
    echo "Cross-seed webhook failed with HTTP status $CROSS_SEED_RESPONSE"
    exit 1
fi
  '';
in {
  environment.systemPackages = [script];

  services.cloudflared.tunnels.andromeda.ingress = {
    "qbit.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    networks.qbit-public = {};
    containers = rec {
      qbit = {
        image = "ghcr.io/hotio/qbittorrent:release-5.0.2"; # until qbitmanage update
        autoUpdate = "registry";
        networking={
					networks = ["default"]; # dont support multiple networks because of vpn setup it seems
					aliases = ["qbit"];
					ports = {
            webui = {
              host = 9060;
              internal = 9060;
            };
            bittorrent-tcp = {
							host = 37461;
							internal = 37461;
              protocol = "tcp";
						};
            bittorrent-udp = {
							host = 37461;
							internal = 37461;
              protocol = "udp";
						};
          };
				};
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
          UMASK = "002";
          WEBUI_PORTS = "${toString qbit.networking.ports.webui.host}/tcp,${toString qbit.networking.ports.webui.host}/udp";

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
					"${config.sops.secrets.WIREGUARD_AIRVPN_CONF.path}:/config/wireguard/wg0.conf:ro"
          "/mnt/hdd/torrents/public:/storage/torrents/public:rw"
          "/mnt/ssd/services/qbit/config:/config:rw"
          "${script}/bin:/scripts/:ro"
          "/nix/store:/nix/store:ro"
        ];
				capabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun"];
				extraOptions = [
					"--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          "--add-host=${builtins.head cross-seed-public.networking.aliases}:10.89.1.100" # add cross seed hostname manually because of vpn
          "--add-host=${builtins.head config.virtualisation.oci-containers.compose.mediaserver.containers.qbit-private.networking.aliases}:10.89.1.90" # add private qbit hostname manually because of vpn
				];
        labels = [
          # Reverse proxy config. Passed on: https://github.com/qbittorrent/qBittorrent/wiki/Traefik-Reverse-Proxy-for-Web-UI
          "traefik.enable=true"      

          # Router Configuration
          "traefik.http.routers.qb.entryPoints=local"
          "traefik.http.routers.qb.rule=Host(`qbit.mgrlab.dk`)"
          
          # Security Headers
          "traefik.http.middlewares.qb-headers.headers.customRequestHeaders.X-Frame-Options=SAMEORIGIN"
          "traefik.http.middlewares.qb-headers.headers.customRequestHeaders.Referer="
          "traefik.http.middlewares.qb-headers.headers.customRequestHeaders.Origin="
          
          # Apply headers middleware
          "traefik.http.routers.qb.middlewares=qb-headers"
          
          # Service Configuration
          "traefik.http.services.qb.loadbalancer.server.port=9060"
          "traefik.http.services.qb.loadbalancer.passHostHeader=false"

          # Monitoring
          "kuma.qbit.http.name=Qbittorrent"
          "kuma.qbit.http.url=https://qbit.mgrlab.dk" # TODO: make use of authentication because more fun and challenging 
        ];
      };

      cross-seed-public = {
        image= "ghcr.io/cross-seed/cross-seed:6";
        commands = ["daemon"];
        # user = "1000:100";
        networking = {
          networks = ["default:ip=10.89.1.100"];
          aliases = ["cross-seed-public"];
          ports = {
            http = {
              host = 2469;
              internal = 2468;
            };
          };
        };
        volumes = [
          "/mnt/ssd/services/cross-seed-public/config:/config:rw" # config location
          "${config.sops.secrets.CROSS_SEED_CONFIG_PUBLIC.path}:/config/config.js:ro"
          "/mnt/ssd/services/qbit/config/data/BT_backup:/mnt/ssd/services/qbit/config/data/BT_backup:ro" # readonly access to torrent files for qbit
          "/mnt/hdd/torrents:/storage/torrents:rw" # root folder for torrents in qbit
        ];
        dependsOn = ["qbit"];
      };

      qbitmanage = {
        image = "ghcr.io/hotio/qbitmanage:nightly";
        autoUpdate = "registry";
        networking.networks = ["default" "qbit-public"];
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
          UMASK = "002";
          QBT_DRY_RUN = "false";
          QBT_SCHEDULE = "60";
        };
        volumes = [
          "/mnt/ssd/services/qbitmanage/config:/config:rw"
          # "${./qbitmanage.config.yml}:/config/config.yml:ro"
          "/mnt/hdd/torrents/public:/storage/torrents/public:rw"
        ];
        dependsOn = ["qbit"];
      };
    };
  };

  # Systemd service with script to update automatic trackerlist
  # systemd.services.qbittorrent-trackers = {
  #   description = "qBittorrent Auto-Trackers Update Service";
    
  #   # Required services
  #   after = [ "network-online.target" "qbittorrent.service" ];
  #   requires = [ "qbittorrent.service" ];
  #   wants = [ "network-online.target" ];
    
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "qbittorrent";
  #     Group = "qbittorrent";
  #     ExecStart = "${pkgs.writeScriptBin "qbt-trackers.sh" (builtins.readFile ./qbt-trackers.sh)}/bin/qbt-trackers.sh";
      
  #     # Security hardening
  #     PrivateTmp = true;
  #     ProtectSystem = "strict";
  #     ProtectHome = true;
  #     NoNewPrivileges = true;
      
  #     # Network access
  #     IPAddressDeny = "none";
  #     IPAddressAllow = "any";
  #   };
  # };

  # # Timer to run the service daily
  # systemd.timers.qbittorrent-trackers = {
  #   wantedBy = [ "timers.target" ];
  #   partOf = [ "qbittorrent-trackers.service" ];
    
  #   timerConfig = {
  #     OnCalendar = "daily";
  #     Persistent = true;
  #     Unit = "qbittorrent-trackers.service";
  #   };
  # };

  # Systemd service with script to update torrents with bad trackers
}

# curl -XPOST cross-seed-public:2469/api/webhook?apikey=ef5d258cb193893abc952a7ee4d3614c73e060daf8411819 --data-urlencode "infoHash=%I"