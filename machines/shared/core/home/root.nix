{
  inputs,
  osConfig,
  ...
}: {
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  home.username = "root";
  home.homeDirectory = "/root";
  home.stateVersion = osConfig.system.stateVersion;
}
