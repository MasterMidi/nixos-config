{ self, ... }:
{
  flake.nixosModules.laptop-power-management =
    { config, lib, ... }:
    {
      imports = [ self.nixosModules.zswap ];

      zswap = {
        enable = true;
        compressor = "lzo";
      };

      boot = {
        # Define kernel parameters for zswap and hibernation
        kernelParams = [
          # WARNING: resume_offset is highly specific to the physical location of the swapfile on the disk.
          # If this flake module is shared across multiple machines, this value MUST be moved to a host-specific file.
          "resume_offset=24452618"
        ];

        # The block device that contains the swapfile.
        resumeDevice = config.fileSystems."/".device;
      };

      # Physical swap file configuration
      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = 16 * 1024; # 16GB
          options = [ "discard" ]; # Trims the swap file to improve SSD performance and longevity
        }
      ];

      powerManagement.enable = true;
      services.power-profiles-daemon.enable = true;

      # logind configuration for hardware buttons and lid switch
      services.logind.settings.Login = {
        lidSwitch = "suspend-then-hibernate";
        powerKey = "hibernate";
        powerKeyLongPress = "poweroff";
      };

      # Configure systemd sleep states
      systemd.sleep.settings.Sleep = {
        # The delay before transitioning from suspend (RAM) to hibernate (Disk)
        HibernateDelaySec = 3600;
      };
    };
}
