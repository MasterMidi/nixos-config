{ config, ... }:
{
  sops.secrets = {
    PANGOLIN_SERVER_SECRET = {
      sopsFile = ./secrets.sops.yaml;
    };
    STALWART_ADMIN_PASSWORD = {
      sopsFile = ./secrets.sops.yaml;
      # owner = config.users.users.stalwart-mail.name;
      # group = config.users.groups.stalwart-mail.name;
    };
    CLOUDFLARE_GLOBAL_API_KEY = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
}
