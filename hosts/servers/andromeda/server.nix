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

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    acceptLegalNotice = true;
    group = "media";
  };

  users.groups.media = {
    gid = 500;
  };

  users.users.michael.extraGroups = ["media"];
}
