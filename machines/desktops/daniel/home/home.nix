{inputs, ...}: {
  home.stateVersion = "23.11";

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-material-dark-medium;

  services = {
    swayosd = {
      enable = true;
      display = "eDP-1";
    };
  };
}
