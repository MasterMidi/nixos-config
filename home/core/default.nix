{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./programs/starship.nix
    ./shell
  ];
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;
}
