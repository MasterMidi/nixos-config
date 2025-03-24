{pkgs, ...}: {
  imports = [
    # ./mediaserver/recyclarr
  ];

  # Runtime
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
      # network_interface = "podman0";
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Firewall
  networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];

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
}
