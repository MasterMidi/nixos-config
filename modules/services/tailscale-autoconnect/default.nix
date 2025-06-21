{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.tailscale.autoConnect;
  package = config.services.tailscale.package;
in
{
  meta.maintainers = with lib.maintainers; [ mrene ];

  options.services.tailscale.autoConnect = {
    enable = lib.mkEnableOption "the OpenThread Border Router";

    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The path to a file containing the authentication key";
    };
  };

  config = lib.mkIf (cfg.enable && config.services.tailscale.enable) {
    # create a oneshot job to authenticate to Tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [
        "network-pre.target"
        "tailscale.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
      ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${package}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${package}/bin/tailscale up -authkey $(cat ${cfg.apiKeyFile})
      '';
    };
  };
}
