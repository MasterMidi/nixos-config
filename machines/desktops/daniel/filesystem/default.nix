{...}: {
  facter.reportPath = ./facter.json;

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0cdde5df-af82-4347-9115-4bd6743b37bb";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E4B8-C8DA";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/eaf66ae0-b614-498a-8865-c19fbeeb4774";
    fsType = "btrfs";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/d5ef45f8-c73d-4ea3-9da8-ac169d4eac74";
    fsType = "xfs";
  };

  swapDevices = [];
}
