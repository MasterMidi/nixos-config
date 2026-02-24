{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
  flake.modules.nixos = {
    vfio = ./vfio;
    refind = ./refind;
    compose = ./compose;
    development = ./development;
		jdupes = ./jdupes;
    openthread-border-router = ./openthread-border-router;
    podman-auto-update = ./podman-auto-update;
    tailscale-autoconnect = ./tailscale-autoconnect;
  };
}
