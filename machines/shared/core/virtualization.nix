{
  lib,
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (lib.mkIf config.virtualisation.podman.enable podman-tui)
  ];
}
