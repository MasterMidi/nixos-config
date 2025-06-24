{
  lib,
  inputs,
  osConfig,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;
  home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
}
