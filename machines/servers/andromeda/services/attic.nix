{ config, ... }:
{
  services.atticd = {
    enable = true;
    settings = {
      listen = "[::]:8787";
      allowed-hosts = [ ];
      api-endpoint = "https://nix-cache.mgrlab.dk/";
      storage = {
        type = "local";
        path = "/mnt/ssd/services/attic/data";
      };
      chunking = {
        nar-size-threshold = 65536;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
      compression = {
        type = "zstd";
      };
      garbage-collection = {
        interval = "1 day";
        default-retention-period = "1 month";
      };

      jwt = { };
    };
    environmentFile = config.sops.secrets.ATTIC_SECRET_BASE64.path;
  };
}
