{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    # (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  networking.hostName = "voyager";

  system.stateVersion = "25.11";

  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberryPi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];
}
