{...}: {
  services.recyclarr = {
    enable = true;
    settings = {};
    config = {
      sonarr = import ./sonarr {};
      radarr = import ./radarr {};
    };
  };
}
