{ self, ... }:
{
  flake.nixosModules.laptop-power-management =
    { config, ... }:
    {
      imports = [ self.nixosModules.zswap ];

      zswap = {
        enable = true;
        compressor = "lzo";
      };

      boot = {
        kernelParams = [
          "resume=/dev/disk/by-uuid/b4a62dea-af21-4e0a-92cf-9f7645844568"
        ];
        resumeDevice = "/dev/disk/by-uuid/b4a62dea-af21-4e0a-92cf-9f7645844568";
      };

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

      powerManagement.cpuFreqGovernor = "schedutil";

      services.auto-cpufreq = {
        enable = false;
        settings = {
          battery = {
            governor = "Powersave";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };

      boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
      services.acpid.enable = true;
      services.tlp.enable = false;
    };
}
