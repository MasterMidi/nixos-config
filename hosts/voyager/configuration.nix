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

  # 1. Allow you to log in as root with a password "nixos" (change this later!)
  users.users.root.initialPassword = "nixos";

  # 2. Allow your user 'michael' to log in with "nixos"
  users.users.michael.initialPassword = "nixos";
}
