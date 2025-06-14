{ pkgs, modules, ... }:
{
  imports = [
    modules.options.compose
    modules.services.podman-auto-update
    ./pangolin
  ];

  # Runtime
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    autoUpdate.enable = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
      # network_interface = "podman0";
    };
  };
}
