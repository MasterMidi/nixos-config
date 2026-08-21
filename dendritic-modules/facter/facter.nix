{ ... }:
{
  flake.nixosModules.facter =
    { config,... }:
    {
      hardware.facter = {
        reportPath = ./. + "/reports/${config.networking.hostName}-facter.json";
      };
    };
}
