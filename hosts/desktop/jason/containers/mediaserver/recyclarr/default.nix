{...}: {
  services.recyclarr = {
    enable = false;
    # secretsFile = ./secrets.yml; # not checked in for now :P
    settings = {};
    config = {
      sonarr = import ./sonarr {};
      radarr = import ./radarr {};
    };
  };
}
