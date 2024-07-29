{inputs, ...}: {
  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "24.05";

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;
}
