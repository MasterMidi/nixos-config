{
  lib,
  config,
  ...
}:
{
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  boot.kernelModules = [ "acpi_call" ];
  boot.kernelParams = [ "ideapad_laptop.allow_v4_dytc=1" ];
  services.acpid.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  services.auto-cpufreq.enable = lib.mkForce false;
}
