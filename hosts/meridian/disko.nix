{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HBJQ-000L2_S4DYNX1R303730";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "esp"; # This shorthand type creates a FAT32 filesystem mounted at /boot
            };

            root = {
              size = "100G";
              content = {
                type = "btrfs";
                # This creates a subvolume named '@' and mounts it as the root directory '/'
                subvolumes = {
                  "@" = "/";
                };
              };
            };

            nix = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/nix";
              };
            };

            home = {
              size = "225G";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/home";
              };
            };
          };
        };
      };
    };
  };
}
