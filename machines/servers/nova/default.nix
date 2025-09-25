{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./containers
    ./secrets
    # ./mailserver.nix
    ./networking.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.michael.password = "Servurb42";

  services.openssh = {
    settings = {
      # PermitRootLogin = "no";
    };

    listenAddresses = [
      {
        addr = "100.98.127.33";
        port = 22;
      }
    ];
  };

  system.stateVersion = "24.11";

  # lollypops.deployment.ssh.host = "138.199.154.23";
}
