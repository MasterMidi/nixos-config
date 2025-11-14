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
    # (modulesPath + "/virtualisation/qemu-vm.nix")
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

  services.openssh = {
    settings = {
      # PermitRootLogin = "no";
    };
  };

  system.stateVersion = "24.11";

  networking.hostName = "aether";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  services.resolved.enable = true;

  # virtualisation.qemu.guestAgent.enable = true; # enable hetzner admin password reset
  services.qemuGuest.enable = true;
}
