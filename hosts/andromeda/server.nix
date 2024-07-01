{
  pkgs,
  config,
  ...
}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # services.qbittorrent = {
  #   enable = true;
  #   openFirewall = true;
  #   group = "media";
  # };

  users.groups.media = {
    system = true;
    gid = 500;
  };
}
