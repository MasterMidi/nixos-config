{ pkgs, self, ... }:
{
  imports = [
    self.modules.nixos.compose
    self.modules.nixos.podman-auto-update
    # ./headscale.nix
    ./vaultwarden.nix
  ];

  virtualisation = {
    oci-containers.compose.tunnel = {
      enable = true;
      networks.default = { };
    };

    # Runtime
    containers.enable = true;
    podman = {
      enable = true;
      autoPrune.enable = true;
      autoUpdate.enable = true;
      defaultNetwork.settings = {
        # Required for container networking to be able to use names.
        dns_enabled = true;
        # network_interface = "podman0";
      };
    };
  };
}
