{...}: {
  # Kernel modules for storage
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7f4599a1-65eb-4eef-b09b-2c57aae16d20";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/97A0-6168";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/2c850a80-71a3-4f03-97a8-b64c4a31573c";
    fsType = "btrfs";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/8d73240a-6872-43f8-b41c-3d76759da890";
    fsType = "btrfs";
  };

  # Other drives
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/6baf0c54-8fb0-425d-ac48-fd2ca868a2bf";
    fsType = "btrfs";
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/b6de6650-e3d2-4efc-a7e4-8dd13473e6a6";
    fsType = "xfs";
    options = ["x-systemd.automount" "noauto"];
  };
}
