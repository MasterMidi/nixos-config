{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [ inputs.nixos-facter-modules.nixosModules.facter ];

  facter.reportPath = ./facter.json;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fcd29710-e98e-4eb4-8b2e-0f37d945ecc6";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E4B8-C8DA";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/b4a62dea-af21-4e0a-92cf-9f7645844568";
      options = [ "discard" ]; # Trims the swap file to improve SSD performance and longevity
    }
  ];
}
