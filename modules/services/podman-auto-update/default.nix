{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.virtualisation.podman.autoUpdate;
in {
  meta.maintainers = with lib.maintainers; [mrene];

  options.virtualisation.podman.autoUpdate = {
    enable = lib.mkEnableOption "the autoupdate service for podman";

    # apiKeyFile = lib.mkOption {
    #   type = lib.types.nullOr lib.types.str;
    #   default = null;
    #   description = "The path to a file containing the authentication key";
    # };
  };

  config = lib.mkIf cfg.enable {
    # Auto-update service
    systemd.services.podman-auto-update = {
      description = "Podman auto-update service";
      path = [pkgs.podman];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.podman}/bin/podman auto-update";
        ExecStartPost = "${pkgs.podman}/bin/podman image prune -f";
      };
    };

    systemd.timers.podman-auto-update = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "900";
        Persistent = true;
      };
    };
  };
}
