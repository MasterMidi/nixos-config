{
  config,
  lib,
  ...
}: {
  virtualisation.containers.enable = lib.mkForce true;
  virtualisation.docker = {
    enable = lib.mkForce true;
    rootless = {
      enable = lib.mkForce true;
      setSocketVariable = lib.mkForce true;
    };
    enableOnBoot = lib.mkForce true;
  };
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    grafana = {
      image = "grafana/grafana-oss:10.1.10";
      hostname = "grafana";
      ports = ["3000:3000"];
      user = "1000:100";
      volumes = [
        "/services/grafana/data:/var/lib/grafana"
        "/services/grafana/provisioning/:/etc/grafana/provisioning/"
      ];
      environment = {
        GF_PATHS_CONFIG = "/var/lib/grafana/grafana.ini";
        GF_PANELS_DISABLE_SANITIZE_HTML = "true";
        GF_INSTALL_PLUGINS = "grafana-piechart-panel";
      };
      extraOptions = ["--network=host"];
      autoStart = true;
    };
  };

  services.prometheus = {
    enable = true;
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "blocky";
        static_configs = [{targets = ["envpi.local:4000"];}];
      }
      {
        job_name = "sonarr";
        static_configs = [{targets = ["localhost:${builtins.toString config.services.prometheus.exporters.exportarr-sonarr.port}"];}];
      }
      {
        job_name = "radarr";
        static_configs = [{targets = ["localhost:${builtins.toString config.services.prometheus.exporters.exportarr-radarr.port}"];}];
      }
      {
        job_name = "prowlarr";
        static_configs = [{targets = ["localhost:${builtins.toString config.services.prometheus.exporters.exportarr-prowlarr.port}"];}];
      }
      {
        job_name = "bazarr";
        static_configs = [{targets = ["localhost:${builtins.toString config.services.prometheus.exporters.exportarr-bazarr.port}"];}];
      }
    ];

    exporters = {
      exportarr-sonarr = {
        enable = true;
        url = "http://jason:9040";
        port = 9041;
        openFirewall = true;
        # apiKeyFile = ../../secrets/sonarr-api-key.txt;
        environment = {
          API_KEY = "c5783cdc82d244e6b138be2988397813";
        };
      };

      exportarr-radarr = {
        enable = true;
        url = "http://jason:9030";
        port = 9031;
        openFirewall = true;
        # apiKeyFile = ../../secrets/sonarr-api-key.txt;
        environment = {
          API_KEY = "51732014769e475a9455c1f5cd8f18d1";
        };
      };

      exportarr-prowlarr = {
        enable = true;
        url = "http://localhost:9696";
        port = 9697;
        openFirewall = true;
        # apiKeyFile = ../../secrets/sonarr-api-key.txt;
        environment = {
          API_KEY = "9fb4395699e94c1595a270d4086783f8";
          PROWLARR__BACKFILL = "true";
        };
      };

      exportarr-bazarr = {
        enable = true;
        url = "http://jason:9080";
        port = 9081;
        openFirewall = true;
        # apiKeyFile = ../../secrets/sonarr-api-key.txt;
        environment = {
          API_KEY = "a1e271e0a6cb3da6a89d5c23ed13fd2e";
        };
      };
    };
  };

  # services.grafana.enable = true;
  # services.grafana.settings = {
  #   server = {
  #     # Listening Address
  #     http_addr = "";
  #     # and Port
  #     http_port = 3000;
  #     # Grafana needs to know on which domain and URL it's running
  #     domain = "david.local";
  #     # root_url = "https://your.domain/grafana/"; # Not needed if it is `https://your.domain/`
  #     # serve_from_sub_path = true;
  #   };
  # };

  # services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
  #     proxyWebsockets = true;
  #   };
  # };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      3000
      config.services.prometheus.port
    ];
  };
}
