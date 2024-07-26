{inputs, ...}: {
  home.username = "michael";
  home.homeDirectory = "/home/michael";
  home.stateVersion = "23.11";

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;
}
