{config,...}:{
  services.cloudflared.tunnels.andromeda.ingress = {
    "bazarr.mgrlab.dk" = "http://localhost:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.traefik.networking.ports.local.host}";
  };

  virtualisation.oci-containers.compose.mediaserver = {
    containers = {
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
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = "1000";
          TZ = config.time.timeZone;
          VERBOSITY = "-vv";
        };
        volumes = [
          "/mnt/hdd/media:/storage/media:rw"
          "/mnt/ssd/services/bazarr/config:/config:rw"
        ];
        labels = [
          "traefik.enable=true"
          "traefik.port=6767"
          "traefik.http.routers.bazarr.rule=Host(`bazarr.mgrlab.dk`)"
          "traefik.http.routers.bazarr.entrypoints=local"

          # Monitoring
          "kuma.bazarr.http.name=Bazarr"
          "kuma.bazarr.http.url=https://bazarr.mgrlab.dk/system/health"
          # "kuma.bazarr.http.headers={\"X-API-KEY\": '$(cat ${config.sops.secrets.BAZARR_API_KEY.path})'}" # TODO find a way to make this work. Circemvent the shell escaping
        ];
        # extraOptions = [
        #   "--label=kuma.bazarr.http.headers={\"X-API-KEY\": \"$(cat ${config.sops.secrets.BAZARR_API_KEY.path})\"}"
        # ];
      };
    };
  };

  # virtualisation.oci-containers.containers.mediaserver-bazarr.preRunExtraOptions = ["API_KEY=$(cat /run/secrets/BAZARR_API_KEY)"];

  # prometheus exporters
  services.prometheus.exporters = {
    exportarr-bazarr = {
      enable = true;
      user = "michael";
      group = "users";
      url = "http://localhost:${config.virtualisation.oci-containers.compose.mediaserver.containers.bazarr.networking.ports.webui.host |> builtins.toString}";
      openFirewall = true;
      apiKeyFile = config.sops.secrets.BAZARR_API_KEY.path;
      port = 9081;
    };
  };
}