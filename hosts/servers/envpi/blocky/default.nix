{...}: {
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
  };
}
