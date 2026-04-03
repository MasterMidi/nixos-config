{ ... }:
{
  flake.nixosModules.laptop-power-management =
    { config, lib, ... }:
    {
      # Enable zswap to compressed swap in memory before going to disk
      boot.kernelParams = [
        "zswap.enabled=1" # enables zswap
        "zswap.compressor=lz4" # compression algorithm
        "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
        "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure

        # set offset for swap resume
        "resume_offset=<first_physical_offset>"
      ];
      boot.initrd.systemd.enable = true; # Needed for lz4 compression in zswap

      # Physical swap file for when memory is all used
      swapDevices = [
        {
          # label = "swap";
          device = "/var/lib/swapfile";
          size = 16 * 1024; # 16GB example
          options = [ "discard" ]; # For improved perfomance and longevity on ssd-backed swap https://wiki.nixos.org/wiki/Swap#discard
        }
      ];
      # boot.resumeDevice = config.fileSystems."/".device;

      powerManagement.enable = true;
    };
}
