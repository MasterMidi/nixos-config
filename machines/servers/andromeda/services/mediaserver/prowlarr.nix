{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "prowlarr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  # services.mullvad-vpn.enable = true;
  services.resolved.enable = true; # Needed for mullvad to work: https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/8

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
      prowlarr = rec {
        image = "ghcr.io/hotio/prowlarr:nightly";
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
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
        };
        volumes = [
          "/mnt/ssd/services/prowlarr/config:/config:rw"
        ];
        capabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun"];
				extraOptions = [
					"--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          # "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
				];
        labels = [
          "traefik.enable=true"
          "traefik.port: 9696"
          "traefik.http.routers.prowlarr.rule=Host(`prowlarr.mgrlab.dk`)"
          "traefik.http.routers.prowlarr.entrypoints=local"

          # Monitoring
          "kuma.prwolarr.http.name=Prowlarr"
          "kuma.prwolarr.http.url=https://prowlarr.mgrlab.dk/ping"
        ];
      };

      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        autoUpdate = "registry";
        networking = {
          networks = ["default"];
          aliases = ["flaresolverr"];
          ports = { # use expose instead (so i dont map to host network, since i dont need to)
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
    exportarr-radarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:${config.virtualisation.oci-containers.compose.mediaserver.containers.radarr.networking.ports.webui.host |> builtins.toString}";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.RADARR_API_KEY.path;
      port = 9031;
    };
  };
}