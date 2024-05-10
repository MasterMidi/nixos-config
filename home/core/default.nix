{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./programs/starship.nix
    ./shell
  ];
}
