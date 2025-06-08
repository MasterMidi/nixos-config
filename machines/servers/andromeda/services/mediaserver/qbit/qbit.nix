{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.compose.mediaserver = {
    networks.qbit-public = {};
    containers = rec {
      qbit = {
        image = "ghcr.io/hotio/qbittorrent:release-5.0.4";
        autoUpdate = "registry";
        networking = {
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
          VPN_ENABLED = "true";
          VPN_CONF = "wg0";
          VPN_PROVIDER = "generic";
          VPN_LAN_NETWORK = "192.168.1.0/24";
          VPN_LAN_LEAK_ENABLED = "false";
          # VPN_AUTO_PORT_FORWARD="false";
          VPN_KEEP_LOCAL_DNS = "true";
          VPN_FIREWALL_TYPE = "auto";
          VPN_HEALTHCHECK_ENABLED = "false";
          PRIVOXY_ENABLED = "true";
          UNBOUND_ENABLED = "false";
        };
        volumes = [
          "${config.sops.templates.WIREGUARD_AIRVPN_CONF.path}:/config/wireguard/wg0.conf:ro"
          "/mnt/hdd/torrents:/storage/torrents:rw"
          "/mnt/ssd/services/qbit/config:/config:rw"
          # "${script}/bin:/scripts/:ro"
          # "/nix/store:/nix/store:ro"
        ];
        capabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun"];
        extraOptions = [
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          # "--add-host=${builtins.head cross-seed-public.networking.aliases}:10.89.1.100" # add cross seed hostname manually because of vpn
          # "--add-host=${builtins.head config.virtualisation.oci-containers.compose.mediaserver.containers.qbit-private.networking.aliases}:10.89.1.90" # add private qbit hostname manually because of vpn
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
    };
  };

  sops.templates.WIREGUARD_AIRVPN_CONF = {
    owner = config.users.users.michael.name;
    group = config.users.groups.users.name;
    restartUnits = [
      config.virtualisation.oci-containers.compose.mediaserver.containers.qbit.unitName
      # config.virtualisation.oci-containers.compose.mediaserver.containers.qbit-private.unitName
    ];
    content = lib.generators.toINI {} {
      Interface = {
        Address = "10.142.244.184/32,fd7d:76ee:e68f:a993:77f5:2a70:242b:6a1a/128";
        PrivateKey = config.sops.placeholder.AIRVPN_WIREGUARD_PRIVATE_KEY;
        MTU = 1320;
        DNS = "10.128.0.1, fd7d:76ee:e68f:a993::1";
      };
      Peer = {
        PublicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
        PresharedKey = config.sops.placeholder.AIRVPN_WIREGUARD_PRESHARED_KEY;
        Endpoint = "europe3.vpn.airdns.org:1637";
        AllowedIPs = "0.0.0.0/0,::/0";
        PersistentKeepalive = 15;
      };
    };
  };

  # Systemd service to update uptime kuma port checker based on qbit log: Detected external IP. IP: "xxx.xxx.xxx.xxx"

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
