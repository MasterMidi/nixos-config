{ config, ... }:
{
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
  boot.kernelModules = [ "acpi_call" ];
  boot.kernelParams = [ "ideapad_laptop.allow_v4_dytc=1" ];
  services.acpid.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
}
