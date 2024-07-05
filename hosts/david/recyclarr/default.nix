{config, ...}: {
  services.recyclarr = {
    enable = true;
    # secretsFile = ./secrets.yml; # not checked in for now :P
    settings = {};
    config = {
      sonarr = import ./sonarr {inherit config;};
      # radarr = import ./radarr {inherit config;};
    };
  };
}
