{
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    (modulesPath + "/installer/scan/not-detected.nix")

    ./peripherals.nix
  ];
  facter.reportPath = ./facter.json;
}
