{
  # checkout the example folder for how to configure different disko layouts
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/some-disk-id";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
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
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/home";
              };
            };
          };
        };
      };
    };
  };
}
