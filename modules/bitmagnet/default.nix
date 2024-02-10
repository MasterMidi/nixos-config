{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.bitmagnet;
  bitmagnetPackage = pkgs.bitmagnet; # Ensure this is your packaged application
  configFile = pkgs.writeTextFile {
    name = "config.yml";
    text = builtins.toJSON cfg.settings;
    destination = "/etc/bitmagnet/config.yml"; # Replace with actual desired path
  };
in {
  options = {
    services.bitmagnet = {
      enable = mkEnableOption (lib.mdDoc "Bitmagnet Service");

      package = mkPackageOption pkgs "bitmagnet" {};

      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "Configuration settings for bitmagnet.";
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables for the Bitmagnet service.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.bitmagnet = {
      description = "Bitmagnet Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/bitmagnet worker run --keys=http_server --keys=queue_server --keys=dht_crawler";
        Restart = "on-failure";

        Environment = let
          envVars = cfg.environment;
        in
          lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}=${value}") envVars);
      };
    };
  };
}
