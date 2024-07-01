{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  home.username = "root";
  home.homeDirectory = "/root";
  home.stateVersion = "24.05";
}
