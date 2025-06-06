{
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  facter.reportPath = ./facter.json;
}
