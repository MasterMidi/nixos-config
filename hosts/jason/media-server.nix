{config, ...}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "users";
    user = "jellyfin";
  };
}
