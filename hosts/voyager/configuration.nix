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

  networking = {
    # Enable wireless support (WPA Supplicant)
    wireless = {
      enable = true;
      # The interface name is usually wlan0 on Pi 3, but explicitly stating it helps
      interfaces = [ "wlan0" ];

      networks = {
        "McDonald's McWifi" = {
          psk = "lady121205";
        };
      };
    };

    # Ensure conflict with NetworkManager is avoided
    networkmanager.enable = false;
  };
}
