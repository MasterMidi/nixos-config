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
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/373737f6-cf37-446a-a7b8-fd3c44e59399";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8D9D-71C7";
    fsType = "vfat";
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/2acaf814-d46b-45a6-a679-c0bf467a2457";
    fsType = "xfs";
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/9d66d39f-6f56-4d40-a768-0773e4db01b3";
    fsType = "xfs";
  };

  fileSystems."/var/lib/containers" = {
    device = "/mnt/ssd/containers";
    options = [ "bind" ];
  };

  fileSystems."/var/lib/rancher/k3s" = {
    device = "/mnt/ssd/k3s";
    options = [ "bind" ];
  };

  fileSystems."/var/lib/longhorn" = {
    device = "/mnt/ssd/appdata/longhorn";
    options = [ "bind" ];
  };
}
