{...}:{
	# Kernel modules for storage
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];

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
    options = ["x-systemd.automount" "noauto"];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/9d66d39f-6f56-4d40-a768-0773e4db01b3";
    fsType = "xfs";
    options = ["x-systemd.automount" "noauto"];
  };
}
