{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.metrics.netdata;
in {
  options.metrics.netdata = {
    enable = lib.mkEnableOption "Enable Netdata monitoring";
    disableWebUI = lib.mkEnableOption "Disable Netdata Web UI";
  };

  config = lib.mkIf cfg.enable {
    services.netdata = {
      config = {
        global = {
          "memory mode" = "none";
        };

        # Disable Web UI for sender nodes
        web = lib.mkIf cfg.disableWebUI {
          mode = "none";
          "accept a streaming request every seconds" = 0;
        };
      };
      configDir."stream.conf" = pkgs.writeText "stream.conf" ''
        [stream]
          enabled = yes
          destination = david.local:19999
          api key = any string that is set also on the receiver side
      '';
    };
  };
}
