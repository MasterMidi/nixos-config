{config, ...}: {
  virtualisation.containers.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    enableOnBoot = true;
  };
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    blocky = {
      image = "spx01/blocky";
      autoStart = true;
      # Optional the instance hostname for logging purpose
      hostname = "blocky";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "4000:4000/tcp"
      ];
      environment = {
        TZ = "Europe/Copenhagen"; # Optional to synchronize the log timestamp with host
      };
      volumes = [
        # Optional to synchronize the log timestamp with host
        "/etc/localtime:/etc/localtime:ro"
        # config file
        "${./blocklist.yml}:/app/config.yml"
      ];
    };

    grafana = {
      image = "grafana/grafana:10.1.10";
      hostname = "grafana";
      ports = ["3000:3000"];
      user = "1000:100";
      volumes = [
        "/services/grafana/data:/var/lib/grafana"
        "/services/grafana/provisioning/:/etc/grafana/provisioning/"
      ];
      environment = {
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
        static_configs = [{targets = ["localhost:4000"];}];
      }
    ];
  };

  # services.grafana.enable = true;
  # services.grafana.settings = {
  #   server = {
  #     # Listening Address
  #     http_addr = "127.0.0.1";
  #     # and Port
  #     http_port = 3000;
  #     # Grafana needs to know on which domain and URL it's running
  #     domain = "jason.local";
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
}
